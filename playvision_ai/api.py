from fastapi import FastAPI, UploadFile, File, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from ultralytics import YOLO
from dotenv import load_dotenv
from supabase import create_client
from datetime import datetime
from pathlib import Path
from typing import Optional
import cv2
import math
import shutil
import os
import uuid
import requests
import time
from collections import defaultdict

# --- CORRECCIÓN DE VARIABLES DE ENTORNO ---
# Obtenemos la ruta absoluta de la carpeta donde está este archivo (api.py)
BASE_DIR = Path(__file__).resolve().parent
env_path = BASE_DIR / ".env"

# Forzamos a que dotenv lea exactamente esa ruta y sobreescriba variables
load_dotenv(dotenv_path=env_path, override=True)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_KEY")  # Usa service_role para bypass RLS

if not SUPABASE_URL or not SUPABASE_KEY:
    raise RuntimeError(f"Faltan credenciales de Supabase. Buscando en: {env_path}")

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
# ------------------------------------------

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
NUM_PLAYERS     = int(os.getenv("NUM_PLAYERS", "10"))
MIN_PRESENCE    = float(os.getenv("MIN_PRESENCE", "0.05"))
BALL_RADIUS     = int(os.getenv("BALL_RADIUS", "80"))
FIELD_WIDTH_M   = float(os.getenv("FIELD_WIDTH_M", "105.0"))
FPS             = float(os.getenv("FPS", "30.0"))
CONF_THRESHOLD  = float(os.getenv("CONF_THRESHOLD", "0.55"))
FRAME_SKIP      = int(os.getenv("FRAME_SKIP", "5"))

# ==========================================
# VARIABLES PARA API DE PARTIDOS EN VIVO
# ==========================================
API_KEY_SPORTS = "5b04f6e82ecd9629ff7b1a495bab699e"
HEADERS_SPORTS = {
    "x-apisports-key": API_KEY_SPORTS 
}
cache_partidos = None
ultimo_llamado_partidos = 0
TIEMPO_CACHE_PARTIDOS = 60 # Actualiza cada minuto

def zone_label(x, y, w, h):
    col = "Izq"    if x < w / 3 else ("Der"     if x > 2 * w / 3 else "Centro")
    row = "Ataque" if y < h / 3 else ("Defensa" if y > 2 * h / 3 else "Medio")
    return f"{row}-{col}"

def create_or_update_match(team_id: int, match_id: Optional[int], opponent: str, source_type: str, video_url: str):
    data = {
        "team_id": team_id,
        "opponent": opponent,
        "source_type": source_type,
        "video_url": video_url,
        "status": "uploaded",
        "updated_at": datetime.utcnow().isoformat(),
    }

    if match_id:
        result = supabase.table("matches").update(data).eq("id", match_id).execute()
        return match_id

    data["match_date"] = datetime.utcnow().isoformat()
    data["created_at"] = datetime.utcnow().isoformat()
    result = supabase.table("matches").insert(data).execute()
    return result.data[0]["id"] if result.data and len(result.data) > 0 else None

def create_player_stat(match_id: int, track_id: int, stats: dict):
    insert_data = {
        "match_id": match_id,
        "player_id": None, # Queda nulo por ahora hasta que asignes un jugador real
        "track_id": track_id, # Añadido track_id explícitamente para asegurar compatibilidad
        "distance": stats.get("distance_km"),
        "velocity": stats.get("speed_ms"),
        "possession": stats.get("possession_pct"),
        "presence": stats.get("presence_pct"), 
        "zone": stats.get("zone"),
        "created_at": datetime.utcnow().isoformat(),
        "updated_at": datetime.utcnow().isoformat(),
    }
    
    supabase.table("player_match_stats").insert(insert_data).execute()

def save_match_report(match_id: int, team_id: int, payload: dict):
    report = {
        "match_id": match_id,
        "summary_json": payload,
        "created_at": datetime.utcnow().isoformat(),
        "updated_at": datetime.utcnow().isoformat(),
    }
    
    supabase.table("match_reports").insert(report).execute()

