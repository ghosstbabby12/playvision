from fastapi import APIRouter, HTTPException
from analysis.exporter import get_player_history
from app.api.routers.insights import _generate_insights

router = APIRouter(prefix="/api", tags=["Players"])


def _aggregate(stats: list) -> dict:
    def avg(key):
        vals = [s[key] for s in stats if s.get(key) is not None]
        return round(sum(vals) / len(vals), 2) if vals else 0.0

    zones      = [s["zone"] for s in stats if s.get("zone")]
    positions  = [s["best_position"] for s in stats if s.get("best_position")]
    top_zone   = max(set(zones),     key=zones.count)     if zones     else "Unknown"
    best_pos   = max(set(positions), key=positions.count) if positions else "Unknown"

    return {
        "avg_distance_km":   avg("distance"),
        "avg_speed_kmh":     avg("speed_kmh"),
        "avg_possession_pct": avg("possession"),
        "avg_presence_pct":  avg("presence"),
        "dominant_zone":     top_zone,
        "best_position":     best_pos,
        "matches_analyzed":  len(stats),
    }


def _player_insight(agg: dict) -> list[str]:
    # Build a fake player dict compatible with _generate_insights
    proxy = {
        "best_position":  agg["best_position"],
        "distance_km":    agg["avg_distance_km"],
        "speed_kmh":      agg["avg_speed_kmh"],
        "possession_pct": agg["avg_possession_pct"],
        "presence_pct":   agg["avg_presence_pct"],
        "heatmap_zones":  {agg["dominant_zone"]: 100},
    }
    return _generate_insights(proxy)


@router.get("/player/{track_id}")
def get_player(track_id: int, limit: int = 10):
    """
    Full player profile aggregated across recent matches.
    Uses track_id (the detection ID assigned during analysis).
    """
    history = get_player_history(track_id, limit=limit)
    if not history:
        raise HTTPException(status_code=404, detail="Player not found")

    agg = _aggregate(history)

    return {
        "track_id":       track_id,
        "summary":        agg,
        "insights":       _player_insight(agg),
        "match_history": [
            {
                "match_id":      s["match_id"],
                "distance_km":   s.get("distance"),
                "speed_kmh":     s.get("speed_kmh"),
                "possession_pct": s.get("possession"),
                "zone":          s.get("zone"),
                "best_position": s.get("best_position"),
                "date":          s.get("created_at", "")[:10],
            }
            for s in history
        ],
    }
