"""
team_classifier.py — Team classification from YOLO class output.
Class 0 = Player_Green (team 0), Class 1 = Player_Red (team 1).
"""
import numpy as np

TEAM_GREEN_CLASS = 0
TEAM_RED_CLASS   = 1
PLAYER_CLASSES   = {TEAM_GREEN_CLASS, TEAM_RED_CLASS}

TEAM_COLORS_BGR = [
    (50,  220,  50),   # team 0 — green
    (50,  80,  255),   # team 1 — red/orange
]
UNKNOWN_COLOR_BGR = (160, 160, 160)


class TeamClassifier:
    def __init__(self):
        self._team_map: dict[int, int] = {}

    def update(self, frame: np.ndarray, results) -> None:
        """Read team directly from YOLO class (0=green, 1=red)."""
        if results is None or results.boxes is None:
            return
        for box in results.boxes:
            cls = int(box.cls[0])
            if cls not in PLAYER_CLASSES or box.id is None:
                continue
            pid = int(box.id[0])
            self._team_map[pid] = cls

    def get_team(self, pid: int) -> int:
        """Returns 0, 1, or -1 (unknown)."""
        return self._team_map.get(pid, -1)

    def color_for(self, pid: int) -> tuple:
        t = self.get_team(pid)
        if t in (0, 1):
            return TEAM_COLORS_BGR[t]
        return UNKNOWN_COLOR_BGR
