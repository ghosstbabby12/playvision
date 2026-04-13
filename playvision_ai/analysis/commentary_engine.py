"""
commentary_engine.py - Rule-based tactical commentary.

Generates 1–3 broadcast-style insights per segment based on:
  - Pass rate and sequence type
  - Player pressure zones
  - Team compactness and defensive shape
  - Ball progression (which third)
  - Possession chains
"""
import math
from collections import defaultdict


class CommentaryEngine:
    def __init__(self, frame_w: int, frame_h: int):
        self._fw = frame_w
        self._fh = frame_h
        self._latest: list[str] = []
        self._prev_ball_zone: str | None = None
        self._zone_hold_count: int = 0

    def update(
        self,
        frame_id:        int,
        players:         dict[int, tuple],
        ball:            tuple | None,
        all_passes:      list[dict],
        team_classifier,
    ) -> list[str]:
        if not players:
            return self._latest

        insights: list[str] = []

        # 1. Pass sequence analysis (last 90 frames ≈ 3s at 30fps)
        recent = [p for p in all_passes if frame_id - p["frame_id"] < 90]
        total  = len(all_passes)

        if len(recent) >= 6:
            insights.append("Lightning quick passing sequence")
        elif len(recent) >= 4:
            insights.append("Fast combination play")
        elif len(recent) >= 2:
            insights.append("Building through passes")

        if total >= 20 and not insights:
            insights.append(f"{total} passes - dominant possession")

        # 2. Pressure zones - count players per third
        thirds = {"Attacking": 0, "Middle": 0, "Defensive": 0}
        for pos in players.values():
            thirds[self._vertical_third(pos)] += 1

        if thirds["Attacking"] >= 5:
            insights.append("High press - attacking third overload")
        elif thirds["Defensive"] >= 6:
            insights.append("Compact defensive block")
        elif thirds["Middle"] >= 5:
            insights.append("Midfield battle for control")

        # 3. Team compactness / width
        positions = list(players.values())
        if len(positions) >= 5:
            spread = self._spread(positions)
            width  = self._width(positions)
            if spread < 180:
                insights.append("Team compact - tight defensive shape")
            elif width > self._fw * 0.65:
                insights.append("Wide attacking shape - stretching play")
            elif spread > 500:
                insights.append("Team spread - counter-attack threat")

        # 4. Ball progression - track which third the ball is in
        if ball:
            zone = self._vertical_third(ball)
            side = self._horizontal_side(ball)

            if zone == self._prev_ball_zone:
                self._zone_hold_count += 1
            else:
                self._zone_hold_count = 0
                self._prev_ball_zone  = zone

            # Only show ball position if no pressure/compactness insight
            if not any(kw in " ".join(insights) for kw in ["press", "compact", "shape", "battle"]):
                if zone == "Attacking":
                    insights.append(f"Ball in attacking third - {side} channel")
                elif zone == "Defensive":
                    insights.append(f"Defending deep - ball on {side}")
                else:
                    insights.append(f"Play through the {side} midfield")

            # Held in attacking third
            if self._zone_hold_count > 5 and zone == "Attacking":
                insights.append("Sustained pressure in final third")

        self._latest = insights[:3]
        return self._latest

    @property
    def latest(self) -> list[str]:
        return self._latest

    # ── Helpers ───────────────────────────────────────────────────────────────

    def _vertical_third(self, pos: tuple) -> str:
        _, y = pos
        if y < self._fh / 3:
            return "Attacking"
        if y > 2 * self._fh / 3:
            return "Defensive"
        return "Middle"

    def _horizontal_side(self, pos: tuple) -> str:
        x, _ = pos
        if x < self._fw / 3:
            return "left"
        if x > 2 * self._fw / 3:
            return "right"
        return "central"

    def _spread(self, positions: list) -> float:
        xs = [p[0] for p in positions]
        ys = [p[1] for p in positions]
        return math.dist((min(xs), min(ys)), (max(xs), max(ys)))

    def _width(self, positions: list) -> float:
        xs = [p[0] for p in positions]
        return max(xs) - min(xs)
