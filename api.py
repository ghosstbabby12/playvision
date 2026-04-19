"""
api.py — FastAPI entry-point.  Thin orchestration layer only.
All heavy logic lives in the analysis/ package.
"""
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.responses import Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv
from pathlib import Path
from typing import Optional
import cv2
import os
import shutil
import time
import uuid
import requests
from datetime import datetime

# ── Load env BEFORE importing analysis modules (they read os.getenv) ─────────
BASE_DIR = Path(__file__).resolve().parent
load_dotenv(dotenv_path=BASE_DIR / ".env", override=True)

from analysis.detector        import detect_frame
from analysis.tracker         import PlayerTracker
from analysis.metrics_engine  import compute_metrics
from analysis.exporter        import create_or_update_match, save_match_report, save_player_stats, upload_video, get_match_players
from analysis.heatmap_engine  import heatmap_from_positions_sample, encode_heatmap_png
from analysis.video_heatmap   import VideoHeatmapOverlay, overlay_positions_on_frame
from analysis.team_classifier  import TeamClassifier
from analysis.ar_renderer      import render_frame as ar_render
from analysis.detector         import reset_state as reset_detector
from analysis.ball_tracker     import BallTracker
from analysis.possession_engine import PossessionEngine
from analysis.pass_detector    import PassLog
from analysis.commentary_engine import CommentaryEngine

# ── Config ────────────────────────────────────────────────────────────────────
NUM_PLAYERS    = int(os.getenv("NUM_PLAYERS",   "22"))
MIN_PRESENCE   = float(os.getenv("MIN_PRESENCE", "0.01"))
BALL_RADIUS    = int(os.getenv("BALL_RADIUS",   "80"))
FIELD_WIDTH_M  = float(os.getenv("FIELD_WIDTH_M","105.0"))
FPS            = float(os.getenv("FPS",          "30.0"))
CONF_THRESHOLD = float(os.getenv("CONF_THRESHOLD","0.35"))
FRAME_SKIP     = int(os.getenv("FRAME_SKIP",    "2"))   

TARGET_WIDTH   = 1280

# ── Live-match cache ──────────────────────────────────────────────────────────
_API_KEY_SPORTS       = "5b04f6e82ecd9629ff7b1a495bab699e"
_HEADERS_SPORTS       = {"x-apisports-key": _API_KEY_SPORTS}
_cache_partidos       = None
_ultimo_llamado       = 0
_CACHE_TTL_SECONDS    = 60

# ── App setup ─────────────────────────────────────────────────────────────────
app = FastAPI(title="PlayVision AI")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class CORSMiddlewareStaticFiles(StaticFiles):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    async def get_response(self, path: str, scope):
        response = await super().get_response(path, scope)
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
        response.headers["Access-Control-Allow-Headers"] = "Range, Content-Type, Authorization"
        response.headers["Access-Control-Expose-Headers"] = "Content-Length, Content-Range"
        return response

VIDEOS_DIR = os.path.join(BASE_DIR, "annotated_videos")
os.makedirs(VIDEOS_DIR, exist_ok=True)

app.mount("/videos", CORSMiddlewareStaticFiles(directory=str(VIDEOS_DIR)), name="videos")

# ── Helpers ───────────────────────────────────────────────────────────────────
def _resize_frame(frame, target_width: int):
    h, w = frame.shape[:2]
    if w <= target_width:
        return frame
    scale  = target_width / w
    new_h  = int(h * scale)
    return cv2.resize(frame, (target_width, new_h), interpolation=cv2.INTER_LINEAR)

def _open_writer(out_path: str, fps: float, width: int, height: int):
    # 1. Intentar 'avc1' (H.264), el codec que Chrome soporta perfectamente
    fourcc = cv2.VideoWriter_fourcc(*'avc1')
    writer = cv2.VideoWriter(out_path, fourcc, fps, (width, height))
    if writer.isOpened():
        return writer
        
    # 2. Fallback a 'mp4v' si avc1 falla en este sistema
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    writer = cv2.VideoWriter(out_path, fourcc, fps, (width, height))
    if writer.isOpened():
        return writer

    raise RuntimeError("Could not open VideoWriter with any codec")

