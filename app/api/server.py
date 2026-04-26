from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import settings
from app.api.routers import analysis, heatmap, matches, news, insights, players


class CORSStaticFiles(StaticFiles):
    async def get_response(self, path: str, scope):
        response = await super().get_response(path, scope)
        response.headers["Access-Control-Allow-Origin"]   = "*"
        response.headers["Access-Control-Allow-Methods"]  = "GET, OPTIONS"
        response.headers["Access-Control-Allow-Headers"]  = "Range, Content-Type, Authorization"
        response.headers["Access-Control-Expose-Headers"] = "Content-Length, Content-Range"
        return response


def create_app() -> FastAPI:
    app = FastAPI(title="PlayVision AI", version="2.0.0")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.mount(
        "/videos",
        CORSStaticFiles(directory=str(settings.videos_dir)),
        name="videos",
    )

    app.include_router(analysis.router)
    app.include_router(heatmap.router)
    app.include_router(matches.router)
    app.include_router(news.router)
    app.include_router(insights.router)
    app.include_router(players.router)

    return app


app = create_app()
