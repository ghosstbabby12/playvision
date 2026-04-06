"""
detector.py — YOLOv8 model loading and per-frame detection.
Singleton model to avoid reloading on every request.
"""
from ultralytics import YOLO

PERSON_CLASS = 0
BALL_CLASS   = 32

_model: YOLO | None = None


def get_model(weights: str = "yolov8n.pt") -> YOLO:
    global _model
    if _model is None:
        _model = YOLO(weights)
    return _model


def detect_frame(
    frame,
    conf_threshold: float = 0.55,
    ball_conf: float = 0.4,
):
    """
    Run YOLOv8 tracking on a single frame.

    Returns:
        frame_players: dict[track_id -> (cx, cy)]
        ball_center:   (cx, cy) or None
        raw_result:    ultralytics Results object (for annotation)
    """
    model = get_model()
    results = model.track(
        frame,
        persist=True,
        verbose=False,
        classes=[PERSON_CLASS, BALL_CLASS],
        conf=conf_threshold,
        iou=0.5,
    )

    if not results or results[0].boxes is None:
        return {}, None, None

    ball_center: tuple | None = None
    frame_players: dict[int, tuple] = {}

    for box in results[0].boxes:
        cls  = int(box.cls[0])
        conf = float(box.conf[0])
        xyxy = box.xyxy[0].tolist()
        cx   = (xyxy[0] + xyxy[2]) / 2
        cy   = (xyxy[1] + xyxy[3]) / 2

        if cls == BALL_CLASS and conf > ball_conf:
            ball_center = (cx, cy)
        elif cls == PERSON_CLASS and box.id is not None:
            frame_players[int(box.id[0])] = (cx, cy)

    return frame_players, ball_center, results[0]
