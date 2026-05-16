import time
from datetime import datetime, timezone
from typing import Any
from urllib.parse import quote

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


def _public_base_url() -> str:
    """
    Base pública del backend, usando:
    - settings.backend_public_url (config.py)
    - o fallback a localhost:8000 por si acaso.
    """
    base = (
        getattr(settings, "backend_public_url", None)
        or "http://localhost:8000"
    )
    return str(base).rstrip("/")


def _proxy_logo(url: str | None) -> str:
    """
    Convierte una URL de logo remota (crest de football-data, etc.)
    en una URL proxied que pasa por nuestro backend.
    """
    if not url:
        return ""
    encoded = quote(url, safe="")
    return f"{_public_base_url()}/api/logo-proxy?url={encoded}"


def _map_status(status_raw: str) -> dict:
    status_raw = (status_raw or "").upper()

    if status_raw in {"TIMED", "SCHEDULED"}:
        return {"long": "Not Started", "short": "NS", "elapsed": None}

    if status_raw == "IN_PLAY":
        return {"long": "In Play", "short": "1H", "elapsed": None}

    if status_raw == "PAUSED":
        return {"long": "Half Time", "short": "HT", "elapsed": None}

    if status_raw == "FINISHED":
        return {"long": "Finished", "short": "FT", "elapsed": None}

    if status_raw == "POSTPONED":
        return {"long": "Postponed", "short": "PST", "elapsed": None}

    if status_raw == "SUSPENDED":
        return {"long": "Suspended", "short": "SUSP", "elapsed": None}

    if status_raw == "CANCELLED":
        return {"long": "Cancelled", "short": "CANC", "elapsed": None}

    return {"long": status_raw, "short": status_raw, "elapsed": None}


def _normalize_match(m: dict) -> dict:
    competition = m.get("competition", {}) or {}
    home = m.get("homeTeam", {}) or {}
    away = m.get("awayTeam", {}) or {}
    score = m.get("score", {}) or {}
    full = score.get("fullTime", {}) or {}
    half = score.get("halfTime", {}) or {}

    status = _map_status(m.get("status", ""))

    competition_logo = competition.get("emblem") or ""
    home_logo = home.get("crest") or ""
    away_logo = away.get("crest") or ""

    normalized = {
        "fixture": {
            "id": m.get("id"),
            "date": m.get("utcDate"),
            "status": status,
        },
        "league": {
            "id": competition.get("id") or competition.get("code"),
            "name": competition.get("name") or "",
            "country": competition.get("area", {}).get("name", ""),
            "logo": _proxy_logo(competition_logo),
            "flag": "",
        },
        "teams": {
            "home": {
                "id": home.get("id"),
                "name": home.get("name") or "",
                "logo": _proxy_logo(home_logo),
                "winner": score.get("winner") == "HOME_TEAM",
            },
            "away": {
                "id": away.get("id"),
                "name": away.get("name") or "",
                "logo": _proxy_logo(away_logo),
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

    return normalized


class SportsClient:
    BASE = settings.football_data_url

    def _headers(self) -> dict[str, str]:
        return {
            "X-Auth-Token": settings.football_data_api_key,
        }

    def get_featured_fixtures(self) -> dict[str, list]:
        global _featured_cache, _featured_ts

        if _featured_cache and (time.time() - _featured_ts < _TTL_FEATURED):
            print("[sports_client] returning featured matches from cache")
            return _featured_cache

        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        data = self._get(f"/matches?date={today}")
        matches = data.get("matches", [])

        print(f"[sports_client] featured date={today}")
        print(f"[sports_client] featured raw matches={len(matches)}")

        competition_codes = [
            m.get("competition", {}).get("code", "")
            for m in matches[:30]
        ]
        print(
            "[sports_client] featured sample competition codes="
            f"{competition_codes}"
        )

        grouped: dict[str, list] = {}
        debug_count = 0

        for m in matches:
            code = m.get("competition", {}).get("code", "")
            if code not in _FEATURED_LEAGUE_CODES:
                continue

            normalized = _normalize_match(m)

            if debug_count < 5:
                print(
                    "[sports_client] sample logos:",
                    normalized["teams"]["home"]["name"],
                    "home_logo=",
                    normalized["teams"]["home"]["logo"],
                    "| away_logo=",
                    normalized["teams"]["away"]["logo"],
                    "| league_logo=",
                    normalized["league"]["logo"],
                )
                debug_count += 1

            league_name = normalized["league"]["name"] or "Unknown League"
            grouped.setdefault(league_name, []).append(normalized)

        print(f"[sports_client] featured grouped leagues={list(grouped.keys())}")

        _featured_cache = grouped
        _featured_ts = time.time()
        return _featured_cache

    def get_live_fixtures(self) -> list[Any]:
        global _fixtures_cache, _fixtures_ts

        if _fixtures_cache and (time.time() - _fixtures_ts < _TTL_FIXTURES):
            print("[sports_client] returning live matches from cache")
            return _fixtures_cache

        data = self._get("/matches?status=IN_PLAY,PAUSED,LIVE")
        matches = data.get("matches", [])

        print(f"[sports_client] live raw matches={len(matches)}")

        normalized_matches = [_normalize_match(m) for m in matches[:15]]

        for item in normalized_matches[:3]:
            print(
                "[sports_client] live sample logos:",
                item["teams"]["home"]["name"],
                "home_logo=",
                item["teams"]["home"]["logo"],
                "| away_logo=",
                item["teams"]["away"]["logo"],
                "| league_logo=",
                item["league"]["logo"],
            )

        _fixtures_cache = normalized_matches
        _fixtures_ts = time.time()
        return _fixtures_cache

    def get_standings(self, league_id: str, season: int) -> list[Any]:
        key = f"{league_id}_{season}"

        if key in _standings_cache and (
            time.time() - _standings_ts.get(key, 0) < _TTL_STANDINGS
        ):
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
                "logo": _proxy_logo(row.get("team", {}).get("crest")),
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

        print(
            f"[sports_client] standings league={league_id} "
            f"season={season} teams={len(teams)}"
        )

        _standings_cache[key] = teams
        _standings_ts[key] = time.time()
        return teams

    def search_team(self, name: str) -> list[Any]:
        data = self._get(f"/teams?name={name}")
        teams = data.get("teams", [])

        print(f"[sports_client] search_team name={name} results={len(teams)}")

        return [
            {
                "id": team.get("id"),
                "name": team.get("name"),
                "country": team.get("area", {}).get("name", ""),
                "logo": _proxy_logo(team.get("crest", "")),
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
            raise Exception(f"football-data error {resp.status_code}: {resp.text}")

        try:
            data = resp.json()
        except ValueError as exc:
            raise Exception(
                "football-data returned non-JSON response: "
                f"{resp.text[:500]}"
            ) from exc

        if isinstance(data, dict):
            print(f"[sports_client] response keys={list(data.keys())[:20]}")

        return data


sports_client = SportsClient()