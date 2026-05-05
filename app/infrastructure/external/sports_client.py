import time
import requests
from datetime import datetime
from typing import Any
from app.core.config import settings

_HEADERS = {"x-apisports-key": settings.api_key_sports}
_TTL_FIXTURES  = 60
_TTL_STANDINGS = 3600

_LEAGUES = {
    "colombia": [
        {"id": 239, "name": "Liga BetPlay",    "country": "Colombia"},
        {"id": 241, "name": "Copa Colombia",   "country": "Colombia"},
    ],
    "europe": [
        {"id": 140, "name": "La Liga",          "country": "Spain"},
        {"id":  39, "name": "Premier League",   "country": "England"},
        {"id": 135, "name": "Serie A",          "country": "Italy"},
        {"id":  78, "name": "Bundesliga",       "country": "Germany"},
        {"id":  61, "name": "Ligue 1",          "country": "France"},
        {"id":   2, "name": "Champions League", "country": "Europe"},
    ],
}

_FEATURED_LEAGUE_IDS = {
    l["id"]
    for region in _LEAGUES.values()
    for l in region
}

# Inicializados como listas vacías para evitar problemas de tipos con "None"
_fixtures_cache:   list[Any] = []
_fixtures_ts:      float     = 0
_featured_cache:   list[Any] = []
_featured_ts:      float     = 0
_standings_cache:  dict[str, list[Any]] = {}
_standings_ts:     dict[str, float] = {}

class SportsClient:
    BASE = settings.sports_api_url

    def get_featured_fixtures(self) -> list[Any]:
        """Today's fixtures from featured leagues, cached 5 min."""
        global _featured_cache, _featured_ts
        if _featured_cache and time.time() - _featured_ts < 300:
            return _featured_cache

        date = datetime.now().strftime("%Y-%m-%d")
        data = self._get(f"/fixtures?date={date}")
        all_fixtures = data.get("response", [])

        league_map = {
            l["id"]: l
            for region in _LEAGUES.values()
            for l in region
        }

        result = []
        for f in all_fixtures:
            lid = f.get("league", {}).get("id")
            if lid in _FEATURED_LEAGUE_IDS:
                result.append({
                    "fixture":  f.get("fixture", {}),
                    "league":   league_map.get(lid, f.get("league", {})),
                    "teams":    f.get("teams", {}),
                    "goals":    f.get("goals", {}),
                    "score":    f.get("score", {}),
                })
        _featured_cache = result[:20]
        _featured_ts    = time.time()
        return _featured_cache

    def get_live_fixtures(self) -> list[Any]:
        global _fixtures_cache, _fixtures_ts
        if _fixtures_cache and time.time() - _fixtures_ts < _TTL_FIXTURES:
            return _fixtures_cache

        date = datetime.now().strftime("%Y-%m-%d")
        data = self._get(f"/fixtures?date={date}")
        _fixtures_cache = data.get("response", [])[:15]
        _fixtures_ts    = time.time()
        return _fixtures_cache

    def get_standings(self, league_id: int, season: int) -> list[Any]:
        key = f"{league_id}_{season}"
        if key in _standings_cache and time.time() - _standings_ts.get(key, 0) < _TTL_STANDINGS:
            return _standings_cache[key]

        data     = self._get(f"/standings?league={league_id}&season={season}")
        response = data.get("response", [])
        if not response:
            return []

        rows = response[0].get("league", {}).get("standings", [[]])[0]
        teams = [
            {
                "position": r["rank"],
                "team":     r["team"]["name"],
                "logo":     r["team"]["logo"],
                "played":   r["all"]["played"],
                "won":      r["all"]["win"],
                "drawn":    r["all"]["draw"],
                "lost":     r["all"]["lose"],
                "gf":       r["all"]["goals"]["for"],
                "ga":       r["all"]["goals"]["against"],
                "points":   r["points"],
                "form":     r.get("form", ""),
            }
            for r in rows[:10]
        ]
        _standings_cache[key] = teams
        _standings_ts[key]    = time.time()
        return teams

    def search_team(self, name: str) -> list[Any]:
        data = self._get(f"/teams?search={name}")
        return [
            {
                "id":      t["team"]["id"],
                "name":    t["team"]["name"],
                "country": t["team"]["country"],
                "logo":    t["team"]["logo"],
                "founded": t["team"].get("founded"),
            }
            for t in data.get("response", [])[:10]
        ]

    def leagues_for_region(self, region: str) -> list[Any]:
        return _LEAGUES.get(region, [])

    def _get(self, path: str) -> dict[str, Any]:
        resp = requests.get(f"{self.BASE}{path}", headers=_HEADERS, timeout=10)
        return resp.json()

sports_client = SportsClient()