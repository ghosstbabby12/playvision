import os
from pathlib import Path

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parents[2]
load_dotenv(dotenv_path=BASE_DIR / ".env", override=True)


class Settings:
    # ── Supabase ──────────────────────────────────────────────────────────────
    supabase_url: str  = os.getenv("SUPABASE_URL", "")
    supabase_key: str  = os.getenv("SUPABASE_SERVICE_KEY", "")

    # ── APIs externas ─────────────────────────────────────────────────────────
    api_key_sports: str = os.getenv("API_KEY_SPORTS", "")
    api_key_news: str   = os.getenv("API_KEY_NEWS", "")

    # ── Servidor ──────────────────────────────────────────────────────────────
    api_host: str = os.getenv("API_HOST", "http://127.0.0.1")
    api_port: str = os.getenv("API_PORT", "8000")

    # ── Pipeline de visión ────────────────────────────────────────────────────
    num_players: int       = int(os.getenv("NUM_PLAYERS",     "22"))
    min_presence: float    = float(os.getenv("MIN_PRESENCE",  "0.01"))
    ball_radius: int       = int(os.getenv("BALL_RADIUS",     "80"))
    field_width_m: float   = float(os.getenv("FIELD_WIDTH_M", "105.0"))
    fps: float             = float(os.getenv("FPS",           "30.0"))
    conf_threshold: float  = float(os.getenv("CONF_THRESHOLD","0.35"))
    frame_skip: int        = int(os.getenv("FRAME_SKIP",      "2"))

    # ── Salida de video ───────────────────────────────────────────────────────
    target_width: int  = 1280
    videos_dir: Path   = BASE_DIR / "annotated_videos"

    @property
    def base_video_url(self) -> str:
        return f"{self.api_host}:{self.api_port}/videos"


settings = Settings()
settings.videos_dir.mkdir(exist_ok=True)
