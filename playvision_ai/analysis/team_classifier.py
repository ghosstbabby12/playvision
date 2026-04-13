"""
team_classifier.py — Classifies players into 2 teams using jersey color (K-Means on HSV).
"""
import cv2
import numpy as np
from collections import defaultdict

PERSON_CLASS = 0

TEAM_COLORS_BGR = [
    (50,  220,  50),   # team 0 — green
    (50,  80,  255),   # team 1 — red/orange
]
UNKNOWN_COLOR_BGR = (160, 160, 160)


class TeamClassifier:
    def __init__(self):
        self._color_history: dict[int, list] = defaultdict(list)
        self._team_map: dict[int, int] = {}

    # ── Public ────────────────────────────────────────────────────────────────
    def update(self, frame: np.ndarray, results) -> None:
        """Extract jersey colors for each tracked person and reclassify."""
        if results is None or results.boxes is None:
            return

        for box in results.boxes:
            if int(box.cls[0]) != PERSON_CLASS or box.id is None:
                continue
            pid   = int(box.id[0])
            color = self._jersey_color(frame, box.xyxy[0].tolist())
            if color is not None:
                self._color_history[pid].append(color)
                # Keep only last 30 samples per player
                if len(self._color_history[pid]) > 30:
                    self._color_history[pid].pop(0)

        self._reclassify()

    def get_team(self, pid: int) -> int:
        """Returns 0, 1, or -1 (unknown)."""
        return self._team_map.get(pid, -1)

    def color_for(self, pid: int) -> tuple:
        t = self.get_team(pid)
        if t in (0, 1):
            return TEAM_COLORS_BGR[t]
        return UNKNOWN_COLOR_BGR

    # ── Internal ──────────────────────────────────────────────────────────────
    def _jersey_color(self, frame: np.ndarray, xyxy: list):
        x1, y1, x2, y2 = [int(v) for v in xyxy]
        h = y2 - y1
        # Upper 35 % of bounding box = jersey torso area
        jersey = frame[y1: y1 + max(1, int(h * 0.35)), x1:x2]
        if jersey.size == 0:
            return None
        jersey = cv2.resize(jersey, (16, 8))
        hsv    = cv2.cvtColor(jersey, cv2.COLOR_BGR2HSV)
        return hsv.reshape(-1, 3).mean(axis=0)   # mean [H, S, V]

    def _reclassify(self) -> None:
        if len(self._color_history) < 4:
            return

        pids     = list(self._color_history.keys())
        features = np.array(
            [np.mean(self._color_history[p], axis=0) for p in pids],
            dtype=np.float32,
        )

        criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 10, 1.0)
        _, labels, _ = cv2.kmeans(
            features, 2, None, criteria, 5, cv2.KMEANS_RANDOM_CENTERS
        )
        for pid, lbl in zip(pids, labels.flatten()):
            self._team_map[pid] = int(lbl)
