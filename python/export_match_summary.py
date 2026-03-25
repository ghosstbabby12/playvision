from pathlib import Path
import csv
import json


PLAYER_SUMMARY_CSV = Path("runs/playvision_color/player_summary.csv")
TEAM_COUNTS_CSV = Path("runs/playvision_color/team_counts_by_frame.csv")
TEAM_SUMMARY_CSV = Path("runs/playvision_color/team_summary.csv")
OUTPUT_JSON = Path("runs/playvision_color/match_summary.json")


def to_int(value, default=0):
    try:
        return int(float(value))
    except:
        return default


def to_float(value, default=0.0):
    try:
        return float(value)
    except:
        return default


def to_bool(value):
    return str(value).strip().lower() in ("true", "1", "yes")


def read_player_summary():
    players = []

    if not PLAYER_SUMMARY_CSV.exists():
        raise FileNotFoundError(f"No existe: {PLAYER_SUMMARY_CSV}")

    with open(PLAYER_SUMMARY_CSV, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)

        for row in reader:
            players.append({
                "track_id": to_int(row.get("track_id")),
                "first_frame": to_int(row.get("first_frame")),
                "last_frame": to_int(row.get("last_frame")),
                "frames_detected": to_int(row.get("frames_detected")),
                "max_frames_seen": to_int(row.get("max_frames_seen")),
                "avg_conf": to_float(row.get("avg_conf")),
                "avg_color_score": to_float(row.get("avg_color_score")),
                "green_votes": to_int(row.get("green_votes")),
                "red_votes": to_int(row.get("red_votes")),
                "unknown_votes": to_int(row.get("unknown_votes")),
                "final_team_player": (row.get("final_team_player") or "unknown").strip(),
                "stable_player": to_bool(row.get("stable_player")),
                "avg_box": {
                    "x1": to_int(row.get("avg_x1")),
                    "y1": to_int(row.get("avg_y1")),
                    "x2": to_int(row.get("avg_x2")),
                    "y2": to_int(row.get("avg_y2")),
                }
            })

    return players


def read_team_counts_by_frame():
    frames = []

    if not TEAM_COUNTS_CSV.exists():
        raise FileNotFoundError(f"No existe: {TEAM_COUNTS_CSV}")

    with open(TEAM_COUNTS_CSV, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)

        for row in reader:
            frames.append({
                "frame": to_int(row.get("frame")),
                "green_visible": to_int(row.get("green_visible")),
                "red_visible": to_int(row.get("red_visible")),
                "unknown_visible": to_int(row.get("unknown_visible")),
                "total_visible": to_int(row.get("total_visible")),
            })

    return frames


def read_team_summary():
    summary = {
        "green_team": 0,
        "red_team": 0,
        "unknown": 0,
    }

    if not TEAM_SUMMARY_CSV.exists():
        raise FileNotFoundError(f"No existe: {TEAM_SUMMARY_CSV}")

    with open(TEAM_SUMMARY_CSV, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)

        for row in reader:
            team = (row.get("team") or "").strip()
            stable_players = to_int(row.get("stable_players"))

            if team in summary:
                summary[team] = stable_players

    return summary


def build_match_summary():
    players = read_player_summary()
    frame_counts = read_team_counts_by_frame()
    team_summary = read_team_summary()

    stable_players = [p for p in players if p["stable_player"]]
    unstable_players = [p for p in players if not p["stable_player"]]

    green_players = [p for p in stable_players if p["final_team_player"] == "green_team"]
    red_players = [p for p in stable_players if p["final_team_player"] == "red_team"]
    unknown_players = [p for p in stable_players if p["final_team_player"] == "unknown"]

    max_green_visible = max((f["green_visible"] for f in frame_counts), default=0)
    max_red_visible = max((f["red_visible"] for f in frame_counts), default=0)
    max_unknown_visible = max((f["unknown_visible"] for f in frame_counts), default=0)
    max_total_visible = max((f["total_visible"] for f in frame_counts), default=0)

    avg_green_visible = round(
        sum(f["green_visible"] for f in frame_counts) / len(frame_counts), 2
    ) if frame_counts else 0.0

    avg_red_visible = round(
        sum(f["red_visible"] for f in frame_counts) / len(frame_counts), 2
    ) if frame_counts else 0.0

    avg_unknown_visible = round(
        sum(f["unknown_visible"] for f in frame_counts) / len(frame_counts), 2
    ) if frame_counts else 0.0

    match_summary = {
        "source": {
            "player_summary_csv": str(PLAYER_SUMMARY_CSV),
            "team_counts_csv": str(TEAM_COUNTS_CSV),
            "team_summary_csv": str(TEAM_SUMMARY_CSV),
        },
        "stats": {
            "total_players_detected": len(players),
            "stable_players_detected": len(stable_players),
            "unstable_players_detected": len(unstable_players),
            "green_team_stable_players": team_summary["green_team"],
            "red_team_stable_players": team_summary["red_team"],
            "unknown_stable_players": team_summary["unknown"],
            "frames_with_counts": len(frame_counts),
            "max_green_visible": max_green_visible,
            "max_red_visible": max_red_visible,
            "max_unknown_visible": max_unknown_visible,
            "max_total_visible": max_total_visible,
            "avg_green_visible": avg_green_visible,
            "avg_red_visible": avg_red_visible,
            "avg_unknown_visible": avg_unknown_visible,
        },
        "teams": {
            "green_team": green_players,
            "red_team": red_players,
            "unknown": unknown_players,
        },
        "all_players": players,
        "frame_counts": frame_counts,
    }

    return match_summary


def main():
    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)

    match_summary = build_match_summary()

    with open(OUTPUT_JSON, "w", encoding="utf-8") as f:
        json.dump(match_summary, f, ensure_ascii=False, indent=2)

    print("\n=== JSON EXPORTADO ===")
    print(f"Archivo generado: {OUTPUT_JSON}")
    print(f"Jugadores totales: {match_summary['stats']['total_players_detected']}")
    print(f"Jugadores estables: {match_summary['stats']['stable_players_detected']}")
    print(f"Equipo verde: {match_summary['stats']['green_team_stable_players']}")
    print(f"Equipo rojo: {match_summary['stats']['red_team_stable_players']}")
    print(f"Unknown: {match_summary['stats']['unknown_stable_players']}")
    print(f"Frames con conteos: {match_summary['stats']['frames_with_counts']}")


if __name__ == "__main__":
    main()
