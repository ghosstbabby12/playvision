from pathlib import Path
import csv
import cv2
import numpy as np
from pytubefix import YouTube
from ultralytics import YOLO


YOUTUBE_URL = "https://www.youtube.com/watch?v=Pj106_kkZCU"
MODEL_PATH = "yolo26n.pt"

MIN_TRACK_FRAMES = 15
MIN_BOX_AREA_RATIO = 0.002
TEAM_COLOR_THRESHOLD = 0.08


def download_youtube_video(url: str) -> str:
    temp_dir = Path("temp_videos")
    temp_dir.mkdir(parents=True, exist_ok=True)

    yt = YouTube(url)

    stream = (
        yt.streams
        .filter(progressive=True, file_extension="mp4")
        .order_by("resolution")
        .desc()
        .first()
    )

    if stream is None:
        stream = yt.streams.get_highest_resolution()

    if stream is None:
        raise Exception("No se pudo obtener un stream válido de YouTube")

    file_path = stream.download(output_path=str(temp_dir), filename="match_input.mp4")
    return file_path


def clamp(v, min_v, max_v):
    return max(min_v, min(int(v), max_v))


def get_final_team(votes: dict) -> str:
    green = votes.get("green_team", 0)
    red = votes.get("red_team", 0)

    if green == 0 and red == 0:
        return "unknown"

    if green >= red:
        return "green_team"

    return "red_team"


def classify_team_by_color(frame, box):
    h, w = frame.shape[:2]
    x1, y1, x2, y2 = box

    x1 = clamp(x1, 0, w - 1)
    y1 = clamp(y1, 0, h - 1)
    x2 = clamp(x2, 0, w - 1)
    y2 = clamp(y2, 0, h - 1)

    if x2 <= x1 or y2 <= y1:
        return "unknown", 0.0

    bw = x2 - x1
    bh = y2 - y1

    torso_x1 = x1 + int(bw * 0.20)
    torso_x2 = x2 - int(bw * 0.20)
    torso_y1 = y1 + int(bh * 0.20)
    torso_y2 = y1 + int(bh * 0.60)

    torso_x1 = clamp(torso_x1, 0, w - 1)
    torso_y1 = clamp(torso_y1, 0, h - 1)
    torso_x2 = clamp(torso_x2, 0, w - 1)
    torso_y2 = clamp(torso_y2, 0, h - 1)

    if torso_x2 <= torso_x1 or torso_y2 <= torso_y1:
        return "unknown", 0.0

    roi = frame[torso_y1:torso_y2, torso_x1:torso_x2]
    if roi.size == 0:
        return "unknown", 0.0

    hsv = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)

    green_lower = np.array([35, 40, 40])
    green_upper = np.array([85, 255, 255])

    red_lower_1 = np.array([0, 50, 50])
    red_upper_1 = np.array([10, 255, 255])
    red_lower_2 = np.array([170, 50, 50])
    red_upper_2 = np.array([179, 255, 255])

    green_mask = cv2.inRange(hsv, green_lower, green_upper)
    red_mask_1 = cv2.inRange(hsv, red_lower_1, red_upper_1)
    red_mask_2 = cv2.inRange(hsv, red_lower_2, red_upper_2)
    red_mask = cv2.bitwise_or(red_mask_1, red_mask_2)

    green_ratio = np.count_nonzero(green_mask) / green_mask.size
    red_ratio = np.count_nonzero(red_mask) / red_mask.size

    if green_ratio > red_ratio and green_ratio >= TEAM_COLOR_THRESHOLD:
        return "green_team", green_ratio

    if red_ratio > green_ratio and red_ratio >= TEAM_COLOR_THRESHOLD:
        return "red_team", red_ratio

    return "unknown", max(green_ratio, red_ratio)


