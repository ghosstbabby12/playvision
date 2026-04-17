"""
detector.py — YOLOv8 + ByteTrack detection with position smoothing.
"""
import numpy as np
from collections import defaultdict, deque
from ultralytics import YOLO

PERSON_CLASS = 0
BALL_CLASS   = 32

PLAYER_CONF  = 0.35
BALL_CONF    = 0.15   # very low — ball is small and fast in training videos

SMOOTH_LEN   = 5

_model: YOLO | None = None
_pos_history:  dict  = defaultdict(lambda: deque(maxlen=SMOOTH_LEN))
_ball_history: deque = deque(maxlen=SMOOTH_LEN)

# Try bytetrack, fall back to default tracker silently
_TRACKER = "bytetrack.yaml"


def get_model(weights: str = "yolov8n.pt") -> YOLO:
    global _model
    if _model is None:
        _model = YOLO(weights)
    return _model


def detect_frame(frame, conf_threshold: float = PLAYER_CONF):
    """
    Returns:
        frame_players : dict[track_id -> (smooth_cx, smooth_cy)]
        ball_center   : (smooth_cx, smooth_cy) or None
        raw_result    : ultralytics Results object
    """
    model = get_model()

    try:
        results = model.track(
            frame,
            persist=True,
            tracker=_TRACKER,
            verbose=False,
            classes=[PERSON_CLASS, BALL_CLASS],
            conf=conf_threshold,
            iou=0.45,
        )
    except Exception:
        # Fallback without explicit tracker config
        results = model.track(
            frame,
            persist=True,
            verbose=False,
            classes=[PERSON_CLASS, BALL_CLASS],
            conf=conf_threshold,
            iou=0.45,
        )

    if not results or results[0].boxes is None:
        return {}, None, None

    boxes = results[0].boxes
    frame_players: dict[int, tuple] = {}
    raw_ball: tuple | None = None

    # Debug: count raw detections
    persons_raw = sum(1 for b in boxes if int(b.cls[0]) == PERSON_CLASS)
    persons_with_id = sum(
        1 for b in boxes
        if int(b.cls[0]) == PERSON_CLASS and b.id is not None
    )
    if persons_raw > 0:
        print(f"[det] persons={persons_raw}  with_id={persons_with_id}  conf_min={conf_threshold}")

    for box in boxes:
        cls  = int(box.cls[0])
        conf = float(box.conf[0])
        xyxy = box.xyxy[0].tolist()
        cx   = (xyxy[0] + xyxy[2]) / 2
        cy   = (xyxy[1] + xyxy[3]) / 2

        if cls == BALL_CLASS and conf >= BALL_CONF:
            raw_ball = (cx, cy)

        elif cls == PERSON_CLASS:
            # Use track ID if available, else use a hash of position as fallback ID
            if box.id is not None:
                pid = int(box.id[0])
            else:
                # Tracking not started yet for this box — use position bucket as temp ID
                pid = int(cx / 50) * 1000 + int(cy / 50)

            _pos_history[pid].append((cx, cy))
            hist = _pos_history[pid]
            smooth_cx = float(np.mean([p[0] for p in hist]))
            smooth_cy = float(np.mean([p[1] for p in hist]))
            frame_players[pid] = (smooth_cx, smooth_cy)

    # Smooth ball
    ball_center: tuple | None = None
    if raw_ball:
        _ball_history.append(raw_ball)
        ball_center = (
            float(np.mean([p[0] for p in _ball_history])),
            float(np.mean([p[1] for p in _ball_history])),
        )

    return frame_players, ball_center, results[0]


def reset_state() -> None:
    _pos_history.clear()
    _ball_history.clear()
