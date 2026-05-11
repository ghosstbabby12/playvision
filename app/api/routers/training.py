from fastapi import APIRouter, HTTPException
from analysis.exporter import _db

router = APIRouter(prefix="/api", tags=["Training"])

_SUGGESTIONS_BY_FITNESS = {
    "low": [
        {"title": "Fuerza base", "category": "Fuerza", "duration_minutes": 30,
         "description": "Circuito de core y tren inferior con bajo impacto articular."},
        {"title": "Cardio suave", "category": "Resistencia", "duration_minutes": 25,
         "description": "Trote continuo a 60-65% FCmax para mejorar base aeróbica."},
        {"title": "Movilidad articular", "category": "Técnica", "duration_minutes": 20,
         "description": "Rutina de movilidad de cadera, rodilla y tobillo."},
    ],
    "medium": [
        {"title": "Posesión 4v4", "category": "Táctica", "duration_minutes": 40,
         "description": "Rondos y juegos de posesión en espacios reducidos."},
        {"title": "Transiciones ofensivas", "category": "Táctica", "duration_minutes": 35,
         "description": "Ejercicios de contragolpe rápido con finalización."},
        {"title": "Velocidad de arranque", "category": "Velocidad", "duration_minutes": 25,
         "description": "Series de aceleración 10-20 m con recuperación total."},
        {"title": "Conducción y cambio de dirección", "category": "Técnica", "duration_minutes": 30,
         "description": "Circuito de slalom con cambios de ritmo."},
    ],
    "high": [
        {"title": "Partido reducido 8v8", "category": "Táctica", "duration_minutes": 50,
         "description": "SSG con alta intensidad, presión inmediata tras pérdida."},
        {"title": "Resistencia específica", "category": "Resistencia", "duration_minutes": 40,
         "description": "Repeticiones de 200-400 m a ritmo de juego real."},
        {"title": "Remate y definición", "category": "Técnica", "duration_minutes": 30,
         "description": "Combinaciones de pase + remate con portero real."},
    ],
}


def _fitness_level(avg_distance: float, avg_speed: float) -> str:
    score = (avg_distance / 8.0) * 60 + (avg_speed / 25.0) * 40
    if score >= 60:
        return "high"
    if score >= 30:
        return "medium"
    return "low"


def _aggregate_team_stats(rows: list) -> tuple[float, float]:
    def avg(key):
        vals = [r[key] for r in rows if r.get(key) is not None]
        return round(sum(vals) / len(vals), 2) if vals else 0.0
    return avg("distance"), avg("speed_kmh")


@router.get("/training-suggestions")
def training_suggestions():
    """Generic training suggestions (no team context)."""
    return {
        "fitness_level": "medium",
        "insights":      ["Datos insuficientes para personalizar. Sugerencias generales."],
        "suggestions":   _SUGGESTIONS_BY_FITNESS["medium"],
    }


@router.get("/team/{team_id}/training-suggestions")
def team_training_suggestions(team_id: int, limit: int = 5):
    """Training suggestions personalised to a team's recent match stats."""
    try:
        db = _db()

        # Last N matches for the team
        matches_res = (
            db.table("matches")
            .select("id")
            .eq("team_id", team_id)
            .order("match_date", desc=True)
            .limit(limit)
            .execute()
        )
        match_ids = [m["id"] for m in (matches_res.data or [])]

        avg_dist = avg_speed = 0.0
        insights: list[str] = []

        if match_ids:
            try:
                stats_res = (
                    db.table("player_match_stats")
                    .select("distance, speed_kmh")
                    .in_("match_id", match_ids)
                    .execute()
                )
                rows = stats_res.data or []
                avg_dist, avg_speed = _aggregate_team_stats(rows)
            except Exception:
                rows = []

        if avg_dist > 0:
            level = _fitness_level(avg_dist, avg_speed)
            insights = [
                f"Distancia media por jugador: {avg_dist} km.",
                f"Velocidad media: {avg_speed} km/h.",
                f"Nivel de condición estimado: {level}.",
            ]
        else:
            level = "medium"
            insights = ["Sin datos de análisis previos. Sugerencias generales aplicadas."]

        return {
            "team_id":       team_id,
            "fitness_level": level,
            "insights":      insights,
            "suggestions":   _SUGGESTIONS_BY_FITNESS[level],
        }

    except Exception as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
