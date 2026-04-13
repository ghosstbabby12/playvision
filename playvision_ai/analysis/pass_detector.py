"""
pass_detector.py — Pass detection with multi-condition validation:
  1. Possession changed from A → B
  2. Same team (or unclassified)
  3. Distance within realistic range
  4. Cooldown respected
  5. Stores full pass log with frame_id
"""
import math
from collections import deque

PASS_DIST_MIN   = 30    # px — ignore micro-handoffs
PASS_DIST_MAX   = 480   # px — ignore teleportation noise
COOLDOWN_FRAMES = 10
MAX_DISPLAY     = 6     # recent passes drawn on screen
FADE_FRAMES     = 50    # frames until arrow disappears


class PassLog:
    def __init__(self):
        self._all:       list[dict]  = []
        self._recent:    deque       = deque(maxlen=MAX_DISPLAY)
        self._cooldown:  int         = 0
        self._positions: dict[int, tuple] = {}

    # ── Called every frame ────────────────────────────────────────────────────

    def tick(self) -> None:
        """Advance timers. Call once per analyzed frame."""
        if self._cooldown > 0:
            self._cooldown -= 1
        aged = [
            {**p, "age": p["age"] + 1}
            for p in self._recent
            if p["age"] < FADE_FRAMES
        ]
        self._recent = deque(aged, maxlen=MAX_DISPLAY)

    def update_positions(self, players: dict[int, tuple]) -> None:
        self._positions.update(players)

    # ── Pass registration ─────────────────────────────────────────────────────

    def try_register(
        self,
        from_id: int,
        to_id:   int,
        team_classifier,
        frame_id: int,
    ) -> bool:
        if self._cooldown > 0:
            return False

        from_pos = self._positions.get(from_id)
        to_pos   = self._positions.get(to_id)
        if not from_pos or not to_pos:
            return False

        dist = math.dist(from_pos, to_pos)
        if not (PASS_DIST_MIN < dist < PASS_DIST_MAX):
            return False

        ta = team_classifier.get_team(from_id)
        tb = team_classifier.get_team(to_id)
        # Reject only if BOTH are classified AND on different teams
        if ta != -1 and tb != -1 and ta != tb:
            return False

        team = ta if ta != -1 else (tb if tb != -1 else 0)

        entry = {
            "passer_id":   from_id,
            "receiver_id": to_id,
            "from_pos":    from_pos,
            "to_pos":      to_pos,
            "frame_id":    frame_id,
            "team":        team,
        }
        self._all.append(entry)
        self._recent.append({**entry, "age": 0,
                              "from_id": from_id, "to_id": to_id})
        self._cooldown = COOLDOWN_FRAMES

        print(
            f"[pass] {from_id}→{to_id}  "
            f"dist={dist:.0f}px  team={team}  "
            f"total={len(self._all)}  frame={frame_id}"
        )
        return True

    # ── Properties ────────────────────────────────────────────────────────────

    @property
    def total(self) -> int:
        return len(self._all)

    @property
    def recent(self) -> list[dict]:
        return list(self._recent)

    @property
    def all_passes(self) -> list[dict]:
        return self._all
