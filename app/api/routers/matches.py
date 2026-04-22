from datetime import datetime
from fastapi import APIRouter, HTTPException
from app.infrastructure.external.sports_client import sports_client

router = APIRouter(prefix="/api", tags=["Matches"])


@router.get("/live-matches")
def live_matches():
    try:
        data = sports_client.get_live_fixtures()
        return {"data": data}
    except Exception as e:
        return {"error": str(e)}


@router.get("/standings/{region}")
def standings(region: str, season: int = None):
    leagues = sports_client.leagues_for_region(region)
    if not leagues:
        raise HTTPException(status_code=400, detail="region must be 'colombia' or 'europe'")

    season  = season or datetime.now().year
    result  = []
    for league in leagues:
        try:
            teams = sports_client.get_standings(league["id"], season)
            if teams:
                result.append({"league": league["name"], "country": league["country"],
                               "season": season, "teams": teams})
        except Exception as e:
            print(f"[warn] standings {league['name']}: {e}")

    return {"region": region, "leagues": result}


@router.get("/teams/search")
def search_team(name: str):
    try:
        return {"results": sports_client.search_team(name)}
    except Exception as e:
        return {"error": str(e)}
