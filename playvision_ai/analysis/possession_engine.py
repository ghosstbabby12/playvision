"""
possession_engine.py — Ball possession with candidate state machine.

Primary:  nearest player to (smoothed) ball must hold for STABLE_FRAMES.
Fallback: when ball is never detected, we still track the "most central"
          player (surrounded by the most teammates) as a soft possession
          proxy so the pass detector can fire.
"""
import math

THRESHOLD_PX    = 65    # max player→ball distance for possession
STABLE_FRAMES   = 4     # frames candidate must persist before confirming
PROXIMITY_PX    = 80    # fallback: players within this range of the group centroid


class PossessionEngine:
    def __init__(self):
        self._owner:            int | None = None
        self._candidate:        int | None = None
        self._candidate_frames: int        = 0
        self._positions:        dict[int, tuple] = {}
        self._ball_ever_seen:   bool       = False

    def update(
        self,
        players: dict[int, tuple],
        ball: tuple | None,
    ) -> int | None:
        self._positions.update(players)

        if not players:
            return self._owner

        # ── Primary: ball-based possession ───────────────────────────────────
        if ball is not None:
            self._ball_ever_seen = True
            nearest, min_dist = _nearest_to(players, ball)

            if min_dist > THRESHOLD_PX:
                self._candidate        = None
                self._candidate_frames = 0
                return self._owner

            if nearest == self._candidate:
                self._candidate_frames += 1
            else:
                self._candidate        = nearest
                self._candidate_frames = 1

            if self._candidate_frames >= STABLE_FRAMES:
                self._owner = self._candidate

            return self._owner

        # ── Fallback: proximity-based when ball never visible ─────────────────
        # Use the player closest to the group centroid as "in possession".
        # This gives the pass detector something to work with in training
        # videos where the YOLO sports-ball class is rarely triggered.
        if not self._ball_ever_seen and len(players) >= 3:
            centroid = _centroid(players)
            nearest, dist = _nearest_to(players, centroid)
            if dist < PROXIMITY_PX:
                if nearest == self._candidate:
                    self._candidate_frames += 1
                else:
                    self._candidate        = nearest
                    self._candidate_frames = 1

                if self._candidate_frames >= STABLE_FRAMES:
                    self._owner = self._candidate

        return self._owner

    @property
    def owner(self) -> int | None:
        return self._owner

    def get_pos(self, pid: int) -> tuple | None:
        return self._positions.get(pid)


# ── helpers ───────────────────────────────────────────────────────────────────

def _nearest_to(players: dict, point: tuple):
    nearest, min_dist = None, float("inf")
    for pid, pos in players.items():
        d = math.dist(pos, point)
        if d < min_dist:
            min_dist, nearest = d, pid
    return nearest, min_dist


def _centroid(players: dict) -> tuple:
    xs = [p[0] for p in players.values()]
    ys = [p[1] for p in players.values()]
    return (sum(xs) / len(xs), sum(ys) / len(ys))
