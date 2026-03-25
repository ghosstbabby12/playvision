from fastapi import APIRouter
from app.schemas.analysis import HealthResponse

router = APIRouter(prefix="/health", tags=["health"])


@router.get("", response_model=HealthResponse)
def health():
    return HealthResponse(status="ok")
