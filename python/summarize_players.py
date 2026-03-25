from pathlib import Path
import csv
from collections import defaultdict, Counter


INPUT_CSV = Path("runs/playvision_color/player_tracking_detail.csv")
OUTPUT_DIR = Path("runs/playvision_color")


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


def main():
    if not INPUT_CSV.exists():
        raise FileNotFoundError(f"No existe el archivo: {INPUT_CSV}")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    players = defaultdict(lambda: {
        "frames_detected": 0,
        "first_frame": None,
        "last_frame": None,
        "max_frames_seen": 0,
        "sum_conf": 0.0,
        "sum_color_score": 0.0,
        "green_votes": 0,
        "red_votes": 0,
        "unknown_votes": 0,
        "stable_true_count": 0,
        "x1_sum": 0,
        "y1_sum": 0,
        "x2_sum": 0,
        "y2_sum": 0,
    })

    frame_team_counts = defaultdict(lambda: {
        "green_team": set(),
        "red_team": set(),
        "unknown": set(),
    })

    total_rows = 0

    with open(INPUT_CSV, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)

        for row in reader:
            total_rows += 1

            frame = to_int(row.get("frame"))
            track_id = to_int(row.get("track_id"))
            x1 = to_int(row.get("x1"))
            y1 = to_int(row.get("y1"))
            x2 = to_int(row.get("x2"))
            y2 = to_int(row.get("y2"))
            conf = to_float(row.get("conf"))
            frames_seen = to_int(row.get("frames_seen"))
            frame_team_label = (row.get("frame_team_label") or "unknown").strip()
            color_score = to_float(row.get("color_score"))
            final_team = (row.get("final_team") or "unknown").strip()
            is_stable = to_bool(row.get("is_stable"))

            p = players[track_id]
            p["frames_detected"] += 1
            p["sum_conf"] += conf
            p["sum_color_score"] += color_score
            p["max_frames_seen"] = max(p["max_frames_seen"], frames_seen)
            p["x1_sum"] += x1
            p["y1_sum"] += y1
            p["x2_sum"] += x2
            p["y2_sum"] += y2

            if p["first_frame"] is None or frame < p["first_frame"]:
                p["first_frame"] = frame
            if p["last_frame"] is None or frame > p["last_frame"]:
                p["last_frame"] = frame

            if is_stable:
                p["stable_true_count"] += 1

            if final_team == "green_team":
                p["green_votes"] += 1
                frame_team_counts[frame]["green_team"].add(track_id)
            elif final_team == "red_team":
                p["red_votes"] += 1
                frame_team_counts[frame]["red_team"].add(track_id)
            else:
                p["unknown_votes"] += 1
                frame_team_counts[frame]["unknown"].add(track_id)

            if frame_team_label not in ("green_team", "red_team", "unknown"):
                frame_team_label = "unknown"

    player_summary_rows = []
    team_counter = Counter()

    for track_id, p in sorted(players.items(), key=lambda item: item[0]):
        frames_detected = p["frames_detected"]
        avg_conf = p["sum_conf"] / frames_detected if frames_detected else 0.0
        avg_color_score = p["sum_color_score"] / frames_detected if frames_detected else 0.0

        avg_x1 = round(p["x1_sum"] / frames_detected) if frames_detected else 0
        avg_y1 = round(p["y1_sum"] / frames_detected) if frames_detected else 0
        avg_x2 = round(p["x2_sum"] / frames_detected) if frames_detected else 0
        avg_y2 = round(p["y2_sum"] / frames_detected) if frames_detected else 0

        votes = {
            "green_team": p["green_votes"],
            "red_team": p["red_votes"],
            "unknown": p["unknown_votes"],
        }
        final_team_player = max(votes, key=votes.get)

        stable_player = p["max_frames_seen"] >= 15 or p["stable_true_count"] > 0

        if stable_player:
            team_counter[final_team_player] += 1

        player_summary_rows.append({
            "track_id": track_id,
            "first_frame": p["first_frame"],
            "last_frame": p["last_frame"],
            "frames_detected": frames_detected,
            "max_frames_seen": p["max_frames_seen"],
            "avg_conf": round(avg_conf, 4),
            "avg_color_score": round(avg_color_score, 4),
            "green_votes": p["green_votes"],
            "red_votes": p["red_votes"],
            "unknown_votes": p["unknown_votes"],
            "final_team_player": final_team_player,
            "stable_player": stable_player,
            "avg_x1": avg_x1,
            "avg_y1": avg_y1,
            "avg_x2": avg_x2,
            "avg_y2": avg_y2,
        })

    player_summary_csv = OUTPUT_DIR / "player_summary.csv"
    with open(player_summary_csv, "w", newline="", encoding="utf-8") as f:
        fieldnames = [
            "track_id",
            "first_frame",
            "last_frame",
            "frames_detected",
            "max_frames_seen",
            "avg_conf",
            "avg_color_score",
            "green_votes",
            "red_votes",
            "unknown_votes",
            "final_team_player",
            "stable_player",
            "avg_x1",
            "avg_y1",
            "avg_x2",
            "avg_y2",
        ]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(player_summary_rows)

    per_frame_team_csv = OUTPUT_DIR / "team_counts_by_frame.csv"
    with open(per_frame_team_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([
            "frame",
            "green_visible",
            "red_visible",
            "unknown_visible",
            "total_visible",
        ])

        for frame in sorted(frame_team_counts.keys()):
            green_count = len(frame_team_counts[frame]["green_team"])
            red_count = len(frame_team_counts[frame]["red_team"])
            unknown_count = len(frame_team_counts[frame]["unknown"])
            writer.writerow([
                frame,
                green_count,
                red_count,
                unknown_count,
                green_count + red_count + unknown_count,
            ])

    team_summary_csv = OUTPUT_DIR / "team_summary.csv"
    with open(team_summary_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["team", "stable_players"])
        writer.writerow(["green_team", team_counter["green_team"]])
        writer.writerow(["red_team", team_counter["red_team"]])
        writer.writerow(["unknown", team_counter["unknown"]])

    print("\n=== RESUMEN FINAL POR JUGADOR ===")
    print(f"Filas leidas del detalle: {total_rows}")
    print(f"Jugadores resumidos: {len(player_summary_rows)}")
    print(f"Jugadores estables verdes: {team_counter['green_team']}")
    print(f"Jugadores estables rojos: {team_counter['red_team']}")
    print(f"Jugadores estables unknown: {team_counter['unknown']}")
    print(f"CSV generado: {player_summary_csv}")
    print(f"CSV generado: {per_frame_team_csv}")
    print(f"CSV generado: {team_summary_csv}")


if __name__ == "__main__":
    main()
