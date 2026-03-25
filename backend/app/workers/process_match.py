from pathlib import Path
import json
import csv
import shutil
import requests
import cv2
import numpy as np
from yt_dlp import YoutubeDL
from ultralytics import YOLO

from app.core.config import settings
from app.services.chart_service import build_chart_payload
from app.services.recommendation_service import generate_recommendations


def clamp(v, min_v, max_v):
    return max(min_v, min(int(v), max_v))


def download_source(source: str, output_dir: Path) -> Path:
    output_dir.mkdir(parents=True, exist_ok=True)

    if source.startswith("http://") or source.startswith("https://"):
        if "youtube.com" in source or "youtu.be" in source:
            target = output_dir / "input_video.mp4"
            ydl_opts = {
                "format": "mp4/bestvideo+bestaudio/best",
                "outtmpl": str(target),
                "merge_output_format": "mp4",
                "quiet": True,
                "noprogress": True,
            }
            with YoutubeDL(ydl_opts) as ydl:
                ydl.download([source])
            if target.exists():
                return target

            candidates = list(output_dir.glob("*.mp4"))
            if candidates:
                return candidates[0]

            raise RuntimeError("No se pudo descargar el video de YouTube.")

        target = output_dir / "input_video.mp4"
        with requests.get(source, stream=True, timeout=120) as r:
            r.raise_for_status()
            with open(target, "wb") as f:
                for chunk in r.iter_content(chunk_size=1024 * 1024):
                    if chunk:
                        f.write(chunk)
        return target

    local_path = Path(source)
    if not local_path.exists():
        raise FileNotFoundError(f"No existe el archivo local: {source}")

    target = output_dir / local_path.name
    shutil.copy2(local_path, target)
    return target


def classify_team_by_color(frame, box):
    h, w = frame.shape[:2]
    x1, y1, x2, y2 = box

    x1 = clamp(x1, 0, w - 1)
    y1 = clamp(y1, 0, h - 1)
    x2 = clamp(x2, 0, w - 1)
    y2 = clamp(y2, 0, h - 1)

    if x2 <= x1 or y2 <= y1:
        return "unknown", 0.0

    bw = x2 - x1
    bh = y2 - y1

    torso_x1 = x1 + int(bw * 0.20)
    torso_x2 = x2 - int(bw * 0.20)
    torso_y1 = y1 + int(bh * 0.20)
    torso_y2 = y1 + int(bh * 0.60)

    torso_x1 = clamp(torso_x1, 0, w - 1)
    torso_y1 = clamp(torso_y1, 0, h - 1)
    torso_x2 = clamp(torso_x2, 0, w - 1)
    torso_y2 = clamp(torso_y2, 0, h - 1)

    if torso_x2 <= torso_x1 or torso_y2 <= torso_y1:
        return "unknown", 0.0

    roi = frame[torso_y1:torso_y2, torso_x1:torso_x2]
    if roi.size == 0:
        return "unknown", 0.0

    hsv = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)

    green_lower = np.array([35, 40, 40])
    green_upper = np.array([85, 255, 255])

    red_lower_1 = np.array([0, 50, 50])
    red_upper_1 = np.array([10, 255, 255])
    red_lower_2 = np.array([170, 50, 50])
    red_upper_2 = np.array([179, 255, 255])

    green_mask = cv2.inRange(hsv, green_lower, green_upper)
    red_mask_1 = cv2.inRange(hsv, red_lower_1, red_upper_1)
    red_mask_2 = cv2.inRange(hsv, red_lower_2, red_upper_2)
    red_mask = cv2.bitwise_or(red_mask_1, red_mask_2)

    green_ratio = np.count_nonzero(green_mask) / green_mask.size
    red_ratio = np.count_nonzero(red_mask) / red_mask.size

    if green_ratio > red_ratio and green_ratio >= settings.team_color_threshold:
        return "green_team", green_ratio

    if red_ratio > green_ratio and red_ratio >= settings.team_color_threshold:
        return "red_team", red_ratio

    return "unknown", max(green_ratio, red_ratio)


def get_final_team(votes: dict) -> str:
    green = votes.get("green_team", 0)
    red = votes.get("red_team", 0)

    if green == 0 and red == 0:
        return "unknown"

    return "green_team" if green >= red else "red_team"


