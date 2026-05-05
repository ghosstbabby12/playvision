import os
import uuid
import traceback
import cv2
from typing import Optional
from fastapi import HTTPException

from app.core.config import settings
from app.infrastructure.storage.video_utils import resize_frame, open_writer

from analysis.detector         import detect_frame, reset_state as reset_detector
from analysis.tracker          import PlayerTracker
from analysis.metrics_engine   import compute_metrics
from analysis.heatmap_engine   import draw_pitch
from analysis.video_heatmap    import VideoHeatmapOverlay
from analysis.team_classifier  import TeamClassifier
from analysis.ar_renderer      import render_frame as ar_render
from analysis.ball_tracker     import BallTracker
from analysis.possession_engine import PossessionEngine
from analysis.pass_detector    import PassLog
from analysis.commentary_engine import CommentaryEngine
from analysis.exporter         import (
    create_or_update_match, save_match_report,
    save_player_stats, upload_video,
)
from analysis.commentary_prompt import build_analysis_prompt
from analysis.id_stabilizer     import IDStabilizer

cfg = settings


def run_pipeline(
    video_path:   str,
    team_id:      int,
    match_id:     Optional[int],
    opponent:     str,
    source_type:  str,
) -> dict:
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise HTTPException(status_code=400, detail="Cannot open video file")

    src_w   = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    src_h   = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    src_fps = cap.get(cv2.CAP_PROP_FPS) or cfg.fps

    scale   = min(1.0, cfg.target_width / src_w)
    out_w   = int(src_w * scale)
    out_h   = int(src_h * scale)
    out_fps = src_fps / cfg.frame_skip

    vid_id     = uuid.uuid4().hex[:8]
    videos_dir = str(cfg.videos_dir)
    ann_path   = os.path.join(videos_dir, f"annotated_{vid_id}.mp4")
    heat_path  = os.path.join(videos_dir, f"heatmap_{vid_id}.mp4")
    writer     = open_writer(ann_path,  out_fps, out_w, out_h)
    heat_wr    = open_writer(heat_path, out_fps, out_w, out_h)

    reset_detector()
    stabilizer   = IDStabilizer(max_dist=120, max_unseen=30)
    tracker      = PlayerTracker(ball_radius=cfg.ball_radius)
    heat_overlay = VideoHeatmapOverlay(width=out_w, height=out_h)
    classifier   = TeamClassifier()
    ball_tracker = BallTracker()
    possession   = PossessionEngine()
    pass_log     = PassLog()
    commentary   = CommentaryEngine(out_w, out_h)

    frame_count = analyzed = 0
    prev_owner: int | None = None
    id_map: dict[int, int] = {}
    next_id    = [0]
    frame_data: list[tuple[int, dict]] = []

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        frame_count += 1
        if frame_count % cfg.frame_skip != 0:
            continue

        frame = resize_frame(frame, cfg.target_width)
        players_full, ball, raw = detect_frame(frame, conf_threshold=cfg.conf_threshold)
        players_full = stabilizer.update(players_full)
        players = {pid: (cx, cy) for pid, (cx, cy, team) in players_full.items()}
        frame_data.append((frame_count, dict(players)))
        classifier.update(frame, raw)

        for pid in players:
            if pid not in id_map:
                next_id[0] += 1
                id_map[pid] = next_id[0]

        ball_stable     = ball_tracker.update(ball)
        ball_possession = ball_stable or ball_tracker.last_known
        # Pass full 3-tuples so tracker records the team per player
        tracker.update(players_full, ball_possession)

        pass_log.tick()
        pass_log.update_positions(players)
        owner = possession.update(players, ball_possession)

        if prev_owner is not None and owner is not None and owner != prev_owner:
            pass_log.try_register(prev_owner, owner, classifier, frame_count)
        prev_owner = owner

        if analyzed % 30 == 0:
            commentary.update(frame_count, players, ball_stable, pass_log.all_passes, classifier)

        ar_frame = ar_render(
            frame, players, ball_stable, pass_log.recent,
            owner, classifier, commentary.latest,
            total_passes=pass_log.total, id_map=id_map,
        )
        writer.write(ar_frame)
        heat_overlay.update(players)
        heat_wr.write(heat_overlay.apply(frame))
        analyzed += 1

    cap.release()
    writer.release()
    heat_wr.release()

    players_out, team_stats = compute_metrics(
        player_data     = tracker.data,
        analyzed_frames = analyzed,
        frame_width     = out_w,
        frame_height    = out_h,
        field_width_m   = cfg.field_width_m,
        fps             = src_fps,
        frame_skip      = cfg.frame_skip,
        num_players     = cfg.num_players,
        min_presence    = cfg.min_presence,
    )

    _generate_player_heatmaps(video_path, frame_data, players_out, vid_id, out_w, out_h, out_fps)

    ann_url  = upload_video(ann_path,  f"annotated_{vid_id}.mp4") or f"{cfg.base_video_url}/annotated_{vid_id}.mp4"
    heat_url = upload_video(heat_path, f"heatmap_{vid_id}.mp4")   or f"{cfg.base_video_url}/heatmap_{vid_id}.mp4"

    for p in players_out:
        fname = f"heat_p{p['rank']}_{vid_id}.mp4"
        path  = os.path.join(videos_dir, fname)
        p["heatmap_video_url"] = upload_video(path, fname) or f"{cfg.base_video_url}/{fname}"

    team_reg = {pid: d["team"] for pid, d in tracker.data.items()}
    for p in players_out:
        p["team"] = team_reg.get(p["track_id"], "unknown")

    result = {
        "frames_total":      frame_count,
        "frames_analyzed":   analyzed,
        "players_detected":  len(players_out),
        "pass_count":        pass_log.total,
        "video_url":         ann_url,
        "heatmap_video_url": heat_url,
        "team":              team_stats,
        "team_summary":      tracker.team_summary(),
        "players":           players_out,
    }

    try:
        from groq import Groq
        groq_client = Groq(api_key=cfg.groq_api_key)
        prompt_text = build_analysis_prompt(result, opponent)
        chat = groq_client.chat.completions.create(
            model=cfg.groq_model,
            messages=[
                {"role": "system", "content": "Eres un analista táctico de fútbol de élite. Responde siempre en español con terminología profesional."},
                {"role": "user",   "content": prompt_text},
            ],
            max_tokens=2048,
        )
        result["ai_analysis"] = chat.choices[0].message.content
    except Exception as e:
        print(f"[warn] Groq analysis: {e}")
        result["ai_analysis"] = None

    try:
        mid = create_or_update_match(
            team_id=team_id, match_id=match_id,
            opponent=opponent, source_type=source_type, video_url=ann_url,
        )
        match_id = match_id or mid
        if match_id:
            save_match_report(match_id, team_id, result)
            try:
                save_player_stats(match_id, players_out)
            except Exception as e:
                print(f"[warn] player stats: {e}")
    except Exception as e:
        print(f"[warn] Supabase persist: {e}")

    return result


def _generate_player_heatmaps(
    video_path: str,
    frame_data: list,
    players_out: list,
    vid_id: str,
    out_w: int,
    out_h: int,
    out_fps: float,
) -> None:
    fd = {fc: fp for fc, fp in frame_data}
    overlays: dict = {}
    writers:  dict = {}
    paths:    dict = {}

    for p in players_out:
        pid  = p["track_id"]
        path = os.path.join(str(cfg.videos_dir), f"heat_p{p['rank']}_{vid_id}.mp4")
        paths[pid]    = path
        overlays[pid] = VideoHeatmapOverlay(width=out_w, height=out_h)
        writers[pid]  = open_writer(path, out_fps, out_w, out_h)

    cap = cv2.VideoCapture(video_path)
    fc  = 0
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        fc += 1
        if fc % cfg.frame_skip != 0:
            continue
        frame   = resize_frame(frame, cfg.target_width)
        fplayers = fd.get(fc, {})
        for pid in paths:
            single = {pid: fplayers[pid]} if pid in fplayers else {}
            overlays[pid].update(single)
            writers[pid].write(overlays[pid].apply(frame))
    cap.release()
    for w in writers.values():
        w.release()
    print(f"[debug] per-player heatmaps: {len(paths)}")
