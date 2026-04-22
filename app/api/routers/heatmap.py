import json
from typing import Optional

from fastapi import APIRouter, HTTPException
from fastapi.responses import Response

from analysis.exporter      import get_match_players
from analysis.heatmap_engine import heatmap_from_positions_sample, encode_heatmap_png, draw_pitch
from analysis.video_heatmap  import overlay_positions_on_frame

router  = APIRouter(prefix="/heatmap", tags=["Heatmap"])
_CANVAS = (1050, 680)


def _get_players_or_404(match_id: int) -> list:
    players = get_match_players(match_id)
    if not players:
        raise HTTPException(status_code=404, detail="Match not found or no player data")
    return players


@router.post("")
async def heatmap_from_json(
    players_json: str = ...,
    player_rank:  str = None,
):
    try:
        players = json.loads(players_json)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid players_json")
    rank  = int(player_rank) if player_rank and player_rank.isdigit() else None
    image = heatmap_from_positions_sample(players, selected_rank=rank)
    return Response(content=encode_heatmap_png(image), media_type="image/png")


@router.get("/{match_id}")
def heatmap_tactical(match_id: int, player_rank: Optional[int] = None):
    players = _get_players_or_404(match_id)
    image   = heatmap_from_positions_sample(players, selected_rank=player_rank)
    return Response(content=encode_heatmap_png(image), media_type="image/png")


@router.get("/{match_id}/overlay")
def heatmap_camera_overlay(match_id: int, player_rank: Optional[int] = None):
    w, h    = _CANVAS
    players = _get_players_or_404(match_id)
    positions = [
        (pos["x"] * w, pos["y"] * h)
        for p in players
        if player_rank is None or p.get("rank") == player_rank
        for pos in p.get("positions_sample", [])
    ]
    result = overlay_positions_on_frame(draw_pitch(w, h), positions)
    return Response(content=encode_heatmap_png(result), media_type="image/png")


@router.get("/{match_id}/players")
def list_players(match_id: int):
    players = _get_players_or_404(match_id)
    return [
        {
            "rank":           p["rank"],
            "track_id":       p["track_id"],
            "zone":           p["zone"],
            "distance_km":    p["distance_km"],
            "speed_kmh":      p["speed_kmh"],
            "possession_pct": p["possession_pct"],
            "presence_pct":   p["presence_pct"],
        }
        for p in players
    ]
