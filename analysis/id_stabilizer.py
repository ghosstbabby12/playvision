"""
id_stabilizer.py — Maps volatile ByteTrack IDs to stable IDs 1..N using spatial proximity.
"""
import math

MAX_DIST   = 120  # px — max distance to consider same player
MAX_UNSEEN = 30   # frames without detection before releasing a stable ID


class IDStabilizer:
    def __init__(self, max_dist: int = MAX_DIST, max_unseen: int = MAX_UNSEEN):
        self.max_dist   = max_dist
        self.max_unseen = max_unseen
        self._stable: dict[int, dict] = {}
        self._next_id = 1

    def update(self, frame_players: dict[int, tuple]) -> dict[int, tuple]:
        """
        Receives {raw_id: (cx, cy, team)}.
        Returns  {stable_id: (cx, cy, team)}.
        """
        for sid in self._stable:
            self._stable[sid]["unseen"] += 1

        used_stable: set[int] = set()
        result: dict[int, tuple] = {}

        for raw_id, detection in frame_players.items():
            cx, cy = detection[0], detection[1]
            team   = detection[2] if len(detection) > 2 else "unknown"
            pos    = (cx, cy)

            best_sid  = None
            best_dist = self.max_dist

            for sid, info in self._stable.items():
                if sid in used_stable:
                    continue
                d = math.dist(pos, info["pos"])
                if d < best_dist:
                    best_dist = d
                    best_sid  = sid

            if best_sid is not None:
                self._stable[best_sid].update({"pos": pos, "unseen": 0, "raw_id": raw_id})
                used_stable.add(best_sid)
                result[best_sid] = (cx, cy, team)
            else:
                sid = self._next_id
                self._next_id += 1
                self._stable[sid] = {"pos": pos, "unseen": 0, "raw_id": raw_id}
                used_stable.add(sid)
                result[sid] = (cx, cy, team)

        to_remove = [sid for sid, info in self._stable.items()
                     if info["unseen"] > self.max_unseen]
        for sid in to_remove:
            del self._stable[sid]

        return result

    def reset(self):
        self._stable.clear()
        self._next_id = 1
