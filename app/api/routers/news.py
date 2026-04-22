from fastapi import APIRouter, HTTPException
from app.core.config import settings
from app.infrastructure.external.news_client import news_client

router = APIRouter(prefix="/api", tags=["News"])


@router.get("/news")
def get_news(topic: str = None):
    if not settings.api_key_news:
        raise HTTPException(status_code=503, detail="API_KEY_NEWS not configured")

    if topic and topic not in news_client.valid_topic_ids():
        raise HTTPException(
            status_code=400,
            detail=f"Invalid topic. Options: {news_client.valid_topic_ids()}"
        )

    articles = news_client.get_articles(topic_id=topic)
    return {"articles": articles}
