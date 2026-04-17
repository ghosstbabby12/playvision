"""
tracker.py — Stateful per-player tracking across frames.

Maintains positions, distances, ball-possession frames and a
short speed history for moving-average smoothing.
Includes outlier removal to ignore teleportation artefacts.
"""
import math
from collections import defaultdict, deque

SMOOTHING_WINDOW  = 7    # frames for velocity moving average
MAX_JUMP_PX       = 400  # pixels — larger jumps are treated as tracking noise


class PlayerTracker:
    def __init__(self, ball_radius: int = 80):
        self.ball_radius = ball_radius
        self._data: dict = defaultdict(self._empty_entry)

    @staticmethod
    def _empty_entry() -> dict:
        return {
            "positions":        [],
            "distances":        [],
            "frames_seen":      0,
            "frames_with_ball": 0,
            "speed_history":    deque(maxlen=SMOOTHING_WINDOW),
        }

    def update(self, frame_players: dict[int, tuple], ball_center: tuple | None):
        """Process one frame of detections."""
        for pid, pos in frame_players.items():
            entry = self._data[pid]

            if entry["positions"]:
                raw_dist = math.dist(pos, entry["positions"][-1])
                if raw_dist < MAX_JUMP_PX:           # outlier filter
                    entry["distances"].append(raw_dist)
                    entry["speed_history"].append(raw_dist)

            entry["positions"].append(pos)
            entry["frames_seen"] += 1

            if ball_center and math.dist(pos, ball_center) < self.ball_radius:
                entry["frames_with_ball"] += 1

    def smoothed_speed(self, pid: int) -> float:
        """Moving-average speed for a player (in px/frame)."""
        h = self._data[pid]["speed_history"]
        return sum(h) / len(h) if h else 0.0

    @property
    def data(self) -> dict:
        return self._data

    def reset(self):
        self._data = defaultdict(self._empty_entry)
