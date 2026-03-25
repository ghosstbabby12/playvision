def build_chart_payload(frame_counts: list[dict], stats: dict) -> dict:
    frames = [item["frame"] for item in frame_counts]
    green = [item["green_visible"] for item in frame_counts]
    red = [item["red_visible"] for item in frame_counts]
    unknown = [item["unknown_visible"] for item in frame_counts]

    return {
        "visibility_by_frame": {
            "type": "line",
            "labels": frames,
            "series": [
                {"name": "green_team", "data": green},
                {"name": "red_team", "data": red},
                {"name": "unknown", "data": unknown},
            ],
        },
        "stable_players_by_team": {
            "type": "bar",
            "labels": ["green_team", "red_team", "unknown"],
            "series": [
                stats.get("green_team_stable_players", 0),
                stats.get("red_team_stable_players", 0),
                stats.get("unknown_stable_players", 0),
            ],
        },
    }