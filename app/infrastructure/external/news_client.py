import time
import requests
from app.core.config import settings

_TTL = 1800  # 30 min

_TOPICS = [
    {"id": "ai_football",  "label": "AI Football",  "query": "football artificial intelligence analysis", "lang": "en"},
    {"id": "tactics",      "label": "Tactics",      "query": "football tactics data analysis",            "lang": "en"},
    {"id": "training",     "label": "Training",     "query": "football player fitness performance",       "lang": "en"},
    {"id": "video",        "label": "Video",        "query": "video analysis football scouting",          "lang": "en"},
    {"id": "heatmap",      "label": "Heatmap",      "query": "heatmap football player tracking",          "lang": "en"},
]

_cache:    dict = {}
_cache_ts: dict = {}


class NewsClient:
    BASE = settings.news_api_url

    def get_articles(self, topic_id: str | None = None, max_results: int = 20) -> list:
        topics = [t for t in _TOPICS if topic_id is None or t["id"] == topic_id]
        all_articles: list = []

        for topic in topics:
            try:
                all_articles.extend(self._fetch_topic(topic))
            except Exception as e:
                print(f"[warn] news topic {topic['id']}: {e}")

        all_articles.sort(key=lambda a: a["published_at"], reverse=True)
        return all_articles[:max_results]

    def valid_topic_ids(self) -> list[str]:
        return [t["id"] for t in _TOPICS]

    def _fetch_topic(self, topic: dict) -> list:
        key = topic["id"]
        if key in _cache and time.time() - _cache_ts.get(key, 0) < _TTL:
            return _cache[key]

        resp = requests.get(self.BASE, params={
            "q":        topic["query"],
            "language": topic["lang"],
            "sortBy":   "publishedAt",
            "pageSize": 5,
            "apiKey":   settings.api_key_news,
        }, timeout=10)

        articles = [
            {
                "title":        a["title"],
                "summary":      a.get("description") or "",
                "image":        a.get("urlToImage") or "",
                "url":          a["url"],
                "source":       a["source"]["name"],
                "published_at": a.get("publishedAt", ""),
                "label":        topic["label"],
            }
            for a in resp.json().get("articles", [])
            if a.get("title") and "[Removed]" not in a.get("title", "")
        ]

        _cache[key]    = articles
        _cache_ts[key] = time.time()
        return articles


news_client = NewsClient()
