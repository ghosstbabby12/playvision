"""
detector.py — YOLOv8 + ByteTrack detection with position smoothing.
Uses custom best.pt model: class 0 = Player_Green, class 1 = Player_Red.
"""
import numpy as np
from collections import defaultdict, deque
from ultralytics import YOLO

TEAM_GREEN_CLASS = 0
TEAM_RED_CLASS   = 1
PLAYER_CLASSES   = {TEAM_GREEN_CLASS, TEAM_RED_CLASS}
PLAYER_CONF = 0.35
SMOOTH_LEN  = 5

_model: YOLO | None = None
_pos_history:  dict  = defaultdict(lambda: deque(maxlen=SMOOTH_LEN))
_ball_history: deque = deque(maxlen=SMOOTH_LEN)
_team_registry: dict = {}   # track_id -> "green" | "red"
_TRACKER = "bytetrack.yaml"


def get_model(weights: str | None = None) -> YOLO:
    global _model
    if _model is None:
        if weights is None:
            from app.core.config import settings
            weights = settings.model_path
        _model = YOLO(weights)
    return _model


def detect_frame(frame, conf_threshold: float = PLAYER_CONF):
    """
    Returns:
        frame_players : dict[track_id -> (smooth_cx, smooth_cy, team)]
        ball_center   : always None (custom model does not detect the ball)
        raw_result    : ultralytics Results object
    """
    model = get_model()

    try:
        results = model.track(
            frame,
            persist=True,
            tracker=_TRACKER,
            verbose=False,
            classes=list(PLAYER_CLASSES),
            conf=conf_threshold,
            iou=0.45,
        )
    except Exception:
        results = model.track(
            frame,
            persist=True,
            verbose=False,
            classes=list(PLAYER_CLASSES),
            conf=conf_threshold,
            iou=0.45,
        )

    if not results or results[0].boxes is None:
        return {}, None, None

    boxes = results[0].boxes

    frame_players: dict[int, tuple] = {}

    players_raw     = sum(1 for b in boxes if int(b.cls[0]) in PLAYER_CLASSES)
    players_with_id = sum(
        1 for b in boxes
        if int(b.cls[0]) in PLAYER_CLASSES and b.id is not None
    )

    if players_raw > 0:
        print(f"[det] players={players_raw}  with_id={players_with_id}  conf_min={conf_threshold}")

    for box in boxes:
        cls = int(box.cls[0])
        if cls not in PLAYER_CLASSES:
            continue

        xyxy = box.xyxy[0].tolist()
        cx   = (xyxy[0] + xyxy[2]) / 2
        cy   = (xyxy[1] + xyxy[3]) / 2

        team = "green" if cls == TEAM_GREEN_CLASS else "red"

        if box.id is not None:
            pid = int(box.id[0])
        else:
            pid = int(cx / 50) * 1000 + int(cy / 50)

        _team_registry[pid] = team

        _pos_history[pid].append((cx, cy))
        hist = _pos_history[pid]
        smooth_cx = float(np.mean([p[0] for p in hist]))
        smooth_cy = float(np.mean([p[1] for p in hist]))

        frame_players[pid] = (smooth_cx, smooth_cy, team)

    return frame_players, None, results[0]


def get_player_team(track_id: int) -> str:
    """Devuelve el equipo registrado para un track_id."""
    return _team_registry.get(track_id, "unknown")


def reset_state() -> None:
    _pos_history.clear()
    _ball_history.clear()
    _team_registry.clear()
