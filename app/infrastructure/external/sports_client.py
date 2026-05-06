import time
import requests
from datetime import datetime
from typing import Any
from app.core.config import settings


_HEADERS = {"X-Auth-Token": settings.football_data_api_key}
_TTL_FIXTURES  = 60
_TTL_STANDINGS = 3600

# IDs de football-data.org (distintos a API-Sports)
_LEAGUES = {
    "colombia": [
        {"id": "COL1", "name": "Liga BetPlay",  "country": "Colombia"},
    ],
    "europe": [
        {"id": "PD",   "name": "La Liga",          "country": "Spain"},
        {"id": "PL",   "name": "Premier League",   "country": "England"},
        {"id": "SA",   "name": "Serie A",          "country": "Italy"},
        {"id": "BL1",  "name": "Bundesliga",       "country": "Germany"},
        {"id": "FL1",  "name": "Ligue 1",          "country": "France"},
        {"id": "CL",   "name": "Champions League", "country": "Europe"},
    ],
}

_FEATURED_LEAGUE_CODES = {
    l["id"]
    for region in _LEAGUES.values()
    for l in region
}

# Caché en memoria (misma lógica que antes)
_fixtures_cache:  list[Any] = []
_fixtures_ts:     float     = 0
_featured_cache:  list[Any] = []
_featured_ts:     float     = 0
_standings_cache: dict[str, list[Any]] = {}
_standings_ts:    dict[str, float]     = {}


def _normalize_match(m: dict) -> dict:
    """Convierte respuesta de football-data.org al mismo formato
    que usaba API-Sports para no romper nada en routes.py."""
    competition = m.get("competition", {})
    home = m.get("homeTeam", {})
    away = m.get("awayTeam", {})
    score = m.get("score", {})
    full  = score.get("fullTime", {})
    status_raw = m.get("status", "")

    return {
        "fixture": {
            "id":     m.get("id"),
            "date":   m.get("utcDate"),
            "status": {"long": status_raw, "short": status_raw[:2]},
            "minute": m.get("minute"),
        },
        "league": {
            "id":      competition.get("code"),
            "name":    competition.get("name"),
            "country": competition.get("area", {}).get("name", ""),
            "logo":    competition.get("emblem", ""),
            "flag":    "",
        },
        "teams": {
            "home": {
                "id":     home.get("id"),
                "name":   home.get("name", ""),
                "logo":   home.get("crest", ""),
                "winner": score.get("winner") == "HOME_TEAM",
            },
            "away": {
                "id":     away.get("id"),
                "name":   away.get("name", ""),
                "logo":   away.get("crest", ""),
                "winner": score.get("winner") == "AWAY_TEAM",
            },
        },
        "goals": {
            "home": full.get("home"),
            "away": full.get("away"),
        },
        "score": {
            "halftime": score.get("halfTime", {}),
            "fulltime": full,
        },
    }


class SportsClient:
    BASE = settings.football_data_url

    def get_featured_fixtures(self) -> list[Any]:
        """Partidos de hoy de las ligas destacadas, caché 5 min."""
        global _featured_cache, _featured_ts
        if _featured_cache and time.time() - _featured_ts < 300:
            return _featured_cache

        date = datetime.now().strftime("%Y-%m-%d")
        data = self._get(f"/matches?date={date}")
        all_matches = data.get("matches", [])

        result = []
        for m in all_matches:
            code = m.get("competition", {}).get("code", "")
            if code in _FEATURED_LEAGUE_CODES:
                result.append(_normalize_match(m))

        _featured_cache = result[:20]
        _featured_ts    = time.time()
        return _featured_cache

    def get_live_fixtures(self) -> list[Any]:
        """Partidos en vivo ahora mismo, caché 1 min."""
        global _fixtures_cache, _fixtures_ts
        if _fixtures_cache and time.time() - _fixtures_ts < _TTL_FIXTURES:
            return _fixtures_cache

        data = self._get("/matches?status=IN_PLAY,PAUSED,LIVE")
        matches = data.get("matches", [])
        _fixtures_cache = [_normalize_match(m) for m in matches[:15]]
        _fixtures_ts    = time.time()
        return _fixtures_cache

    def get_standings(self, league_id: str, season: int) -> list[Any]:
        """Tabla de posiciones. league_id es el code, ej: 'PL', 'BL1'."""
        key = f"{league_id}_{season}"
        if key in _standings_cache and time.time() - _standings_ts.get(key, 0) < _TTL_STANDINGS:
            return _standings_cache[key]

        data = self._get(f"/competitions/{league_id}/standings?season={season}")
        standings = data.get("standings", [])

        # Tomamos la tabla TOTAL (tipo "TOTAL")
        total_table = next(
            (s["table"] for s in standings if s.get("type") == "TOTAL"),
            []
        )

        teams = [
            {
                "position": r["position"],
                "team":     r["team"]["name"],
                "logo":     r["team"]["crest"],
                "played":   r["playedGames"],
                "won":      r["won"],
                "drawn":    r["draw"],
                "lost":     r["lost"],
                "gf":       r["goalsFor"],
                "ga":       r["goalsAgainst"],
                "points":   r["points"],
                "form":     r.get("form", ""),
            }
            for r in total_table[:10]
        ]
        _standings_cache[key] = teams
        _standings_ts[key]    = time.time()
        return teams

    def search_team(self, name: str) -> list[Any]:
        """Busca equipos por nombre."""
        data = self._get(f"/teams?name={name}")
        return [
            {
                "id":      t["id"],
                "name":    t["name"],
                "country": t.get("area", {}).get("name", ""),
                "logo":    t.get("crest", ""),
                "founded": t.get("founded"),
            }
            for t in data.get("teams", [])[:10]
        ]

    def leagues_for_region(self, region: str) -> list[Any]:
        return _LEAGUES.get(region, [])

    def _get(self, path: str) -> dict[str, Any]:
        resp = requests.get(
            f"{self.BASE}{path}",
            headers=_HEADERS,
            timeout=10,
        )
        return resp.json()


sports_client = SportsClient()