def run_tracking_analysis(source: str, match_id: int) -> dict:
    match_dir = Path("backend/output") / f"match_{match_id}"
    source_dir = match_dir / "source"
    source_dir.mkdir(parents=True, exist_ok=True)

    video_path = download_source(source, source_dir)

    model = YOLO(settings.yolo_model_path)
    results = model.track(
        source=str(video_path),
        classes=[0],
        conf=0.40,
        persist=True,
        stream=True,
        save=False,
        verbose=False,
    )

    frame_rows = []
    frame_counts = []

    raw_unique_ids = set()
    track_frames = {}
    team_votes = {}

    frame_index = 0

    for result in results:
        frame_index += 1
        frame = result.orig_img.copy()
        frame_h, frame_w = frame.shape[:2]
        frame_area = frame_h * frame_w

        visible_green_ids = set()
        visible_red_ids = set()
        visible_unknown_ids = set()

        if result.boxes is not None and result.boxes.id is not None and result.boxes.xyxy is not None:
            boxes = result.boxes.xyxy.cpu().numpy()
            ids = result.boxes.id.int().cpu().tolist()
            confs = result.boxes.conf.cpu().tolist()
            classes = result.boxes.cls.int().cpu().tolist()

            for box, track_id, conf, cls_id in zip(boxes, ids, confs, classes):
                if cls_id != 0:
                    continue

                x1, y1, x2, y2 = map(int, box)
                box_area = max(0, x2 - x1) * max(0, y2 - y1)

                if box_area < frame_area * settings.min_box_area_ratio:
                    continue

                raw_unique_ids.add(track_id)
                track_frames[track_id] = track_frames.get(track_id, 0) + 1

                if track_id not in team_votes:
                    team_votes[track_id] = {
                        "green_team": 0,
                        "red_team": 0,
                        "unknown": 0,
                    }

                frame_team_label, color_score = classify_team_by_color(
                    frame, (x1, y1, x2, y2)
                )
                team_votes[track_id][frame_team_label] += 1

                final_team = get_final_team(team_votes[track_id])
                is_stable = track_frames[track_id] >= settings.min_track_frames

                if final_team == "green_team" and is_stable:
                    visible_green_ids.add(track_id)
                elif final_team == "red_team" and is_stable:
                    visible_red_ids.add(track_id)
                elif is_stable:
                    visible_unknown_ids.add(track_id)

                frame_rows.append({
                    "frame": frame_index,
                    "track_id": track_id,
                    "x1": x1,
                    "y1": y1,
                    "x2": x2,
                    "y2": y2,
                    "conf": round(float(conf), 4),
                    "frames_seen": track_frames[track_id],
                    "frame_team_label": frame_team_label,
                    "color_score": round(float(color_score), 4),
                    "final_team": final_team,
                    "is_stable": bool(is_stable),
                })

        frame_counts.append({
            "frame": frame_index,
            "green_visible": len(visible_green_ids),
            "red_visible": len(visible_red_ids),
            "unknown_visible": len(visible_unknown_ids),
            "total_visible": len(visible_green_ids) + len(visible_red_ids) + len(visible_unknown_ids),
        })

    players_map = {}
    for row in frame_rows:
        tid = row["track_id"]
        if tid not in players_map:
            players_map[tid] = {
                "track_id": tid,
                "first_frame": row["frame"],
                "last_frame": row["frame"],
                "frames_detected": 0,
                "max_frames_seen": 0,
                "avg_conf_sum": 0.0,
                "avg_color_sum": 0.0,
                "green_votes": 0,
                "red_votes": 0,
                "unknown_votes": 0,
                "stable_player": False,
                "avg_box_sum": {"x1": 0, "y1": 0, "x2": 0, "y2": 0},
            }

        p = players_map[tid]
        p["frames_detected"] += 1
        p["first_frame"] = min(p["first_frame"], row["frame"])
        p["last_frame"] = max(p["last_frame"], row["frame"])
        p["max_frames_seen"] = max(p["max_frames_seen"], row["frames_seen"])
        p["avg_conf_sum"] += row["conf"]
        p["avg_color_sum"] += row["color_score"]
        p["avg_box_sum"]["x1"] += row["x1"]
        p["avg_box_sum"]["y1"] += row["y1"]
        p["avg_box_sum"]["x2"] += row["x2"]
        p["avg_box_sum"]["y2"] += row["y2"]

        if row["final_team"] == "green_team":
            p["green_votes"] += 1
        elif row["final_team"] == "red_team":
            p["red_votes"] += 1
        else:
            p["unknown_votes"] += 1

        if row["is_stable"]:
            p["stable_player"] = True

    players = []
    stable_green = 0
    stable_red = 0
    stable_unknown = 0

    for tid in sorted(players_map.keys()):
        p = players_map[tid]
        frames_detected = p["frames_detected"]

        team_votes_summary = {
            "green_team": p["green_votes"],
            "red_team": p["red_votes"],
            "unknown": p["unknown_votes"],
        }
        team_label = max(team_votes_summary, key=team_votes_summary.get)

        player = {
            "track_id": tid,
            "first_frame": p["first_frame"],
            "last_frame": p["last_frame"],
            "frames_detected": frames_detected,
            "max_frames_seen": p["max_frames_seen"],
            "avg_conf": round(p["avg_conf_sum"] / frames_detected, 4),
            "avg_color_score": round(p["avg_color_sum"] / frames_detected, 4),
            "green_votes": p["green_votes"],
            "red_votes": p["red_votes"],
            "unknown_votes": p["unknown_votes"],
            "team_label": team_label,
            "stable_player": p["stable_player"],
            "avg_box": {
                "x1": round(p["avg_box_sum"]["x1"] / frames_detected),
                "y1": round(p["avg_box_sum"]["y1"] / frames_detected),
                "x2": round(p["avg_box_sum"]["x2"] / frames_detected),
                "y2": round(p["avg_box_sum"]["y2"] / frames_detected),
            },
        }
        players.append(player)

        if player["stable_player"]:
            if team_label == "green_team":
                stable_green += 1
            elif team_label == "red_team":
                stable_red += 1
            else:
                stable_unknown += 1

    avg_green_visible = round(
        sum(x["green_visible"] for x in frame_counts) / len(frame_counts), 2
    ) if frame_counts else 0.0
    avg_red_visible = round(
        sum(x["red_visible"] for x in frame_counts) / len(frame_counts), 2
    ) if frame_counts else 0.0
    avg_unknown_visible = round(
        sum(x["unknown_visible"] for x in frame_counts) / len(frame_counts), 2
    ) if frame_counts else 0.0

    stats = {
        "total_players_detected": len(players),
        "stable_players_detected": sum(1 for p in players if p["stable_player"]),
        "unstable_players_detected": sum(1 for p in players if not p["stable_player"]),
        "green_team_stable_players": stable_green,
        "red_team_stable_players": stable_red,
        "unknown_stable_players": stable_unknown,
        "frames_with_counts": len(frame_counts),
        "max_green_visible": max((x["green_visible"] for x in frame_counts), default=0),
        "max_red_visible": max((x["red_visible"] for x in frame_counts), default=0),
        "max_unknown_visible": max((x["unknown_visible"] for x in frame_counts), default=0),
        "max_total_visible": max((x["total_visible"] for x in frame_counts), default=0),
        "avg_green_visible": avg_green_visible,
        "avg_red_visible": avg_red_visible,
        "avg_unknown_visible": avg_unknown_visible,
    }

    chart_json = build_chart_payload(frame_counts, stats)
    recommendations = generate_recommendations(stats, players)

    result = {
        "match_id": match_id,
        "source": str(source),
        "stats": stats,
        "players": players,
        "frame_counts": frame_counts,
        "chart_json": chart_json,
        "recommendations": recommendations,
    }

    match_dir.mkdir(parents=True, exist_ok=True)

    with open(match_dir / "match_summary.json", "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    with open(match_dir / "player_metrics.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "track_id",
                "first_frame",
                "last_frame",
                "frames_detected",
                "max_frames_seen",
                "avg_conf",
                "avg_color_score",
                "green_votes",
                "red_votes",
                "unknown_votes",
                "team_label",
                "stable_player",
                "avg_box",
            ],
        )
        writer.writeheader()
        writer.writerows(players)

    with open(match_dir / "frame_counts.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "frame",
                "green_visible",
                "red_visible",
                "unknown_visible",
                "total_visible",
            ],
        )
        writer.writeheader()
        writer.writerows(frame_counts)

    return result
