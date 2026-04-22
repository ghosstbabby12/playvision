import os
import uuid
import shutil
import traceback
from typing import Optional

from fastapi import APIRouter, UploadFile, File, Form, HTTPException

from app.core.config import settings
from app.infrastructure.vision.pipeline import run_pipeline
from app.infrastructure.storage.video_utils import download_video

router = APIRouter(tags=["Analysis"])


@router.post("/analyze")
async def analyze_upload(
    team_id:     str           = Form(...),
    match_id:    Optional[str] = Form(None),
    opponent:    str           = Form(""),
    source_type: str           = Form("upload"),
    file:        UploadFile    = File(...),
):
    mid        = int(match_id) if match_id and match_id not in ("null", "") else None
    video_path = str(settings.videos_dir / f"upload_{uuid.uuid4().hex[:8]}_{file.filename}")
    try:
        with open(video_path, "wb") as buf:
            shutil.copyfileobj(file.file, buf)
        return run_pipeline(video_path, int(team_id), mid, opponent, source_type)
    except HTTPException:
        raise
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if os.path.exists(video_path):
            os.remove(video_path)


@router.post("/analyze-url")
async def analyze_url(
    team_id:     str           = Form(...),
    match_id:    Optional[str] = Form(None),
    opponent:    str           = Form(""),
    source_type: str           = Form("url"),
    video_url:   str           = Form(...),
):
    mid        = int(match_id) if match_id and match_id not in ("null", "") else None
    video_path = str(settings.videos_dir / f"remote_{uuid.uuid4().hex[:8]}.mp4")
    try:
        download_video(video_url, video_path)
        if not os.path.exists(video_path) or os.path.getsize(video_path) < 1024:
            raise HTTPException(status_code=400, detail="Downloaded file is empty")
        return run_pipeline(video_path, int(team_id), mid, opponent, source_type)
    except HTTPException:
        raise
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if os.path.exists(video_path):
            os.remove(video_path)
