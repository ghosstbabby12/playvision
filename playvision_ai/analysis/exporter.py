"""
exporter.py — Supabase persistence layer.

All DB writes live here so the rest of the code stays clean.
Uses a lazy singleton client (initialised once after dotenv loads).
"""
from datetime import datetime
from typing import Optional

from supabase import create_client, Client
import os

_supabase: Client | None = None


def _db() -> Client:
    global _supabase
    if _supabase is None:
        url = os.getenv("SUPABASE_URL")
        key = os.getenv("SUPABASE_SERVICE_KEY")
        if not url or not key:
            raise RuntimeError("SUPABASE_URL / SUPABASE_SERVICE_KEY missing from environment")
        _supabase = create_client(url, key)
    return _supabase


def create_or_update_match(
    team_id: int,
    match_id: Optional[int],
    opponent: str,
    source_type: str,
    video_url: str,
) -> Optional[int]:
    db = _db()
    now = datetime.utcnow().isoformat()
    data = {
        "team_id":     team_id,
        "opponent":    opponent,
        "source_type": source_type,
        "video_url":   video_url,
        "status":      "uploaded",
        "updated_at":  now,
    }

    if match_id:
        db.table("matches").update(data).eq("id", match_id).execute()
        return match_id

    data["match_date"] = now
    data["created_at"] = now
    result = db.table("matches").insert(data).execute()
    return result.data[0]["id"] if result.data else None


def save_match_report(match_id: int, team_id: int, payload: dict) -> None:
    now = datetime.utcnow().isoformat()
    _db().table("match_reports").insert({
        "match_id":    match_id,
        "summary_json": payload,
        "created_at":  now,
        "updated_at":  now,
    }).execute()


def save_player_stats(match_id: int, players: list) -> None:
    """
    Insert one row per player into player_match_stats.
    Columns must already exist in the DB schema.
    """
    now  = datetime.utcnow().isoformat()
    rows = [
        {
            "match_id":   match_id,
            "player_id":  None,
            "track_id":   p["track_id"],
            "distance":   p["distance_km"],
            "velocity":   p["speed_ms"],
            "possession": p["possession_pct"],
            "presence":   p["presence_pct"],
            "zone":       p["zone"],
            "created_at": now,
            "updated_at": now,
        }
        for p in players
    ]
    _db().table("player_match_stats").insert(rows).execute()
