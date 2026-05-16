import os
from pathlib import Path

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parents[2]
load_dotenv(dotenv_path=BASE_DIR / ".env")


class Settings:
    # -- Supabase -----------------------------------------------------------------
    supabase_url: str = os.getenv("SUPABASE_URL", "")
    supabase_key: str = os.getenv("SUPABASE_SERVICE_KEY", "")
    storage_bucket: str = os.getenv("STORAGE_BUCKET", "match-videos")

    # -- External APIs ------------------------------------------------------------
    api_key_sports: str = os.getenv("API_KEY_SPORTS", "")
    sports_api_url: str = os.getenv(
        "SPORTS_API_URL",
        "https://v3.football.api-sports.io",
    )

    # football-data.org
    football_data_api_key: str = os.getenv("FOOTBALL_DATA_API_KEY", "")
    football_data_url: str = os.getenv(
        "FOOTBALL_DATA_URL",
        "https://api.football-data.org/v4",
    )

    api_key_news: str = os.getenv("API_KEY_NEWS", "")
    news_api_url: str = os.getenv(
        "NEWS_API_URL",
        "https://newsapi.org/v2/everything",
    )

    # -- Server -------------------------------------------------------------------
    # En Railway, PORT viene seteado por la plataforma.
    api_host: str = os.getenv("API_HOST", "http://127.0.0.1")
    api_port: str = os.getenv("API_PORT", os.getenv("PORT", "8000"))
    railway_public_domain: str = os.getenv("RAILWAY_PUBLIC_DOMAIN", "")

    # URL pública del backend:
    # - local: http://127.0.0.1:8000
    # - Railway: https://<RAILWAY_PUBLIC_DOMAIN>
    backend_public_url: str = os.getenv(
        "BACKEND_PUBLIC_URL",
        f"https://{railway_public_domain}"
        if railway_public_domain
        else f"{api_host}:{api_port}",
    )

    # -- Vision pipeline ----------------------------------------------------------
    model_path: str = os.getenv("MODEL_PATH", "models/best.pt")
    num_players: int = int(os.getenv("NUM_PLAYERS", "22"))
    min_presence: float = float(os.getenv("MIN_PRESENCE", "0.01"))
    ball_radius: int = int(os.getenv("BALL_RADIUS", "80"))
    field_width_m: float = float(os.getenv("FIELD_WIDTH_M", "105.0"))
    fps: float = float(os.getenv("FPS", "30.0"))
    conf_threshold: float = float(os.getenv("CONF_THRESHOLD", "0.35"))
    frame_skip: int = int(os.getenv("FRAME_SKIP", "2"))

    # -- AI / LLM -----------------------------------------------------------------
    groq_api_key: str = os.getenv("GROQ_API_KEY", "")
    groq_model: str = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile")

    # -- Video output -------------------------------------------------------------
    target_width: int = 1280
    videos_dir: Path = BASE_DIR / "annotated_videos"

    @property
    def base_video_url(self) -> str:
        return f"{self.backend_public_url}/videos"


settings = Settings()
settings.videos_dir.mkdir(exist_ok=True)