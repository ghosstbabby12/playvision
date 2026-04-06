"""
metrics_engine.py — Converts raw tracker data into player and team metrics.

New metrics added vs. v1:
  - speed_kmh (km/h peak smooth speed)
  - heatmap_zones (3x3 zone visit counts)
"""


def zone_label(x: float, y: float, w: int, h: int) -> str:
    col = "Left"   if x < w / 3 else ("Right"  if x > 2 * w / 3 else "Center")
    row = "Attack" if y < h / 3 else ("Defense" if y > 2 * h / 3 else "Mid")
    return f"{row}-{col}"


def _heatmap(positions: list, frame_width: int, frame_height: int) -> dict:
    """Return a 3×3 normalised visit-count grid."""
    grid: dict[str, int] = {}
    for px, py in positions:
        lbl = zone_label(px, py, frame_width, frame_height)
        grid[lbl] = grid.get(lbl, 0) + 1
    total = max(sum(grid.values()), 1)
    return {k: round(v / total * 100, 1) for k, v in sorted(grid.items())}


def compute_metrics(
    player_data: dict,
    analyzed_frames: int,
    frame_width: int,
    frame_height: int,
    field_width_m: float,
    fps: float,
    frame_skip: int,
    num_players: int,
    min_presence: float,
) -> tuple[list, dict]:
    """
    Returns (players_out, team_stats).
    """
    min_frames = max(10, int(analyzed_frames * min_presence))
    stable = {pid: d for pid, d in player_data.items() if d["frames_seen"] >= min_frames}
    active = dict(
        sorted(stable.items(), key=lambda x: x[1]["frames_seen"], reverse=True)[:num_players]
    )

    scale         = field_width_m / frame_width
    effective_fps = fps / frame_skip

    players_out     = []
    team_total_dist = 0

    for rank, (pid, data) in enumerate(
        sorted(active.items(), key=lambda x: x[1]["frames_seen"], reverse=True), 1
    ):
        total_dist   = sum(data["distances"])
        presence_pct = data["frames_seen"] / max(analyzed_frames, 1) * 100
        poss_pct     = data["frames_with_ball"] / max(data["frames_seen"], 1) * 100

        speed_history = data.get("speed_history", [])
        avg_speed_px  = (sum(speed_history) / len(speed_history)) if speed_history else (
            total_dist / max(len(data["distances"]), 1)
        )

        avg_x = sum(p[0] for p in data["positions"]) / len(data["positions"])
        avg_y = sum(p[1] for p in data["positions"]) / len(data["positions"])

        team_total_dist += total_dist

        distance_m  = total_dist * scale
        distance_km = round(distance_m / 1000, 2)
        speed_ms    = round(avg_speed_px * scale * effective_fps, 2)
        speed_kmh   = round(speed_ms * 3.6, 1)

        positions_sample = [
            {"x": round(p[0] / frame_width, 3), "y": round(p[1] / frame_height, 3)}
            for p in data["positions"][::15]
        ]

        players_out.append({
            "rank":             rank,
            "track_id":         pid,
            "zone":             zone_label(avg_x, avg_y, frame_width, frame_height),
            "presence_pct":     round(presence_pct, 1),
            "total_distance":   round(total_dist),
            "distance_km":      distance_km,
            "speed_ms":         speed_ms,
            "speed_kmh":        speed_kmh,
            "possession_pct":   round(poss_pct, 1),
            "avg_x_norm":       round(avg_x / frame_width, 3),
            "avg_y_norm":       round(avg_y / frame_height, 3),
            "positions_sample": positions_sample,
            "heatmap_zones":    _heatmap(data["positions"], frame_width, frame_height),
        })

    team_km   = round(team_total_dist * scale / 1000, 2)
    team_poss = (
        sum(d["frames_with_ball"] for d in active.values()) / max(analyzed_frames, 1) * 100
    )

    most_active  = max(players_out, key=lambda p: p["total_distance"],  default=None)
    most_poss    = max(players_out, key=lambda p: p["possession_pct"],  default=None)
    least_active = min(players_out, key=lambda p: p["total_distance"],  default=None)

    team_stats = {
        "total_distance":    round(team_total_dist),
        "total_distance_km": team_km,
        "avg_distance_km":   round(team_km / max(len(active), 1), 2),
        "possession_pct":    round(team_poss, 1),
        "most_active":       most_active["rank"]  if most_active  else None,
        "least_active":      least_active["rank"] if least_active else None,
        "most_possession":   most_poss["rank"]    if most_poss    else None,
    }

    return players_out, team_stats
