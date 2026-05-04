from ultralytics import YOLO
import cv2
import math
from collections import defaultdict
from datetime import datetime

TEAM_GREEN_CLASS = 0
TEAM_RED_CLASS   = 1
PLAYER_CLASSES   = {TEAM_GREEN_CLASS, TEAM_RED_CLASS}
NUM_PLAYERS = 10          # ← cambia este número según los jugadores reales del video
MIN_PRESENCE = 0.05       # 5% — útil para videos cortos (YouTube Shorts, clips)
CONF_THRESHOLD = 0.45     # más bajo para detectar más jugadores

model = YOLO("models/best.pt")

cap = cv2.VideoCapture("entreno2.mp4")
frame_width  = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

player_data = defaultdict(lambda: {
    'positions': [],
    'distances': [],
    'frames_seen': 0,
    'team': 'desconocido',
})

frame_count    = 0
analyzed_frames = 0

try:
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        frame_count += 1
        if frame_count % 5 != 0:
            continue

        analyzed_frames += 1

        results = model.track(
            frame,
            persist=True,
            verbose=False,
            classes=list(PLAYER_CLASSES),
            conf=CONF_THRESHOLD,
            iou=0.5,
        )

        if not results or results[0].boxes is None:
            continue

        frame_players = {}

        for box in results[0].boxes:
            cls  = int(box.cls[0])
            xyxy = box.xyxy[0].tolist()
            cx   = (xyxy[0] + xyxy[2]) / 2
            cy   = (xyxy[1] + xyxy[3]) / 2

            if cls in PLAYER_CLASSES and box.id is not None:
                pid  = int(box.id[0])
                team = "green" if cls == TEAM_GREEN_CLASS else "red"
                frame_players[pid] = ((cx, cy), team)

        for pid, (pos, team) in frame_players.items():
            data = player_data[pid]

            if data['positions']:
                dist = math.dist(pos, data['positions'][-1])
                data['distances'].append(dist)

            data['positions'].append(pos)
            data['frames_seen'] += 1
            data['team'] = team

        annotated = results[0].plot(labels=True, conf=True, line_width=2)
        cv2.imshow("PlayVision AI", annotated)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

except KeyboardInterrupt:
    pass

finally:
    cap.release()
    cv2.destroyAllWindows()


# ── Filtrado: solo jugadores reales ──────────────────────────
min_frames_required = max(10, int(analyzed_frames * MIN_PRESENCE))

# 1. Filtrar por presencia mínima
stable = {pid: d for pid, d in player_data.items()
          if d['frames_seen'] >= min_frames_required}

# 2. Tomar solo los NUM_PLAYERS más estables (mayor frames_seen)
active = dict(
    sorted(stable.items(), key=lambda x: x[1]['frames_seen'], reverse=True)[:NUM_PLAYERS]
)


# ── Informe ───────────────────────────────────────────────────
def zone_label(x, y):
    col = 'Izq'    if x < frame_width  / 3 else ('Der'     if x > 2 * frame_width  / 3 else 'Centro')
    row = 'Ataque' if y < frame_height / 3 else ('Defensa' if y > 2 * frame_height / 3 else 'Medio')
    return f"{row}-{col}"


lines = []
lines.append("=" * 60)
lines.append("   INFORME DE ANÁLISIS — PlayVision AI")
lines.append(f"   {datetime.now().strftime('%d/%m/%Y  %H:%M')}")
lines.append("=" * 60)
lines.append(f"\nFrames totales          : {frame_count}")
lines.append(f"Frames analizados       : {analyzed_frames}")
lines.append(f"Tracks detectados total : {len(player_data)}")
lines.append(f"Jugadores válidos       : {len(active)}  (mín. {min_frames_required} frames de presencia)")

lines.append("\n" + "-" * 60)
lines.append("ANÁLISIS POR JUGADOR")
lines.append("-" * 60)

team_total_dist = 0

player_rows = []

for pid, data in active.items():
    total_dist   = sum(data['distances'])
    avg_speed    = total_dist / max(len(data['distances']), 1)
    presence_pct = data['frames_seen'] / analyzed_frames * 100

    avg_x = sum(p[0] for p in data['positions']) / len(data['positions'])
    avg_y = sum(p[1] for p in data['positions']) / len(data['positions'])
    zone  = zone_label(avg_x, avg_y)

    team_total_dist += total_dist

    team_name = data.get('team', 'desconocido')
    player_rows.append((pid, data['frames_seen'], total_dist, avg_speed, presence_pct, zone, team_name))

# Ordenar por frames vistos (más presente primero)
player_rows.sort(key=lambda r: r[1], reverse=True)

for idx, (pid, frames, dist, speed, presence, zone, team_name) in enumerate(player_rows, 1):
    lines.append(f"\n  Jugador {idx:>2}  (track #{pid})")
    lines.append(f"    Equipo             : {'Verde' if team_name == 'green' else 'Rojo' if team_name == 'red' else 'Desconocido'}")
    lines.append(f"    Zona predominante  : {zone}")
    lines.append(f"    Presencia en campo : {presence:.0f}%  ({frames} frames)")
    lines.append(f"    Distancia recorrida: {dist:,.0f} px")
    lines.append(f"    Velocidad media    : {speed:.1f} px/frame")

lines.append("\n" + "=" * 60)
lines.append("ANÁLISIS DEL EQUIPO")
lines.append("=" * 60)

if active:
    avg_dist = team_total_dist / len(active)

    most_active_row  = max(player_rows, key=lambda r: r[2])
    least_active_row = min(player_rows, key=lambda r: r[2])
    most_present_row = max(player_rows, key=lambda r: r[1])

    zones = set()
    for pid, data in active.items():
        for pos in data['positions'][::10]:
            zones.add(zone_label(pos[0], pos[1]))

    green_players = [(pid, d) for pid, d in active.items() if d.get('team') == 'green']
    red_players   = [(pid, d) for pid, d in active.items() if d.get('team') == 'red']

    lines.append(f"\n  Jugadores en informe   : {len(active)}")
    lines.append(f"  Jugadores equipo verde : {len(green_players)}")
    lines.append(f"  Jugadores equipo rojo  : {len(red_players)}")
    lines.append(f"  Distancia total equipo : {team_total_dist:,.0f} px")
    lines.append(f"  Distancia media/jugador: {avg_dist:,.0f} px")
    lines.append(f"  Zonas del campo cubiert: {len(zones)} / 9")
    lines.append(f"  Jugador más activo     : Jugador {player_rows.index(most_active_row)+1}  (track #{most_active_row[0]})")
    lines.append(f"  Jugador menos activo   : Jugador {player_rows.index(least_active_row)+1}  (track #{least_active_row[0]})")
    lines.append(f"  Más tiempo en campo    : Jugador {player_rows.index(most_present_row)+1}  (track #{most_present_row[0]}, {most_present_row[4]:.0f}%)")

lines.append("\n" + "=" * 60)

report = "\n".join(lines)
print(report)

with open("informe_partido.txt", "w", encoding="utf-8") as f:
    f.write(report)

print("\nInforme guardado en: informe_partido.txt")
