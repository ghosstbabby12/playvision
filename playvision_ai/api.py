"""
api.py — FastAPI entry-point.  Thin orchestration layer only.
All heavy logic lives in the analysis/ package.
"""
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
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

from analysis.detector      import detect_frame
from analysis.tracker       import PlayerTracker
from analysis.metrics_engine import compute_metrics
from analysis.exporter      import create_or_update_match, save_match_report, save_player_stats

# ── Config ────────────────────────────────────────────────────────────────────
NUM_PLAYERS    = int(os.getenv("NUM_PLAYERS",   "10"))
MIN_PRESENCE   = float(os.getenv("MIN_PRESENCE", "0.05"))
BALL_RADIUS    = int(os.getenv("BALL_RADIUS",   "80"))
FIELD_WIDTH_M  = float(os.getenv("FIELD_WIDTH_M","105.0"))
FPS            = float(os.getenv("FPS",          "30.0"))
CONF_THRESHOLD = float(os.getenv("CONF_THRESHOLD","0.55"))
FRAME_SKIP     = int(os.getenv("FRAME_SKIP",    "3"))   # default 3 (was 5) for better metrics

TARGET_WIDTH   = 1280   # resize to 720p-wide for speed (keeps aspect ratio)

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

VIDEOS_DIR = "annotated_videos"
os.makedirs(VIDEOS_DIR, exist_ok=True)
app.mount("/videos", StaticFiles(directory=VIDEOS_DIR), name="videos")


# ── Helpers ───────────────────────────────────────────────────────────────────
def _resize_frame(frame, target_width: int):
    h, w = frame.shape[:2]
    if w <= target_width:
        return frame
    scale  = target_width / w
    new_h  = int(h * scale)
    return cv2.resize(frame, (target_width, new_h), interpolation=cv2.INTER_LINEAR)


def _open_writer(out_path: str, fps: float, width: int, height: int):
    for fourcc_str in ("mp4v", "XVID"):
        fourcc = cv2.VideoWriter_fourcc(*fourcc_str)
        writer = cv2.VideoWriter(out_path, fourcc, fps, (width, height))
        if writer.isOpened():
            return writer
    raise RuntimeError("Could not open VideoWriter with any codec")


# ── /analyze endpoint ─────────────────────────────────────────────────────────
@app.post("/analyze")
async def analyze_video(
    team_id:     str            = Form(...),
    match_id:    Optional[str]  = Form(None),
    opponent:    str            = Form(""),
    source_type: str            = Form("upload"),
    file:        UploadFile     = File(...),
):
    team_id_int  = int(team_id)
    match_id_int = int(match_id) if match_id and match_id not in ("null", "") else None

    video_path = f"uploaded_{uuid.uuid4().hex[:8]}_{file.filename}"

    try:
        # 1. Save upload ──────────────────────────────────────────────────────
        with open(video_path, "wb") as buf:
            shutil.copyfileobj(file.file, buf)

        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            raise HTTPException(status_code=400, detail="Cannot open video file")

        src_w   = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        src_h   = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        src_fps = cap.get(cv2.CAP_PROP_FPS) or FPS

        # Compute output dimensions (720p resize)
        scale_r  = min(1.0, TARGET_WIDTH / src_w)
        out_w    = int(src_w * scale_r)
        out_h    = int(src_h * scale_r)
        out_fps  = src_fps / FRAME_SKIP

        video_id = uuid.uuid4().hex[:8]
        out_path = os.path.join(VIDEOS_DIR, f"annotated_{video_id}.mp4")
        writer   = _open_writer(out_path, out_fps, out_w, out_h)

        # 2. Process frames ───────────────────────────────────────────────────
        tracker     = PlayerTracker(ball_radius=BALL_RADIUS)
        frame_count = 0
        analyzed    = 0

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            frame_count += 1
            if frame_count % FRAME_SKIP != 0:
                continue

            # Resize for speed
            frame = _resize_frame(frame, TARGET_WIDTH)

            frame_players, ball_center, raw_result = detect_frame(
                frame, conf_threshold=CONF_THRESHOLD
            )
            tracker.update(frame_players, ball_center)

            if raw_result is not None:
                annotated = raw_result.plot(labels=True, conf=False, line_width=2)
                annotated = _resize_frame(annotated, TARGET_WIDTH)
                writer.write(annotated)

            analyzed += 1

        cap.release()
        writer.release()

        # 3. Compute metrics ──────────────────────────────────────────────────
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

        # 4. Build response ────────────────────────────────────────────────────
        video_url = (
            f"{os.getenv('API_HOST', 'http://127.0.0.1')}:"
            f"{os.getenv('API_PORT', '8000')}"
            f"/videos/annotated_{video_id}.mp4"
        )

        result_payload = {
            "frames_total":     frame_count,
            "frames_analyzed":  analyzed,
            "players_detected": len(players_out),
            "video_url":        video_url,
            "team":             team_stats,
            "players":          players_out,
        }

        # 5. Persist to Supabase ──────────────────────────────────────────────
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

    finally:
        if os.path.exists(video_path):
            os.remove(video_path)


# ── /api/live-matches endpoint ────────────────────────────────────────────────
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
