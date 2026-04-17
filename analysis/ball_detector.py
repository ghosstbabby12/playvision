"""
ball_detector.py — Stable ball ownership detection.

Uses a stable_count approach: a player must be near the ball
for N consecutive frames before being declared owner.
This prevents rapid ownership flickering.
"""
import math
from collections import defaultdict

BALL_OWNER_THRESHOLD_PX = 50   # distance player→ball to count as "near"
STABLE_FRAMES_REQUIRED  = 3    # consecutive frames near ball to become owner


class BallOwnerTracker:
    def __init__(self):
        self._stable_count: dict[int, int] = defaultdict(int)
        self._current_owner: int | None = None

    def update(
        self,
        frame_players: dict[int, tuple],
        ball_center: tuple | None,
    ) -> int | None:
        """
        Returns the stable owner track_id, or None.
        Requires STABLE_FRAMES_REQUIRED frames of proximity before switching.
        """
        if ball_center is None or not frame_players:
            return self._current_owner

        # Find nearest player
        nearest, min_dist = None, float("inf")
        for pid, pos in frame_players.items():
            d = math.dist(pos, ball_center)
            if d < min_dist:
                min_dist, nearest = d, pid

        if min_dist > BALL_OWNER_THRESHOLD_PX:
            # No one close enough — decay counts
            self._stable_count.clear()
            return self._current_owner

        # Increment stable count for nearest player, decay others
        for pid in list(self._stable_count):
            if pid != nearest:
                self._stable_count[pid] = max(0, self._stable_count[pid] - 1)
        self._stable_count[nearest] += 1

        # Switch owner only when stability threshold is reached
        if self._stable_count[nearest] >= STABLE_FRAMES_REQUIRED:
            self._current_owner = nearest

        return self._current_owner

    @property
    def owner(self) -> int | None:
        return self._current_owner


# ── Simple one-shot helper (for backward compat) ──────────────────────────────
def get_ball_owner(
    frame_players: dict[int, tuple],
    ball_center: tuple | None,
) -> int | None:
    if ball_center is None or not frame_players:
        return None
    nearest, min_dist = None, float("inf")
    for pid, pos in frame_players.items():
        d = math.dist(pos, ball_center)
        if d < min_dist:
            min_dist, nearest = d, pid
    return nearest if min_dist < BALL_OWNER_THRESHOLD_PX else None
