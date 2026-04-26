from datetime import datetime

from fastapi import APIRouter, HTTPException

from app.infrastructure.external.sports_client import sports_client

router = APIRouter(prefix="/api", tags=["Matches"])


@router.get("/live-matches", summary="Partidos en vivo")
def live_matches():
    """Retorna los partidos que están en curso en este momento."""
    try:
        data = sports_client.get_live_fixtures()
        return {"data": data}
    except Exception as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc


@router.get("/standings/{region}", summary="Tabla de posiciones por región")
def standings(region: str, season: int | None = None):
    """
    Retorna la tabla de posiciones para la región indicada.

    - **region**: `colombia` o `europe`
    - **season**: año del torneo (por defecto el año actual)
    """
    leagues = sports_client.leagues_for_region(region)
    if not leagues:
        raise HTTPException(
            status_code=400,
            detail="El parámetro 'region' debe ser 'colombia' o 'europe'.",
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


@router.get("/teams/search", summary="Buscar equipo por nombre")
def search_team(name: str):
    """Busca equipos cuyo nombre coincida con el parámetro `name`."""
    try:
        return {"results": sports_client.search_team(name)}
    except Exception as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
