import os
import cv2
import requests
from fastapi import HTTPException


def resize_frame(frame, target_width: int):
    h, w = frame.shape[:2]
    if w <= target_width:
        return frame
    scale = target_width / w
    return cv2.resize(frame, (target_width, int(h * scale)), interpolation=cv2.INTER_LINEAR)


def open_writer(path: str, fps: float, width: int, height: int) -> cv2.VideoWriter:
    for codec in ("avc1", "mp4v"):
        writer = cv2.VideoWriter(
            path, cv2.VideoWriter_fourcc(*codec), fps, (width, height)
        )
        if writer.isOpened():
            return writer
    raise RuntimeError("Could not open VideoWriter with any codec")


_PLATFORM_PATTERNS = (
    "youtube.com", "youtu.be", "vimeo.com", "dailymotion.com",
    "twitch.tv", "instagram.com", "twitter.com", "x.com",
    "tiktok.com", "facebook.com", "fb.watch",
)


def download_video(url: str, out_path: str) -> None:
    if any(p in url for p in _PLATFORM_PATTERNS):
        _download_platform(url, out_path)
    else:
        _download_direct(url, out_path)


def _download_platform(url: str, out_path: str) -> None:
    try:
        import yt_dlp
    except ImportError:
        raise HTTPException(status_code=500, detail="yt-dlp not installed")

    opts = {
        "format":      "best[ext=mp4][height<=720]/best[ext=mp4]/best",
        "outtmpl":     out_path,
        "quiet":       True,
        "no_warnings": True,
    }
    with yt_dlp.YoutubeDL(opts) as ydl:
        info     = ydl.extract_info(url, download=True)
        expected = ydl.prepare_filename(info)
        if expected != out_path and os.path.exists(expected):
            os.rename(expected, out_path)


def _download_direct(url: str, out_path: str) -> None:
    try:
        resp = requests.get(url, stream=True, timeout=120,
                            headers={"User-Agent": "Mozilla/5.0"})
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Could not reach URL: {e}")
    if resp.status_code != 200:
        raise HTTPException(status_code=400, detail=f"HTTP {resp.status_code}")
    with open(out_path, "wb") as f:
        for chunk in resp.iter_content(chunk_size=1024 * 1024):
            f.write(chunk)
