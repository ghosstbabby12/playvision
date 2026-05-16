from datetime import datetime
from urllib.parse import urlparse

import requests
from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import Response

from app.infrastructure.external.sports_client import sports_client

router = APIRouter(prefix="/api", tags=["Matches"])


@router.get("/featured-matches", summary="Featured matches grouped by league")
def featured_matches():
    """
    Today's fixtures from top leagues, grouped by league name.
    Each fixture includes full league (id, logo) and teams (id, logo) objects.
    """
    try:
        return sports_client.get_featured_fixtures()
    except Exception as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc


@router.get("/live-matches", summary="Live matches")
def live_matches():
    """Return live matches with full team and league objects."""
    try:
        return {"data": sports_client.get_live_fixtures()}
    except Exception as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc


@router.get("/standings/{region}", summary="Standings by region")
def standings(region: str, season: int | None = None):
    """
    Return the standings table for the given region.

    - **region**: `colombia` or `europe`
    - **season**: tournament year (defaults to current year)
    """
    leagues = sports_client.leagues_for_region(region)
    if not leagues:
        raise HTTPException(
            status_code=400,
            detail="'region' must be 'colombia' or 'europe'.",
        )

    season = season or datetime.now().year
    result: list[dict] = []

    for league in leagues:
        try:
            teams = sports_client.get_standings(league["id"], season)
            if teams:
                result.append(
                    {
                        "league": league["name"],
                        "country": league["country"],
                        "season": season,
                        "teams": teams,
                    }
                )
        except Exception as exc:
            print(f"[warn] standings {league['name']}: {exc}")

    return {"region": region, "leagues": result}


@router.get("/teams/search", summary="Search team by name")
def search_team(name: str):
    """Search teams whose name matches the `name` parameter."""
    try:
        return {"results": sports_client.search_team(name)}
    except Exception as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc


@router.get("/logo-proxy", summary="Proxy remote logo images")
def logo_proxy(url: str = Query(..., min_length=8)):
    """
    Proxy image requests so Flutter Web doesn't hit third-party crest URLs directly.
    """
    parsed = urlparse(url)

    if parsed.scheme not in {"http", "https"}:
        raise HTTPException(status_code=400, detail="Invalid URL scheme.")

    allowed_hosts = {
        "crests.football-data.org",
        "upload.wikimedia.org",
        "media.api-sports.io",
    }
    if parsed.netloc not in allowed_hosts:
        raise HTTPException(status_code=400, detail="Host not allowed.")

    try:
        resp = requests.get(
            url,
            timeout=20,
            headers={
                "User-Agent": "Mozilla/5.0",
                "Accept": "image/png,image/*;q=0.8,*/*;q=0.5",
                "Referer": "https://www.football-data.org/",
            },
        )
    except requests.RequestException as exc:
        raise HTTPException(status_code=502, detail=f"Proxy fetch failed: {exc}") from exc

    if not resp.ok:
        raise HTTPException(
            status_code=resp.status_code,
            detail=f"Remote image request failed with {resp.status_code}",
        )

    content_type = resp.headers.get("content-type", "").lower()
    if not content_type.startswith("image/"):
        raise HTTPException(status_code=415, detail="Remote resource is not an image.")

    return Response(
        content=resp.content,
        media_type=content_type,
        headers={"Cache-Control": "public, max-age=86400"},
    )