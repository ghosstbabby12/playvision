"""
ball_tracker.py — Robust ball tracking:
  - Outlier rejection (unrealistic speed)
  - Temporal smoothing (last N valid detections)
  - Position persistence (keeps last known pos for N frames)
"""
import math
from collections import deque

MAX_BALL_SPEED_PX  = 180   # px/frame — faster = outlier
BUFFER_LEN         = 7
MIN_VALID          = 3     # detections in buffer to output a position
PERSISTENCE_FRAMES = 8     # frames to hold last position when ball missing


class BallTracker:
    def __init__(self):
        self._buf: deque         = deque(maxlen=BUFFER_LEN)
        self._last_valid: tuple | None = None
        self._persistence: int   = 0

    def update(self, raw: tuple | None) -> tuple | None:
        """
        Feed raw detection (or None). Returns smoothed & stable ball pos.
        """
        # Reject outlier — ball can't teleport
        if raw is not None and self._last_valid is not None:
            if math.dist(raw, self._last_valid) > MAX_BALL_SPEED_PX:
                raw = None

        self._buf.append(raw)
        valid = [p for p in self._buf if p is not None]

        if len(valid) >= MIN_VALID:
            bx = sum(p[0] for p in valid) / len(valid)
            by = sum(p[1] for p in valid) / len(valid)
            pos = (bx, by)
            self._last_valid  = pos
            self._persistence = PERSISTENCE_FRAMES
            return pos

        # Temporal persistence — don't lose ball between frames
        if self._persistence > 0:
            self._persistence -= 1
            return self._last_valid

        return None

    @property
    def last_known(self) -> tuple | None:
        return self._last_valid
