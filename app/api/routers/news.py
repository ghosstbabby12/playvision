from fastapi import APIRouter, HTTPException

from app.core.config import settings
from app.infrastructure.external.news_client import news_client

router = APIRouter(prefix="/api", tags=["News"])


@router.get("/news", summary="Noticias de fútbol")
def get_news(topic: str | None = None):
    """
    Retorna artículos de noticias de fútbol.

    - **topic**: categoría opcional (ver opciones válidas en la API de noticias)
    """
    if not settings.api_key_news:
        raise HTTPException(
            status_code=503,
            detail="La clave API_KEY_NEWS no está configurada en el servidor.",
        )

    valid_topics = news_client.valid_topic_ids()
    if topic and topic not in valid_topics:
        raise HTTPException(
            status_code=400,
            detail=f"Tema inválido. Opciones disponibles: {valid_topics}",
        )

    articles = news_client.get_articles(topic_id=topic)
    return {"articulos": articles}