# ── Shared pipeline ───────────────────────────────────────────────────────────
def _run_pipeline(
    video_path:   str,
    team_id_int:  int,
    match_id_int: Optional[int],
    opponent:     str,
    source_type:  str,
) -> dict:
    """Process a video file through the full detection → metrics → upload pipeline."""
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise HTTPException(status_code=400, detail="Cannot open video file")

    src_w   = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    src_h   = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    src_fps = cap.get(cv2.CAP_PROP_FPS) or FPS

    scale_r = min(1.0, TARGET_WIDTH / src_w)
    out_w   = int(src_w * scale_r)
    out_h   = int(src_h * scale_r)
    out_fps = src_fps / FRAME_SKIP

    video_id    = uuid.uuid4().hex[:8]
    out_path    = os.path.join(VIDEOS_DIR, f"annotated_{video_id}.mp4")
    heat_path   = os.path.join(VIDEOS_DIR, f"heatmap_{video_id}.mp4")
    writer      = _open_writer(out_path,  out_fps, out_w, out_h)
    heat_writer = _open_writer(heat_path, out_fps, out_w, out_h)

    reset_detector()   # clear smoothing history from previous video
    tracker         = PlayerTracker(ball_radius=BALL_RADIUS)
    heat_overlay    = VideoHeatmapOverlay(width=out_w, height=out_h)
    team_classifier = TeamClassifier()
    ball_tracker    = BallTracker()
    possession      = PossessionEngine()
    pass_log        = PassLog()
    commentary      = CommentaryEngine(out_w, out_h)
    frame_count     = 0
    analyzed        = 0
    prev_owner: int | None = None
    id_map: dict[int, int] = {}
    _next_id = [0]
    frame_data: list[tuple[int, dict]] = []  # (frame_count, frame_players) for per-player heatmaps

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        frame_count += 1
        if frame_count % FRAME_SKIP != 0:
            continue

        frame = _resize_frame(frame, TARGET_WIDTH)
        frame_players, ball_detected, raw_result = detect_frame(
            frame, conf_threshold=CONF_THRESHOLD
        )
        frame_data.append((frame_count, dict(frame_players)))
        team_classifier.update(frame, raw_result)

        # ── Assign stable display numbers (1…N) to new track IDs ─────────────
        for pid in frame_players:
            if pid not in id_map:
                _next_id[0] += 1
                id_map[pid] = _next_id[0]

        # ── Ball: stabilize raw detection, fall back to last known ───────────
        ball_center = ball_tracker.update(ball_detected)
        # For possession we extend persistence using last_known so the
        # engine never runs fully blind even when YOLO misses the ball.
        ball_for_possession = ball_center or ball_tracker.last_known

        # ── Tracker (uses detected ball for possession-frame counting) ────────
        tracker.update(frame_players, ball_for_possession)

        # ── Possession & pass detection ──────────────────────────────────────
        pass_log.tick()
        pass_log.update_positions(frame_players)

        current_owner = possession.update(frame_players, ball_for_possession)

        if (prev_owner is not None
                and current_owner is not None
                and current_owner != prev_owner):
            pass_log.try_register(prev_owner, current_owner, team_classifier, frame_count)

        prev_owner = current_owner

        # ── Commentary (every 30 analyzed frames) ────────────────────────────
        if analyzed % 30 == 0:
            commentary.update(frame_count, frame_players, ball_center,
                              pass_log.all_passes, team_classifier)
            ball_str = f"({int(ball_center[0])},{int(ball_center[1])})" if ball_center else "none"
            print(f"[debug] frame={frame_count} players={len(frame_players)} "
                  f"ball={ball_str} passes={pass_log.total} owner={current_owner}")

        # ── AR overlay ───────────────────────────────────────────────────────
        ar_frame = ar_render(
            frame, frame_players, ball_center,
            pass_log.recent, current_owner,
            team_classifier, commentary.latest,
            total_passes=pass_log.total,
            id_map=id_map,
        )
        writer.write(ar_frame)

        # ── Heatmap overlay ───────────────────────────────────────────────────
        heat_overlay.update(frame_players)
        heat_writer.write(heat_overlay.apply(frame))
        analyzed += 1

    cap.release()
    writer.release()
    heat_writer.release()

    # ── Diagnostics ──────────────────────────────────────────────────────────
    track_entries = {pid: d["frames_seen"] for pid, d in tracker.data.items()}
    min_f         = max(1, int(analyzed * MIN_PRESENCE))
    stable_ids    = [pid for pid, fs in track_entries.items() if fs >= min_f]
    print(f"[debug] done | analyzed={analyzed} | tracked_ids={len(track_entries)} "
          f"| min_frames={min_f} | stable={len(stable_ids)} | passes={pass_log.total}")
    if track_entries:
        top5 = sorted(track_entries.items(), key=lambda x: x[1], reverse=True)[:5]
        print(f"[debug] top players frames_seen: {top5}")

    players_out, team_stats = compute_metrics(
        player_data    = tracker.data,
        analyzed_frames= analyzed,
        frame_width    = out_w,
        frame_height   = out_h,
        field_width_m  = FIELD_WIDTH_M,
        fps            = src_fps,
        frame_skip     = FRAME_SKIP,
        num_players    = NUM_PLAYERS,
        min_presence   = MIN_PRESENCE,
    )

    # ── Per-player heatmap videos (second pass — no YOLO, just overlay) ─────────
    fd_lookup = {fc: fp for fc, fp in frame_data}
    p_overlays: dict[int, VideoHeatmapOverlay] = {}
    p_writers:  dict[int, cv2.VideoWriter]     = {}
    p_paths:    dict[int, str]                 = {}

    for p in players_out:
        pid  = p["track_id"]
        rank = p["rank"]
        path = os.path.join(VIDEOS_DIR, f"heat_p{rank}_{video_id}.mp4")
        p_paths[pid]    = path
        p_overlays[pid] = VideoHeatmapOverlay(width=out_w, height=out_h)
        p_writers[pid]  = _open_writer(path, out_fps, out_w, out_h)

    cap2 = cv2.VideoCapture(video_path)
    fc2  = 0
    while cap2.isOpened():
        ret, frame = cap2.read()
        if not ret:
            break
        fc2 += 1
        if fc2 % FRAME_SKIP != 0:
            continue
        frame    = _resize_frame(frame, TARGET_WIDTH)
        fplayers = fd_lookup.get(fc2, {})
        for pid in p_paths:
            single = {pid: fplayers[pid]} if pid in fplayers else {}
            p_overlays[pid].update(single)
            p_writers[pid].write(p_overlays[pid].apply(frame))
    cap2.release()
    for pid in p_paths:
        p_writers[pid].release()
    print(f"[debug] per-player heatmap videos generated: {len(p_paths)}")

    base_url = (
        f"{os.getenv('API_HOST', 'http://127.0.0.1')}:"
        f"{os.getenv('API_PORT', '8000')}/videos"
    )
    ann_file  = f"annotated_{video_id}.mp4"
    heat_file = f"heatmap_{video_id}.mp4"

    storage_url      = upload_video(out_path,  ann_file)
    heat_storage_url = upload_video(heat_path, heat_file)

    # Upload per-player heatmap videos and attach URL to each player
    for p in players_out:
        pid   = p["track_id"]
        rank  = p["rank"]
        fname = f"heat_p{rank}_{video_id}.mp4"
        url   = upload_video(p_paths[pid], fname) if pid in p_paths else None
        p["heatmap_video_url"] = url or f"{base_url}/{fname}"

    video_url      = storage_url      or f"{base_url}/{ann_file}"
    heat_video_url = heat_storage_url or f"{base_url}/{heat_file}"

    result_payload = {
        "frames_total":      frame_count,
        "frames_analyzed":   analyzed,
        "players_detected":  len(players_out),
        "pass_count":        pass_log.total,
        "video_url":         video_url,
        "heatmap_video_url": heat_video_url,
        "team":              team_stats,
        "players":           players_out,
    }

    try:
        if match_id_int is None:
            match_id_int = create_or_update_match(
                team_id=team_id_int, match_id=None,
                opponent=opponent, source_type=source_type,
                video_url=video_url,
            )
        else:
            create_or_update_match(
                team_id=team_id_int, match_id=match_id_int,
                opponent=opponent, source_type=source_type,
                video_url=video_url,
            )
        if match_id_int is not None:
            save_match_report(match_id_int, team_id_int, result_payload)
            try:
                save_player_stats(match_id_int, players_out)
            except Exception as e:
                print(f"[warn] player stats insert skipped: {e}")
    except Exception as e:
        print(f"[warn] Supabase persist failed: {e}")

    return result_payload


