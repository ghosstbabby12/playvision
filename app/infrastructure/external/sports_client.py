import time
from datetime import datetime, timezone
from typing import Any

import requests

from app.core.config import settings


_TTL_FIXTURES = 60
_TTL_STANDINGS = 3600
_TTL_FEATURED = 300


_LEAGUES = {
    "colombia": [
        {"id": "COL1", "name": "Liga BetPlay", "country": "Colombia"},
    ],
    "europe": [
        {"id": "PD", "name": "La Liga", "country": "Spain"},
        {"id": "PL", "name": "Premier League", "country": "England"},
        {"id": "SA", "name": "Serie A", "country": "Italy"},
        {"id": "BL1", "name": "Bundesliga", "country": "Germany"},
        {"id": "FL1", "name": "Ligue 1", "country": "France"},
        {"id": "CL", "name": "Champions League", "country": "Europe"},
    ],
}


_FEATURED_LEAGUE_CODES = {
    league["id"]
    for region in _LEAGUES.values()
    for league in region
}


_fixtures_cache: list[Any] = []
_fixtures_ts: float = 0

_featured_cache: dict[str, list] = {}
_featured_ts: float = 0

_standings_cache: dict[str, list[Any]] = {}
_standings_ts: dict[str, float] = {}


def _normalize_match(m: dict) -> dict:
    competition = m.get("competition", {})
    home = m.get("homeTeam", {})
    away = m.get("awayTeam", {})
    score = m.get("score", {})
    full = score.get("fullTime", {})
    half = score.get("halfTime", {})
    status_raw = m.get("status", "")

    return {
        "fixture": {
            "id": m.get("id"),
            "date": m.get("utcDate"),
            "status": {
                "long": status_raw,
                "short": status_raw[:2] if status_raw else "",
            },
            "minute": m.get("minute"),
        },
        "league": {
            "id": competition.get("code"),
            "name": competition.get("name"),
            "country": competition.get("area", {}).get("name", ""),
            "logo": competition.get("emblem", ""),
            "flag": "",
        },
        "teams": {
            "home": {
                "id": home.get("id"),
                "name": home.get("name", ""),
                "logo": home.get("crest", ""),
                "winner": score.get("winner") == "HOME_TEAM",
            },
            "away": {
                "id": away.get("id"),
                "name": away.get("name", ""),
                "logo": away.get("crest", ""),
                "winner": score.get("winner") == "AWAY_TEAM",
            },
        },
        "goals": {
            "home": full.get("home"),
            "away": full.get("away"),
        },
        "score": {
            "halftime": half,
            "fulltime": full,
        },
    }


