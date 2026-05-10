import time
import requests
from datetime import datetime, timezone
from typing import Any
from app.core.config import settings


_HEADERS = {"X-Auth-Token": settings.football_data_api_key}
_TTL_FIXTURES  = 60
_TTL_STANDINGS = 3600

_LEAGUES = {
    "colombia": [
        {"id": "COL1", "name": "Liga BetPlay", "country": "Colombia"},
    ],
    "europe": [
        {"id": "PD",  "name": "La Liga",          "country": "Spain"},
        {"id": "PL",  "name": "Premier League",   "country": "England"},
        {"id": "SA",  "name": "Serie A",          "country": "Italy"},
        {"id": "BL1", "name": "Bundesliga",       "country": "Germany"},
        {"id": "FL1", "name": "Ligue 1",          "country": "France"},
        {"id": "CL",  "name": "Champions League", "country": "Europe"},
    ],
}

_FEATURED_LEAGUE_CODES = {
    league["id"]
    for region in _LEAGUES.values()
    for league in region
}

_fixtures_cache:  list[Any]           = []
_fixtures_ts:     float               = 0
_featured_cache:  dict[str, list]     = {}
_featured_ts:     float               = 0
_standings_cache: dict[str, list[Any]] = {}
_standings_ts:    dict[str, float]    = {}


def _normalize_match(m: dict) -> dict:
    competition = m.get("competition", {})
    home  = m.get("homeTeam", {})
    away  = m.get("awayTeam", {})
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

    def get_featured_fixtures(self) -> dict[str, list]:
        """Today's fixtures from featured leagues, grouped by league name. Cached 5 min."""
        global _featured_cache, _featured_ts
        if _featured_cache and time.time() - _featured_ts < 300:
            return _featured_cache

        date = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        data = self._get(f"/matches?date={date}")

        grouped: dict[str, list] = {}
        for m in data.get("matches", []):
            code = m.get("competition", {}).get("code", "")
            if code not in _FEATURED_LEAGUE_CODES:
                continue
            normalized = _normalize_match(m)
            name = normalized["league"]["name"]
            grouped.setdefault(name, []).append(normalized)

        _featured_cache = grouped
        _featured_ts    = time.time()
        return _featured_cache

    def get_live_fixtures(self) -> list[Any]:
        """Live matches right now, cached 1 min."""
        global _fixtures_cache, _fixtures_ts
        if _fixtures_cache and time.time() - _fixtures_ts < _TTL_FIXTURES:
            return _fixtures_cache

        data = self._get("/matches?status=IN_PLAY,PAUSED,LIVE")
        _fixtures_cache = [_normalize_match(m) for m in data.get("matches", [])[:15]]
        _fixtures_ts    = time.time()
        return _fixtures_cache

    def get_standings(self, league_id: str, season: int) -> list[Any]:
        """Standings table. league_id is the competition code, e.g. 'PL', 'BL1'."""
        key = f"{league_id}_{season}"
        if key in _standings_cache and time.time() - _standings_ts.get(key, 0) < _TTL_STANDINGS:
            return _standings_cache[key]

        data = self._get(f"/competitions/{league_id}/standings?season={season}")
        standings = data.get("standings", [])

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
        """Search teams by name."""
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
