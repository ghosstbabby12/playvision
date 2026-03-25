from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from ultralytics import YOLO
import cv2
import math
import shutil
import os
import uuid
from collections import defaultdict

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

model = YOLO("yolov8n.pt")

PERSON_CLASS    = 0
BALL_CLASS      = 32
NUM_PLAYERS     = 10
MIN_PRESENCE    = 0.05
BALL_RADIUS     = 80
FIELD_WIDTH_M   = 105.0   # campo estándar en metros
FPS             = 30.0
CONF_THRESHOLD  = 0.55
FRAME_SKIP      = 5


def zone_label(x, y, w, h):
    col = "Izq"    if x < w / 3 else ("Der"     if x > 2 * w / 3 else "Centro")
    row = "Ataque" if y < h / 3 else ("Defensa" if y > 2 * h / 3 else "Medio")
    return f"{row}-{col}"


@app.post("/analyze")
async def analyze_video(file: UploadFile = File(...)):
    video_path = f"uploaded_{file.filename}"

    try:
        with open(video_path, "wb") as buf:
            shutil.copyfileobj(file.file, buf)

        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            raise HTTPException(status_code=400, detail="No se pudo abrir el video")

        frame_width  = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        src_fps      = cap.get(cv2.CAP_PROP_FPS) or 30.0

        # Preparar writer para video anotado (se escribe 1 de cada FRAME_SKIP frames)
        video_id  = uuid.uuid4().hex[:8]
        out_path  = os.path.join(VIDEOS_DIR, f"annotated_{video_id}.mp4")
        out_fps   = src_fps / FRAME_SKIP
        fourcc    = cv2.VideoWriter_fourcc(*"avc1")
        writer    = cv2.VideoWriter(out_path, fourcc, out_fps, (frame_width, frame_height))
        if not writer.isOpened():
            # fallback codec
            fourcc = cv2.VideoWriter_fourcc(*"mp4v")
            writer = cv2.VideoWriter(out_path, fourcc, out_fps, (frame_width, frame_height))

        player_data = defaultdict(lambda: {
            "positions": [], "distances": [], "frames_seen": 0, "frames_with_ball": 0
        })

        frame_count     = 0
        analyzed_frames = 0

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            frame_count += 1
            if frame_count % FRAME_SKIP != 0:
                continue

            analyzed_frames += 1

            results = model.track(
                frame,
                persist=True,
                verbose=False,
                classes=[PERSON_CLASS, BALL_CLASS],
                conf=CONF_THRESHOLD,
                iou=0.5,
            )

            if not results or results[0].boxes is None:
                continue

            ball_center   = None
            frame_players = {}

            for box in results[0].boxes:
                cls  = int(box.cls[0])
                conf = float(box.conf[0])
                xyxy = box.xyxy[0].tolist()
                cx   = (xyxy[0] + xyxy[2]) / 2
                cy   = (xyxy[1] + xyxy[3]) / 2

                if cls == BALL_CLASS and conf > 0.4:
                    ball_center = (cx, cy)
                elif cls == PERSON_CLASS and box.id is not None:
                    frame_players[int(box.id[0])] = (cx, cy)

            for pid, pos in frame_players.items():
                data = player_data[pid]
                if data["positions"]:
                    data["distances"].append(math.dist(pos, data["positions"][-1]))
                data["positions"].append(pos)
                data["frames_seen"] += 1
                if ball_center and math.dist(pos, ball_center) < BALL_RADIUS:
                    data["frames_with_ball"] += 1

            # Guardar frame anotado
            annotated = results[0].plot(labels=True, conf=False, line_width=2)
            writer.write(annotated)

        cap.release()
        writer.release()

        # Filtrar jugadores reales
        min_frames = max(10, int(analyzed_frames * MIN_PRESENCE))
        stable = {pid: d for pid, d in player_data.items() if d["frames_seen"] >= min_frames}
        active = dict(
            sorted(stable.items(), key=lambda x: x[1]["frames_seen"], reverse=True)[:NUM_PLAYERS]
        )

        players_out = []
        team_total_dist = 0

        for rank, (pid, data) in enumerate(
            sorted(active.items(), key=lambda x: x[1]["frames_seen"], reverse=True), 1
        ):
            total_dist   = sum(data["distances"])
            avg_speed    = total_dist / max(len(data["distances"]), 1)
            presence_pct = data["frames_seen"] / max(analyzed_frames, 1) * 100
            poss_pct     = data["frames_with_ball"] / data["frames_seen"] * 100

            avg_x = sum(p[0] for p in data["positions"]) / len(data["positions"])
            avg_y = sum(p[1] for p in data["positions"]) / len(data["positions"])

            team_total_dist += total_dist

            # Conversión a unidades reales
            scale       = FIELD_WIDTH_M / frame_width   # m/px
            distance_m  = total_dist * scale
            distance_km = round(distance_m / 1000, 2)
            speed_ms    = round(avg_speed * scale * (FPS / FRAME_SKIP), 1)

            positions_sample = [
                {"x": round(p[0] / frame_width, 3), "y": round(p[1] / frame_height, 3)}
                for p in data["positions"][::15]
            ]
            players_out.append({
                "rank":             rank,
                "track_id":         pid,
                "zone":             zone_label(avg_x, avg_y, frame_width, frame_height),
                "presence_pct":     round(presence_pct, 1),
                "total_distance":   round(total_dist),
                "distance_km":      distance_km,
                "speed_ms":         speed_ms,
                "possession_pct":   round(poss_pct, 1),
                "avg_x_norm":       round(avg_x / frame_width, 3),
                "avg_y_norm":       round(avg_y / frame_height, 3),
                "positions_sample": positions_sample,
            })

        most_active  = max(players_out, key=lambda p: p["total_distance"], default=None)
        most_poss    = max(players_out, key=lambda p: p["possession_pct"], default=None)
        least_active = min(players_out, key=lambda p: p["total_distance"], default=None)
        team_poss    = sum(d["frames_with_ball"] for d in active.values()) / max(analyzed_frames, 1) * 100

        scale = FIELD_WIDTH_M / frame_width
        team_km = round(team_total_dist * scale / 1000, 2)

        return {
            "frames_total":     frame_count,
            "frames_analyzed":  analyzed_frames,
            "players_detected": len(active),
            "video_url":        f"http://127.0.0.1:8000/videos/annotated_{video_id}.mp4",
            "team": {
                "total_distance":    round(team_total_dist),
                "total_distance_km": team_km,
                "avg_distance_km":   round(team_km / max(len(active), 1), 2),
                "possession_pct":    round(team_poss, 1),
                "most_active":       most_active["rank"] if most_active else None,
                "least_active":      least_active["rank"] if least_active else None,
                "most_possession":   most_poss["rank"] if most_poss else None,
            },
            "players": players_out,
        }

    finally:
        if os.path.exists(video_path):
            os.remove(video_path)