class SportsClient:
    BASE = settings.football_data_url

    def _headers(self) -> dict[str, str]:
        return {
            "X-Auth-Token": settings.football_data_api_key,
        }

    def get_featured_fixtures(self) -> dict[str, list]:
        """
        Partidos destacados del día, agrupados por liga.
        Se cachea 5 minutos.
        """
        global _featured_cache, _featured_ts

        if _featured_cache and (time.time() - _featured_ts < _TTL_FEATURED):
            print("[sports_client] returning featured matches from cache")
            return _featured_cache

        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")

        # Puedes probar también con:
        # data = self._get(f"/matches?dateFrom={today}&dateTo={today}")
        data = self._get(f"/matches?date={today}")

        matches = data.get("matches", [])

        print(f"[sports_client] featured date={today}")
        print(f"[sports_client] featured raw matches={len(matches)}")

        competition_codes = [
            m.get("competition", {}).get("code", "")
            for m in matches[:30]
        ]
        print(f"[sports_client] featured sample competition codes={competition_codes}")

        grouped: dict[str, list] = {}

        for m in matches:
            code = m.get("competition", {}).get("code", "")
            if code not in _FEATURED_LEAGUE_CODES:
                continue

            normalized = _normalize_match(m)
            league_name = normalized["league"]["name"] or "Unknown League"
            grouped.setdefault(league_name, []).append(normalized)

        print(f"[sports_client] featured grouped leagues={list(grouped.keys())}")

        _featured_cache = grouped
        _featured_ts = time.time()
        return _featured_cache

    def get_live_fixtures(self) -> list[Any]:
        """
        Partidos en vivo en este momento.
        Cache 1 minuto.
        """
        global _fixtures_cache, _fixtures_ts

        if _fixtures_cache and (time.time() - _fixtures_ts < _TTL_FIXTURES):
            print("[sports_client] returning live matches from cache")
            return _fixtures_cache

        data = self._get("/matches?status=IN_PLAY,PAUSED,LIVE")
        matches = data.get("matches", [])

        print(f"[sports_client] live raw matches={len(matches)}")

        _fixtures_cache = [_normalize_match(m) for m in matches[:15]]
        _fixtures_ts = time.time()
        return _fixtures_cache

    def get_standings(self, league_id: str, season: int) -> list[Any]:
        """
        Tabla de posiciones por código de competición.
        Ejemplo: PL, BL1, PD, COL1.
        """
        key = f"{league_id}_{season}"

        if key in _standings_cache and (time.time() - _standings_ts.get(key, 0) < _TTL_STANDINGS):
            print(f"[sports_client] returning standings from cache key={key}")
            return _standings_cache[key]

        data = self._get(f"/competitions/{league_id}/standings?season={season}")
        standings = data.get("standings", [])

        total_table = next(
            (s.get("table", []) for s in standings if s.get("type") == "TOTAL"),
            [],
        )

        teams = [
            {
                "position": row.get("position"),
                "team": row.get("team", {}).get("name"),
                "logo": row.get("team", {}).get("crest"),
                "played": row.get("playedGames"),
                "won": row.get("won"),
                "drawn": row.get("draw"),
                "lost": row.get("lost"),
                "gf": row.get("goalsFor"),
                "ga": row.get("goalsAgainst"),
                "points": row.get("points"),
                "form": row.get("form", ""),
            }
            for row in total_table[:10]
        ]

        print(f"[sports_client] standings league={league_id} season={season} teams={len(teams)}")

        _standings_cache[key] = teams
        _standings_ts[key] = time.time()
        return teams

    def search_team(self, name: str) -> list[Any]:
        """
        Buscar equipos por nombre.
        """
        data = self._get(f"/teams?name={name}")
        teams = data.get("teams", [])

        print(f"[sports_client] search_team name={name} results={len(teams)}")

        return [
            {
                "id": team.get("id"),
                "name": team.get("name"),
                "country": team.get("area", {}).get("name", ""),
                "logo": team.get("crest", ""),
                "founded": team.get("founded"),
            }
            for team in teams[:10]
        ]

    def leagues_for_region(self, region: str) -> list[Any]:
        return _LEAGUES.get(region, [])

    def _get(self, path: str) -> dict[str, Any]:
        if not settings.football_data_api_key:
            raise Exception("FOOTBALL_DATA_API_KEY is empty")

        url = f"{self.BASE}{path}"
        print(f"[sports_client] GET {url}")

        try:
            resp = requests.get(
                url,
                headers=self._headers(),
                timeout=15,
            )
        except requests.RequestException as exc:
            raise Exception(f"Error connecting to football-data: {exc}") from exc

        print(f"[sports_client] status={resp.status_code}")

        content_type = resp.headers.get("content-type", "")
        print(f"[sports_client] content-type={content_type}")

        if not resp.ok:
            raise Exception(
                f"football-data error {resp.status_code}: {resp.text}"
            )

        try:
            data = resp.json()
        except ValueError as exc:
            raise Exception(
                f"football-data returned non-JSON response: {resp.text[:500]}"
            ) from exc

        if isinstance(data, dict):
            print(f"[sports_client] response keys={list(data.keys())[:20]}")

        return data


sports_client = SportsClient()