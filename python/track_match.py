from pathlib import Path

from pytubefix import YouTube
from ultralytics import YOLO


def get_youtube_stream_url(video_url: str) -> str:
    yt = YouTube(video_url)

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
        raise Exception("No se pudo obtener un stream válido del video de YouTube")

    return stream.url


def main():
    youtube_url = "https://www.youtube.com/watch?v=Pj106_kkZCU"

    output_dir = Path("runs/playvision")
    output_dir.mkdir(parents=True, exist_ok=True)

    direct_stream_url = get_youtube_stream_url(youtube_url)

    model = YOLO("yolo26n.pt")

    results = model.track(
        source=direct_stream_url,
        conf=0.25,
        persist=True,
        stream=True,
        save=True,
        classes=[0, 32],
        project="runs",
        name="playvision_track",
        exist_ok=True,
        tracker="bytetrack.yaml",
    )

    total_frames = 0
    total_person_detections = 0
    total_ball_detections = 0

    for result in results:
        total_frames += 1

        if result.boxes is None:
            continue

        classes = result.boxes.cls.tolist() if result.boxes.cls is not None else []

        persons_in_frame = sum(1 for c in classes if int(c) == 0)
        balls_in_frame = sum(1 for c in classes if int(c) == 32)

        total_person_detections += persons_in_frame
        total_ball_detections += balls_in_frame

        print(
            f"Frame {total_frames}: "
            f"jugadores={persons_in_frame}, "
            f"balones={balls_in_frame}"
        )

    print("\n=== RESUMEN ===")
    print(f"Frames procesados: {total_frames}")
    print(f"Detecciones totales de jugadores: {total_person_detections}")
    print(f"Detecciones totales de balón: {total_ball_detections}")
    print("Salida guardada en: runs/playvision_track")


if __name__ == "__main__":
    main()