# ── /analyze — upload a local file ───────────────────────────────────────────
@app.post("/analyze")
async def analyze_video(
    team_id:     str           = Form(...),
    match_id:    Optional[str] = Form(None),
    opponent:    str           = Form(""),
    source_type: str           = Form("upload"),
    file:        UploadFile    = File(...),
):
    team_id_int  = int(team_id)
    match_id_int = int(match_id) if match_id and match_id not in ("null", "") else None
    video_path   = os.path.join(BASE_DIR, f"uploaded_{uuid.uuid4().hex[:8]}_{file.filename}")
    try:
        with open(video_path, "wb") as buf:
            shutil.copyfileobj(file.file, buf)
        return _run_pipeline(video_path, team_id_int, match_id_int, opponent, source_type)
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        print(f"[error] /analyze failed: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if os.path.exists(video_path):
            os.remove(video_path)


# ── URL helpers ───────────────────────────────────────────────────────────────
_PLATFORM_PATTERNS = (
    "youtube.com", "youtu.be",
    "vimeo.com", "dailymotion.com",
    "twitch.tv", "instagram.com",
    "twitter.com", "x.com", "tiktok.com",
    "facebook.com", "fb.watch",
)

def _is_platform_url(url: str) -> bool:
    return any(p in url for p in _PLATFORM_PATTERNS)

def _download_with_ytdlp(url: str, out_path: str) -> None:
    try:
        import yt_dlp
    except ImportError:
        raise HTTPException(status_code=500, detail="yt-dlp not installed. Run: pip install yt-dlp")

    ydl_opts = {
        # Single-file format — no merge needed, no ffmpeg required
        "format": "best[ext=mp4][height<=720]/best[ext=mp4]/best",
        "outtmpl": out_path,
        "quiet": True,
        "no_warnings": True,
    }
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=True)
        # yt-dlp may append extension; rename if needed
        expected = ydl.prepare_filename(info)
        if expected != out_path and os.path.exists(expected):
            os.rename(expected, out_path)

