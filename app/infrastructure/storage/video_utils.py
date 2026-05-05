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
    os.makedirs(os.path.dirname(path), exist_ok=True)
    fps = fps if fps and fps > 0 else 30.0
    size = (int(width), int(height))
    
    # Probamos mp4v primero (el más compatible en Linux/Docker), luego otros
    for codec in ("mp4v", "avc1", "XVID"):
        # Usamos cv2.VideoWriter.fourcc para evitar la advertencia de Pylance
        fourcc = cv2.VideoWriter.fourcc(*codec)
        writer = cv2.VideoWriter(path, fourcc, fps, size)
        
        if writer.isOpened():
            print(f"[video] writer ok codec={codec} path={path}")
            return writer
            
    raise RuntimeError(f"Could not open VideoWriter for {path} with any codec")


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
    
    # type: ignore se usa para que Pylance no moleste con el tipo de opts
    with yt_dlp.YoutubeDL(opts) as ydl:  # type: ignore
        info     = ydl.extract_info(url, download=True)
        expected = ydl.prepare_filename(info)  # type: ignore
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