@app.post("/analyze")
async def analyze_video(
    team_id: str = Form(...), # Recibimos como texto desde Flutter Web
    match_id: str = Form(None), # Recibimos como texto opcional
    opponent: str = Form(""),
    source_type: str = Form("upload"),
    file: UploadFile = File(...),
):
    # Convertimos a entero internamente de forma segura
    team_id_int = int(team_id)
    match_id_int = int(match_id) if match_id and match_id != "null" else None

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

        video_id  = uuid.uuid4().hex[:8]
        out_path  = os.path.join(VIDEOS_DIR, f"annotated_{video_id}.mp4")
        out_fps   = src_fps / FRAME_SKIP
        
        # CORRECCIÓN DE CODEC: Usar mp4v es mucho más estable en Windows que avc1 (h264)
        fourcc    = cv2.VideoWriter_fourcc(*"mp4v")
        writer    = cv2.VideoWriter(out_path, fourcc, out_fps, (frame_width, frame_height))
        
        if not writer.isOpened():
            # Plan de respaldo si mp4v falla: probar XVID (genera un .avi, pero lo guardamos como mp4)
            fourcc = cv2.VideoWriter_fourcc(*"XVID")
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

            annotated = results[0].plot(labels=True, conf=False, line_width=2)
            writer.write(annotated)

        cap.release()
        writer.release()

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

            scale       = FIELD_WIDTH_M / frame_width
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

        video_url = f"{os.getenv('API_HOST', 'http://127.0.0.1')}:{os.getenv('API_PORT', '8000')}/videos/annotated_{video_id}.mp4"

        result_payload = {
            "frames_total":     frame_count,
            "frames_analyzed":  analyzed_frames,
            "players_detected": len(active),
            "video_url":        video_url,
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

        # CORRECCIÓN DE LA LÓGICA DE PARTIDO: Usar los INT en lugar de los STR originales
        persisted_match_id = match_id_int

        if persisted_match_id is None:
            persisted_match_id = create_or_update_match(
                team_id=team_id_int,
                match_id=None,
                opponent=opponent,
                source_type=source_type,
                video_url=video_url,
            )
        else:
            # Si ya existía, al menos le actualizamos el video_url para que apunte al nuevo
            create_or_update_match(
                team_id=team_id_int,
                match_id=persisted_match_id,
                opponent=opponent,
                source_type=source_type,
                video_url=video_url,
            )

        if persisted_match_id is not None:
            # Guardado general del reporte en JSON usando el INT
            save_match_report(persisted_match_id, team_id_int, result_payload)

        return result_payload

    finally:
        if os.path.exists(video_path):
            os.remove(video_path)


# ==========================================
# NUEVO ENDPOINT: OBTENER PARTIDOS EN VIVO/HOY
# ==========================================
@app.get("/api/live-matches")
def obtener_partidos_hoy():
    global cache_partidos, ultimo_llamado_partidos
    tiempo_actual = time.time()
    
    # Usa caché si no ha pasado 1 minuto para no agotar tus peticiones
    if cache_partidos and (tiempo_actual - ultimo_llamado_partidos < TIEMPO_CACHE_PARTIDOS):
        return {"origen": "cache", "data": cache_partidos}
        
    # Obtener fecha actual en formato YYYY-MM-DD
    fecha_hoy = datetime.now().strftime("%Y-%m-%d")
    
    # URL para traer TODOS los partidos del día (ya jugados, en vivo y programados)
    url = f"https://v3.football.api-sports.io/fixtures?date={fecha_hoy}"
    
    try:
        response = requests.get(url, headers=HEADERS_SPORTS)
        datos = response.json()
        
        if "errors" in datos and datos["errors"]:
            return {"error": datos["errors"]}
            
        cache_partidos = datos.get("response", [])
        ultimo_llamado_partidos = tiempo_actual
        
        return {"origen": "api", "data": cache_partidos}
    except Exception as e:
        return {"error": str(e)}