"""
event_engine.py — Temporally-validated pass detection.

Architecture:
  Ball   → temporal buffer (3/5 frames) → stable ball position
  Owner  → candidate state machine (frames > STABLE) → confirmed owner
  Pass   → distance validation (50–300px) + same_team + cooldown
  Fallback → proximity counter per pair (>5 frames close → pass)
"""
import math
# avoid external dependency on numpy by using built-in mean computation
from collections import deque, defaultdict

# ── Thresholds ─────────────────────────────────────────────────────────────────
BALL_BUFFER_LEN     = 5    # frames in ball temporal buffer
BALL_MIN_SEEN       = 3    # min detections in buffer to accept ball as real

OWNER_STABLE_FRAMES = 6    # frames candidate must hold before becoming owner
PASS_DIST_MIN       = 50   # px — ignore micro hand-offs
PASS_DIST_MAX       = 350  # px — ignore teleportation / detector noise
COOLDOWN_FRAMES     = 12   # min frames between registered passes
TRACK_MIN_HISTORY   = 3    # ignore players seen < N frames (ghosts)

PROX_THRESHOLD_PX   = 55   # px — "close enough to exchange ball"
PROX_MIN_FRAMES     = 5    # frames pair must stay close before counting

MAX_PASSES_DISPLAY  = 6
PASS_FADE_FRAMES    = 50


class PassDetector:
    def __init__(self):
        # Ball temporal buffer
        self._ball_buf: deque = deque(maxlen=BALL_BUFFER_LEN)

        # Owner state machine
        self._confirmed_owner: int | None = None
        self._candidate:       int | None = None
        self._candidate_frames: int = 0

        # Pass state
        self._cooldown:    int = 0
        self._pass_count:  int = 0
        self._recent: deque    = deque(maxlen=MAX_PASSES_DISPLAY)
        self._holder_pos: dict[int, tuple] = {}

        # Proximity fallback
        self._prox_counters: dict[tuple, int] = defaultdict(int)

        # Track history (pid → frame count)
        self._track_frames: dict[int, int] = defaultdict(int)

        # Debug
        self._frame_num = 0

    # ── Public ────────────────────────────────────────────────────────────────

    def update(
        self,
        frame_players: dict[int, tuple],
        ball_center_raw: tuple | None,
        team_classifier,
    ) -> None:
        self._frame_num += 1

        # Age arrows
        aged = [
            {**p, "age": p["age"] + 1}
            for p in self._recent
            if p["age"] < PASS_FADE_FRAMES
        ]
        self._recent = deque(aged, maxlen=MAX_PASSES_DISPLAY)

        if self._cooldown > 0:
            self._cooldown -= 1

        # Update known positions + track history
        stable_players = {}
        for pid, pos in frame_players.items():
            self._track_frames[pid] += 1
            self._holder_pos[pid] = pos
            if self._track_frames[pid] >= TRACK_MIN_HISTORY:
                stable_players[pid] = pos   # filter ghost players

        # Stable ball position
        ball = self._stable_ball(ball_center_raw)

        if ball is not None:
            self._update_ball_mode(stable_players, ball, team_classifier)
        else:
            self._update_proximity_mode(stable_players, team_classifier)

    # ── Ball temporal filter ──────────────────────────────────────────────────

    def _stable_ball(self, raw: tuple | None) -> tuple | None:
        self._ball_buf.append(raw)
        valid = [p for p in self._ball_buf if p is not None]
        if len(valid) >= BALL_MIN_SEEN:
            xs = [p[0] for p in valid]
            ys = [p[1] for p in valid]
            bx = float(sum(xs) / len(xs))
            by = float(sum(ys) / len(ys))
            return (bx, by)
        return None

    # ── Ball-based owner state machine ────────────────────────────────────────

    def _update_ball_mode(self, players, ball, team_classifier):
        if not players:
            return

        # Nearest stable player to ball
        nearest, min_dist = None, float("inf")
        for pid, pos in players.items():
            d = math.dist(pos, ball)
            if d < min_dist:
                min_dist, nearest = d, pid

        if min_dist > 60:   # ball not controlled by anyone
            self._candidate = None
            self._candidate_frames = 0
            return

        if nearest == self._candidate:
            self._candidate_frames += 1
        else:
            self._candidate        = nearest
            self._candidate_frames = 1

        # Candidate stable enough to become confirmed owner?
        if self._candidate_frames >= OWNER_STABLE_FRAMES:
            prev = self._confirmed_owner
            if prev != nearest and prev is not None and self._cooldown == 0:
                self._try_register_pass(prev, nearest, team_classifier, source="ball")
            self._confirmed_owner = nearest

    # ── Proximity fallback ────────────────────────────────────────────────────

    def _update_proximity_mode(self, players, team_classifier):
        if len(players) < 2 or self._cooldown > 0:
            return

        pids = list(players.keys())
        active_pairs = set()

        for i in range(len(pids)):
            for j in range(i + 1, len(pids)):
                a, b  = pids[i], pids[j]
                pair  = (min(a, b), max(a, b))
                d     = math.dist(players[a], players[b])

                if d < PROX_THRESHOLD_PX:
                    self._prox_counters[pair] += 1
                    active_pairs.add(pair)
                else:
                    if self._prox_counters[pair] >= PROX_MIN_FRAMES:
                        # They were close and now separated → pass
                        self._try_register_pass(a, b, team_classifier, source="prox")
                    if pair in self._prox_counters:
                        del self._prox_counters[pair]

        # Decay pairs no longer active
        for pair in list(self._prox_counters):
            if pair not in active_pairs:
                del self._prox_counters[pair]

    # ── Pass registration ─────────────────────────────────────────────────────

    def _try_register_pass(self, from_id, to_id, team_classifier, source="ball"):
        from_pos = self._holder_pos.get(from_id)
        to_pos   = self._holder_pos.get(to_id)
        if not from_pos or not to_pos:
            return

        dist = math.dist(from_pos, to_pos)

        # Distance validation: avoid micro-changes and teleportation
        if not (PASS_DIST_MIN < dist < PASS_DIST_MAX):
            return

        ta = team_classifier.get_team(from_id)
        tb = team_classifier.get_team(to_id)
        same = (ta == tb) or (ta == -1) or (tb == -1)
        if not same:
            return

        team = ta if ta != -1 else (tb if tb != -1 else 0)

        self._recent.append({
            "from_id":  from_id,
            "to_id":    to_id,
            "from_pos": from_pos,
            "to_pos":   to_pos,
            "age":      0,
            "team":     team,
        })
        self._pass_count += 1
        self._cooldown = COOLDOWN_FRAMES

        print(
            f"[pass:{source}] {from_id}→{to_id}  "
            f"dist={dist:.0f}px  team={team}  total={self._pass_count}"
        )

    # ── Properties ────────────────────────────────────────────────────────────

    @property
    def pass_count(self) -> int:
        return self._pass_count

    @property
    def recent_passes(self) -> list[dict]:
        return list(self._recent)

    @property
    def ball_holder(self) -> int | None:
        return self._confirmed_owner
