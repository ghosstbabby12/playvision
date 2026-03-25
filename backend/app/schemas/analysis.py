from typing import Optional, Any
from pydantic import BaseModel


class HealthResponse(BaseModel):
    status: str


class CreateAnalysisJobRequest(BaseModel):
    match_id: int
    source_url: Optional[str] = None


class AnalysisJobResponse(BaseModel):
    id: str
    match_id: int
    status: str
    source_type: Optional[str] = None
    source_url: Optional[str] = None
    error_message: Optional[str] = None


class RunAnalysisResponse(BaseModel):
    ok: bool
    job_id: str
    status: str


class MatchReportResponse(BaseModel):
    match_id: int
    report: dict[str, Any]
    players: list[dict[str, Any]]
    recommendations: list[dict[str, Any]]