def _download_direct(url: str, out_path: str) -> None:
    try:
        resp = requests.get(url, stream=True, timeout=120,
                            headers={"User-Agent": "Mozilla/5.0"})
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Could not reach URL: {e}")
    if resp.status_code != 200:
        raise HTTPException(status_code=400, detail=f"Could not download video: HTTP {resp.status_code}")
    with open(out_path, "wb") as f:
        for chunk in resp.iter_content(chunk_size=1024 * 1024):
            f.write(chunk)


# ── /analyze-url — analyze a video from a remote URL ─────────────────────────
@app.post("/analyze-url")
async def analyze_video_url(
    team_id:     str           = Form(...),
    match_id:    Optional[str] = Form(None),
    opponent:    str           = Form(""),
    source_type: str           = Form("url"),
    video_url:   str           = Form(...),
):
    team_id_int  = int(team_id)
    match_id_int = int(match_id) if match_id and match_id not in ("null", "") else None

    video_path = os.path.join(BASE_DIR, f"remote_{uuid.uuid4().hex[:8]}.mp4")
    try:
        if _is_platform_url(video_url):
            print(f"[info] Platform URL — yt-dlp: {video_url}")
            _download_with_ytdlp(video_url, video_path)
        else:
            print(f"[info] Direct URL — streaming: {video_url}")
            _download_direct(video_url, video_path)

        if not os.path.exists(video_path) or os.path.getsize(video_path) < 1024:
            raise HTTPException(status_code=400, detail="Downloaded file is empty or missing")

        return _run_pipeline(video_path, team_id_int, match_id_int, opponent, source_type)

    except HTTPException:
        raise   # let FastAPI handle these cleanly
    except Exception as e:
        import traceback
        print(f"[error] /analyze-url failed: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if os.path.exists(video_path):
            os.remove(video_path)

@app.post("/heatmap")
async def generate_heatmap(
    players_json: str = Form(...),   # JSON string: list of player dicts
    player_rank:  str = Form(None),  # optional: "3" to filter one player
    mode:         str = Form("team"), # "team" | "player"
):
    """
    Generate a tactical heatmap PNG from positions_sample data.

    Accepts the `players` array from the /analyze response.
    Returns a PNG image directly (Content-Type: image/png).
    """
    import json
    try:
        players = json.loads(players_json)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid players_json")

    rank = int(player_rank) if player_rank and player_rank.isdigit() else None
    image = heatmap_from_positions_sample(players, selected_rank=rank)
    return Response(content=encode_heatmap_png(image), media_type="image/png")


@app.get("/heatmap/{match_id}")
def heatmap_by_match(match_id: int, player_rank: Optional[int] = None):
    """
    Generate heatmap PNG for a match stored in Supabase.
    - No player_rank → heatmap de todo el equipo
    - player_rank=3   → solo el jugador #3
    """
    players = get_match_players(match_id)
    if not players:
        raise HTTPException(status_code=404, detail="Match not found or no player data")
    image = heatmap_from_positions_sample(players, selected_rank=player_rank)
    return Response(content=encode_heatmap_png(image), media_type="image/png")


@app.get("/heatmap/{match_id}/overlay")
def heatmap_overlay_by_player(match_id: int, player_rank: Optional[int] = None):
    """
    Genera un heatmap estilo video (overlay sobre campo) filtrado por jugador.
    - player_rank omitido → todos los jugadores
    - player_rank=2       → solo jugador #2
    Devuelve PNG.
    """
    CANVAS_W, CANVAS_H = 1050, 680

    players = get_match_players(match_id)
    if not players:
        raise HTTPException(status_code=404, detail="Match not found or no player data")

    positions: list[tuple[float, float]] = []
    for p in players:
        if player_rank is not None and p.get("rank") != player_rank:
            continue
        for pos in p.get("positions_sample", []):
            positions.append((pos["x"] * CANVAS_W, pos["y"] * CANVAS_H))

    # Campo verde sintético como base
    from analysis.heatmap_engine import draw_pitch
    base = draw_pitch(CANVAS_W, CANVAS_H)
    result = overlay_positions_on_frame(base, positions)
    return Response(content=encode_heatmap_png(result), media_type="image/png")


@app.get("/heatmap/{match_id}/players")
def list_match_players(match_id: int):
    """Returns the list of players (rank, zone, distance, speed) for a match."""
    players = get_match_players(match_id)
    if not players:
        raise HTTPException(status_code=404, detail="Match not found or no player data")
    return [
        {
            "rank":           p["rank"],
            "track_id":       p["track_id"],
            "zone":           p["zone"],
            "distance_km":    p["distance_km"],
            "speed_kmh":      p["speed_kmh"],
            "possession_pct": p["possession_pct"],
            "presence_pct":   p["presence_pct"],
        }
        for p in players
    ]


@app.get("/api/live-matches")
def live_matches():
    global _cache_partidos, _ultimo_llamado

    if _cache_partidos and (time.time() - _ultimo_llamado < _CACHE_TTL_SECONDS):
        return {"origin": "cache", "data": _cache_partidos}

    fecha = datetime.now().strftime("%Y-%m-%d")
    url   = f"https://v3.football.api-sports.io/fixtures?date={fecha}"

    try:
        resp  = requests.get(url, headers=_HEADERS_SPORTS, timeout=10)
        datos = resp.json()

        if datos.get("errors"):
            return {"error": datos["errors"]}

        _cache_partidos  = datos.get("response", [])
        _ultimo_llamado  = time.time()
        return {"origin": "api", "data": _cache_partidos}

    except Exception as e:
        return {"error": str(e)}