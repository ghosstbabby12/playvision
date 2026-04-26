from fastapi import APIRouter, HTTPException
from analysis.exporter import get_match_players

router = APIRouter(prefix="/api", tags=["Insights"])


def _generate_insights(p: dict) -> list[str]:
    tips: list[str] = []

    # Position
    tips.append(f"Best position detected: {p['best_position']}")

    # Physical load
    km = p["distance_km"]
    if km > 5:
        tips.append(f"High physical load — {km} km covered. Monitor fatigue.")
    elif km < 2:
        tips.append(f"Low activity — only {km} km. Consider increasing involvement.")
    else:
        tips.append(f"Normal physical load — {km} km covered.")

    # Possession
    poss = p["possession_pct"]
    if poss > 25:
        tips.append("Main ball carrier. Key creative player for the team.")
    elif poss < 5:
        tips.append("Low ball contact. Mostly off-ball movement.")

    # Speed
    if p["speed_kmh"] > 18:
        tips.append(f"High pace player — peak {p['speed_kmh']} km/h. Use in transitions.")
    elif p["speed_kmh"] < 8:
        tips.append("Slow average speed. Better suited for positional roles.")

    # Dominant zone
    zones = p.get("heatmap_zones", {})
    if zones:
        top = max(zones, key=zones.get)
        pct = zones[top]
        tips.append(f"Dominant zone: {top} ({pct}% of time). Position accordingly.")

    # Presence
    if p["presence_pct"] < 40:
        tips.append("Low screen presence. Player may have been subbed or off-camera often.")

    return tips


@router.get("/insights/{match_id}")
def match_insights(match_id: int):
    """Coach insights for every player in a match."""
    players = get_match_players(match_id)
    if not players:
        raise HTTPException(status_code=404, detail="Match not found")

    return {
        "match_id": match_id,
        "players": [
            {
                "rank":          p["rank"],
                "best_position": p.get("best_position", "Unknown"),
                "zone":          p["zone"],
                "distance_km":   p["distance_km"],
                "speed_kmh":     p["speed_kmh"],
                "possession_pct": p["possession_pct"],
                "insights":      _generate_insights(p),
            }
            for p in players
        ],
    }


@router.get("/compare/{match_id}")
def compare_players(match_id: int, rank_a: int, rank_b: int):
    """Side-by-side stats comparison between two players."""
    players = get_match_players(match_id)
    if not players:
        raise HTTPException(status_code=404, detail="Match not found")

    index   = {p["rank"]: p for p in players}
    a, b    = index.get(rank_a), index.get(rank_b)

    if not a or not b:
        raise HTTPException(status_code=404, detail="One or both player ranks not found")

    def _summary(p: dict) -> dict:
        return {
            "rank":          p["rank"],
            "best_position": p.get("best_position", "Unknown"),
            "zone":          p["zone"],
            "distance_km":   p["distance_km"],
            "speed_kmh":     p["speed_kmh"],
            "possession_pct": p["possession_pct"],
            "presence_pct":  p["presence_pct"],
            "top_zone":      max(p.get("heatmap_zones", {"?": 0}), key=p.get("heatmap_zones", {"?": 0}).get),
            "insights":      _generate_insights(p),
        }

    return {
        "match_id":  match_id,
        "player_a":  _summary(a),
        "player_b":  _summary(b),
        "winner": {
            "distance":   rank_a if a["distance_km"]    > b["distance_km"]    else rank_b,
            "speed":      rank_a if a["speed_kmh"]      > b["speed_kmh"]      else rank_b,
            "possession": rank_a if a["possession_pct"] > b["possession_pct"] else rank_b,
        },
    }
