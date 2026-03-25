from fastapi import FastAPI
from app.routers.health import router as health_router
from app.routers.analysis import router as analysis_router

app = FastAPI(title="PlayVision Backend", version="1.0.0")

app.include_router(health_router)
app.include_router(analysis_router)