def draw_label(frame, text, x1, y1, color):
    y_top = max(0, y1 - 22)
    x2 = min(frame.shape[1] - 1, x1 + 220)
    cv2.rectangle(frame, (x1, y_top), (x2, y1), color, -1)
    cv2.putText(
        frame,
        text,
        (x1 + 4, max(12, y1 - 6)),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.5,
        (255, 255, 255),
        1,
        cv2.LINE_AA,
    )


def main():
    local_video_path = download_youtube_video(YOUTUBE_URL)
    print(f"Video listo en: {local_video_path}")

    cap_meta = cv2.VideoCapture(local_video_path)
    fps = cap_meta.get(cv2.CAP_PROP_FPS)
    if fps <= 0:
        fps = 30.0
    cap_meta.release()

    output_dir = Path("runs/playvision_color")
    output_dir.mkdir(parents=True, exist_ok=True)
    output_video = str(output_dir / "tracked_teams.mp4")

    model = YOLO(MODEL_PATH)

    results = model.track(
        source=local_video_path,
        classes=[0],
        conf=0.40,
        persist=True,
        stream=True,
        save=False,
        verbose=False,
        tracker="python/bytetrack_playvision.yaml",
    )

    writer = None
    frame_rows = []
    per_frame_rows = []

    raw_unique_ids = set()
    track_frames = {}
    team_votes = {}

    frame_index = 0

    for result in results:
        frame_index += 1
        frame = result.orig_img.copy()
        frame_h, frame_w = frame.shape[:2]
        frame_area = frame_h * frame_w

        if writer is None:
            writer = cv2.VideoWriter(
                output_video,
                cv2.VideoWriter_fourcc(*"mp4v"),
                fps,
                (frame_w, frame_h),
            )

        visible_green_ids = set()
        visible_red_ids = set()
        visible_unknown_ids = set()

        if result.boxes is not None and result.boxes.id is not None and result.boxes.xyxy is not None:
            boxes = result.boxes.xyxy.cpu().numpy()
            ids = result.boxes.id.int().cpu().tolist()
            confs = result.boxes.conf.cpu().tolist()
            classes = result.boxes.cls.int().cpu().tolist()

            for box, track_id, conf, cls_id in zip(boxes, ids, confs, classes):
                if cls_id != 0:
                    continue

                x1, y1, x2, y2 = map(int, box)
                box_area = max(0, x2 - x1) * max(0, y2 - y1)

                if box_area < frame_area * MIN_BOX_AREA_RATIO:
                    continue

                raw_unique_ids.add(track_id)
                track_frames[track_id] = track_frames.get(track_id, 0) + 1

                if track_id not in team_votes:
                    team_votes[track_id] = {"green_team": 0, "red_team": 0, "unknown": 0}

                frame_team_label, color_score = classify_team_by_color(frame, (x1, y1, x2, y2))
                team_votes[track_id][frame_team_label] += 1

                final_team = get_final_team(team_votes[track_id])
                is_stable = track_frames[track_id] >= MIN_TRACK_FRAMES

                if final_team == "green_team":
                    color = (0, 255, 0)
                    if is_stable:
                        visible_green_ids.add(track_id)
                elif final_team == "red_team":
                    color = (0, 0, 255)
                    if is_stable:
                        visible_red_ids.add(track_id)
                else:
                    color = (150, 150, 150)
                    if is_stable:
                        visible_unknown_ids.add(track_id)

                state = "stable" if is_stable else "new"
                cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
                draw_label(frame, f"ID {track_id} {final_team} {state}", x1, y1, color)

                frame_rows.append([
                    frame_index,
                    track_id,
                    x1,
                    y1,
                    x2,
                    y2,
                    round(conf, 4),
                    track_frames[track_id],
                    frame_team_label,
                    round(color_score, 4),
                    final_team,
                    is_stable,
                ])

        per_frame_rows.append([
            frame_index,
            len(visible_green_ids),
            len(visible_red_ids),
            len(visible_unknown_ids),
        ])

        cv2.putText(
            frame,
            f"Frame: {frame_index}",
            (20, 30),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.8,
            (255, 255, 255),
            2,
            cv2.LINE_AA,
        )
        cv2.putText(
            frame,
            f"Verdes visibles estables: {len(visible_green_ids)}",
            (20, 65),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.75,
            (0, 255, 0),
            2,
            cv2.LINE_AA,
        )
        cv2.putText(
            frame,
            f"Rojos visibles estables: {len(visible_red_ids)}",
            (20, 95),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.75,
            (0, 0, 255),
            2,
            cv2.LINE_AA,
        )
        cv2.putText(
            frame,
            f"Sin clasificar estables: {len(visible_unknown_ids)}",
            (20, 125),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.75,
            (180, 180, 180),
            2,
            cv2.LINE_AA,
        )

        writer.write(frame)

    if writer is not None:
        writer.release()

    stable_ids = [tid for tid, n in track_frames.items() if n >= MIN_TRACK_FRAMES]

    stable_green_ids = []
    stable_red_ids = []
    stable_unknown_ids = []

    for tid in stable_ids:
        final_team = get_final_team(team_votes[tid])
        if final_team == "green_team":
            stable_green_ids.append(tid)
        elif final_team == "red_team":
            stable_red_ids.append(tid)
        else:
            stable_unknown_ids.append(tid)

    green_visible_series = [row[1] for row in per_frame_rows]
    red_visible_series = [row[2] for row in per_frame_rows]
    unknown_visible_series = [row[3] for row in per_frame_rows]

    median_green_visible = float(np.median(green_visible_series)) if green_visible_series else 0.0
    median_red_visible = float(np.median(red_visible_series)) if red_visible_series else 0.0
    max_green_visible = int(max(green_visible_series)) if green_visible_series else 0
    max_red_visible = int(max(red_visible_series)) if red_visible_series else 0
    max_unknown_visible = int(max(unknown_visible_series)) if unknown_visible_series else 0

    detail_csv = output_dir / "player_tracking_detail.csv"
    with open(detail_csv, "w", newline="", encoding="utf-8") as f:
        writer_csv = csv.writer(f)
        writer_csv.writerow([
            "frame",
            "track_id",
            "x1",
            "y1",
            "x2",
            "y2",
            "conf",
            "frames_seen",
            "frame_team_label",
            "color_score",
            "final_team",
            "is_stable",
        ])
        writer_csv.writerows(frame_rows)

    per_frame_csv = output_dir / "per_frame_counts.csv"
    with open(per_frame_csv, "w", newline="", encoding="utf-8") as f:
        writer_csv = csv.writer(f)
        writer_csv.writerow([
            "frame",
            "green_visible_stable",
            "red_visible_stable",
            "unknown_visible_stable",
        ])
        writer_csv.writerows(per_frame_rows)

    print("\n=== RESUMEN AJUSTADO ===")
    print(f"IDs unicos crudos: {len(raw_unique_ids)}")
    print(f"IDs estables (>= {MIN_TRACK_FRAMES} frames): {len(stable_ids)}")
    print(f"IDs estables equipo verde: {len(stable_green_ids)}")
    print(f"IDs estables equipo rojo: {len(stable_red_ids)}")
    print(f"IDs estables sin clasificar: {len(stable_unknown_ids)}")
    print(f"Mediana verdes visibles por frame: {median_green_visible:.1f}")
    print(f"Mediana rojos visibles por frame: {median_red_visible:.1f}")
    print(f"Max verdes visibles en un frame: {max_green_visible}")
    print(f"Max rojos visibles en un frame: {max_red_visible}")
    print(f"Max sin clasificar en un frame: {max_unknown_visible}")
    print(f"Video guardado en: {output_video}")
    print(f"CSV detalle guardado en: {detail_csv}")
    print(f"CSV por frame guardado en: {per_frame_csv}")


if __name__ == "__main__":
    main()
