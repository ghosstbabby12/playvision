import time
import requests
from datetime import datetime
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

_fixtures_cache:   dict | None = None
_fixtures_ts:      float       = 0
_standings_cache:  dict        = {}
_standings_ts:     dict        = {}


class SportsClient:
    BASE = "https://v3.football.api-sports.io"

    def get_live_fixtures(self) -> list:
        global _fixtures_cache, _fixtures_ts
        if _fixtures_cache and time.time() - _fixtures_ts < _TTL_FIXTURES:
            return _fixtures_cache

        date = datetime.now().strftime("%Y-%m-%d")
        data = self._get(f"/fixtures?date={date}")
        _fixtures_cache = data.get("response", [])[:15]
        _fixtures_ts    = time.time()
        return _fixtures_cache

    def get_standings(self, league_id: int, season: int) -> list:
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

    def search_team(self, name: str) -> list:
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

    def leagues_for_region(self, region: str) -> list:
        return _LEAGUES.get(region, [])

    def _get(self, path: str) -> dict:
        resp = requests.get(f"{self.BASE}{path}", headers=_HEADERS, timeout=10)
        return resp.json()


sports_client = SportsClient()
