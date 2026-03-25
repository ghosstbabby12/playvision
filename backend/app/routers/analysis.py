from fastapi import APIRouter, BackgroundTasks, HTTPException

from app.schemas.analysis import (
    CreateAnalysisJobRequest,
    AnalysisJobResponse,
    RunAnalysisResponse,
    MatchReportResponse,
)
from app.services.analysis_service import (
    create_analysis_job,
    get_analysis_job,
    run_analysis_job,
    get_match_report,
)

router = APIRouter(prefix="/api/analysis", tags=["analysis"])


@router.post("/jobs", response_model=AnalysisJobResponse)
def create_job(payload: CreateAnalysisJobRequest, background_tasks: BackgroundTasks):
    try:
        job = create_analysis_job(
            match_id=payload.match_id,
            source_url=payload.source_url,
        )
        background_tasks.add_task(run_analysis_job, job["id"])
        return AnalysisJobResponse(**job)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/jobs/{job_id}/run", response_model=RunAnalysisResponse)
def run_job(job_id: str, background_tasks: BackgroundTasks):
    try:
        background_tasks.add_task(run_analysis_job, job_id)
        return RunAnalysisResponse(ok=True, job_id=job_id, status="processing")
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/jobs/{job_id}", response_model=AnalysisJobResponse)
def get_job(job_id: str):
    try:
        job = get_analysis_job(job_id)
        return AnalysisJobResponse(**job)
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.get("/matches/{match_id}/report", response_model=MatchReportResponse)
def match_report(match_id: int):
    try:
        data = get_match_report(match_id)
        return MatchReportResponse(**data)
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
