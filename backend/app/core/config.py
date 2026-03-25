from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_env: str = "development"
    supabase_url: str
    supabase_service_role_key: str
    analysis_output_bucket: str = "analysis-output"
    yolo_model_path: str = "yolo26n.pt"
    min_track_frames: int = 15
    team_color_threshold: float = 0.08
    min_box_area_ratio: float = 0.002

    model_config = SettingsConfigDict(
        env_file="backend/.env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
