"""
player_queries.py — Read-only Supabase queries for the player profile endpoint.
"""
from __future__ import annotations
from .exporter import _db


def get_player_profile(player_id: int) -> dict | None:
    """Return player row from `players` table, or None if not found."""
    try:
        res = _db().table("players").select("*").eq("id", player_id).maybe_single().execute()
        return res.data
    except Exception:
        return None


def get_player_last_stats(player_id: int) -> dict | None:
    """Most recent row from `player_stats` for this player."""
    try:
        res = (
            _db()
            .table("player_stats")
            .select("*")
            .eq("player_id", player_id)
            .order("updated_at", desc=True)
            .limit(1)
            .execute()
        )
        return res.data[0] if res.data else None
    except Exception:
        return None


def get_player_history(player_id: int, limit: int = 6) -> list[dict]:
    """Last `limit` stat rows ordered newest-first (for the rating sparkline)."""
    try:
        res = (
            _db()
            .table("player_stats")
            .select("rating, updated_at, goals, assists, minutes")
            .eq("player_id", player_id)
            .order("updated_at", desc=True)
            .limit(limit)
            .execute()
        )
        return res.data or []
    except Exception:
        return []


def get_team_players(team_id: int) -> list[dict]:
    """All players for a team, ordered by overall rating descending."""
    try:
        res = (
            _db()
            .table("players")
            .select("*")
            .eq("team_id", team_id)
            .order("overall", desc=True)
            .execute()
        )
        return res.data or []
    except Exception:
        return []


def get_player_match_stats(player_id: int, limit: int = 5) -> list[dict]:
    """Stats from `player_match_stats` linked to a real player id."""
    try:
        res = (
            _db()
            .table("player_match_stats")
            .select("distance, velocity, possession, zone, created_at")
            .eq("player_id", player_id)
            .order("created_at", desc=True)
            .limit(limit)
            .execute()
        )
        return res.data or []
    except Exception:
        return []
