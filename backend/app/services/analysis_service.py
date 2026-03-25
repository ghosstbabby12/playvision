from pathlib import Path
from datetime import datetime, timezone

from app.db.supabase_client import supabase
from app.core.config import settings
from app.workers.process_match import run_tracking_analysis


def utcnow_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def get_match(match_id: int) -> dict:
    response = (
        supabase.table("matches")
        .select("*")
        .eq("id", match_id)
        .single()
        .execute()
    )
    return response.data


def get_analysis_job(job_id: str) -> dict:
    response = (
        supabase.table("analysis_jobs")
        .select("*")
        .eq("id", job_id)
        .single()
        .execute()
    )
    return response.data


def update_match_status(match_id: int, status: str) -> None:
    supabase.table("matches").update({
        "status": status,
    }).eq("id", match_id).execute()


def resolve_source_type(source_url: str | None, fallback_type: str | None) -> str | None:
    if fallback_type:
        return fallback_type

    if not source_url:
        return None

    lowered = source_url.lower()

    if "youtube.com" in lowered or "youtu.be" in lowered:
        return "youtube"

    if lowered.startswith("http://") or lowered.startswith("https://"):
        return "external"

    return "upload"


def resolve_match_source(match: dict, override_source_url: str | None = None) -> str | None:
    return (
        override_source_url
        or match.get("source_url")
        or match.get("video_url")
    )


def create_analysis_job(match_id: int, source_url: str | None = None) -> dict:
    match = get_match(match_id)

    resolved_source_url = resolve_match_source(match, source_url)
    resolved_source_type = resolve_source_type(
        resolved_source_url,
        match.get("source_type"),
    )

    if not resolved_source_url:
        raise RuntimeError("El partido no tiene video_url o source_url para analizar.")

    row = {
        "match_id": match_id,
        "status": "queued",
        "source_type": resolved_source_type,
        "source_url": resolved_source_url,
    }

    response = supabase.table("analysis_jobs").insert(row).execute()
    return response.data[0]


def upload_generated_files(match_id: int, job_id: str) -> list[dict]:
    match_dir = Path("backend/output") / f"match_{match_id}"
    uploaded_assets = []

    files_to_upload = [
        ("summary_json", match_dir / "match_summary.json", "application/json"),
        ("player_metrics_csv", match_dir / "player_metrics.csv", "text/csv"),
        ("frame_counts_csv", match_dir / "frame_counts.csv", "text/csv"),
    ]

    bucket = supabase.storage.from_(settings.analysis_output_bucket)

    for asset_type, file_path, content_type in files_to_upload:
        if not file_path.exists():
            continue

        storage_path = f"matches/{match_id}/{job_id}/{file_path.name}"

        with open(file_path, "rb") as f:
            bucket.upload(
                storage_path,
                f,
                {"content-type": content_type, "upsert": "true"},
            )

        public_url = bucket.get_public_url(storage_path)

        uploaded_assets.append({
            "analysis_job_id": job_id,
            "match_id": match_id,
            "asset_type": asset_type,
            "storage_bucket": settings.analysis_output_bucket,
            "storage_path": storage_path,
            "public_url": public_url,
            "metadata": {"filename": file_path.name},
        })

    return uploaded_assets


def save_result(job: dict, result: dict) -> None:
    job_id = job["id"]
    match_id = job["match_id"]

    supabase.table("player_metrics").delete().eq("analysis_job_id", job_id).execute()
    supabase.table("player_recommendations").delete().eq("analysis_job_id", job_id).execute()
    supabase.table("analysis_assets").delete().eq("analysis_job_id", job_id).execute()

    player_rows = []
    for player in result["players"]:
        player_rows.append({
            "analysis_job_id": job_id,
            "match_id": match_id,
            "track_id": player["track_id"],
            "team_label": player["team_label"],
            "first_frame": player["first_frame"],
            "last_frame": player["last_frame"],
            "frames_detected": player["frames_detected"],
            "max_frames_seen": player["max_frames_seen"],
            "avg_conf": player["avg_conf"],
            "avg_color_score": player["avg_color_score"],
            "stable_player": player["stable_player"],
            "avg_box": player["avg_box"],
        })

    if player_rows:
        supabase.table("player_metrics").insert(player_rows).execute()

    recommendation_rows = []
    for rec in result["recommendations"]:
        recommendation_rows.append({
            "analysis_job_id": job_id,
            "match_id": match_id,
            "track_id": rec.get("track_id"),
            "target_type": rec["target_type"],
            "priority": rec["priority"],
            "title": rec["title"],
            "body": rec["body"],
        })

    if recommendation_rows:
        supabase.table("player_recommendations").insert(recommendation_rows).execute()

    report_row = {
        "match_id": match_id,
        "analysis_job_id": job_id,
        "summary_json": {
            "match_id": result["match_id"],
            "source": result["source"],
            "stats": result["stats"],
            "players": result["players"],
            "frame_counts": result["frame_counts"],
            "recommendations": result["recommendations"],
        },
        "chart_json": result["chart_json"],
    }

    supabase.table("match_reports").upsert(
        report_row,
        on_conflict="match_id",
    ).execute()

    assets = upload_generated_files(match_id, job_id)
    if assets:
        supabase.table("analysis_assets").insert(assets).execute()


def run_analysis_job(job_id: str) -> None:
    job = get_analysis_job(job_id)
    match_id = job["match_id"]

    supabase.table("analysis_jobs").update({
        "status": "processing",
        "started_at": utcnow_iso(),
        "error_message": None,
    }).eq("id", job_id).execute()

    update_match_status(match_id, "processing")

    try:
        match = get_match(match_id)

        source = (
            job.get("source_url")
            or match.get("source_url")
            or match.get("video_url")
        )

        if not source:
            raise RuntimeError("El partido no tiene video_url o source_url para analizar.")

        result = run_tracking_analysis(source, match_id)
        save_result(job, result)

        supabase.table("analysis_jobs").update({
            "status": "done",
            "completed_at": utcnow_iso(),
            "error_message": None,
        }).eq("id", job_id).execute()

        update_match_status(match_id, "done")

    except Exception as e:
        supabase.table("analysis_jobs").update({
            "status": "error",
            "completed_at": utcnow_iso(),
            "error_message": str(e),
        }).eq("id", job_id).execute()

        update_match_status(match_id, "uploaded")
        raise


def get_match_report(match_id: int) -> dict:
    report = (
        supabase.table("match_reports")
        .select("*")
        .eq("match_id", match_id)
        .single()
        .execute()
        .data
    )

    players = (
        supabase.table("player_metrics")
        .select("*")
        .eq("match_id", match_id)
        .order("track_id")
        .execute()
        .data
    )

    recommendations = (
        supabase.table("player_recommendations")
        .select("*")
        .eq("match_id", match_id)
        .execute()
        .data
    )

    assets = (
        supabase.table("analysis_assets")
        .select("*")
        .eq("match_id", match_id)
        .execute()
        .data
    )

    return {
        "match_id": match_id,
        "report": report,
        "players": players,
        "recommendations": recommendations,
        "assets": assets,
    }
