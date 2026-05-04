def build_analysis_prompt(result: dict, opponent: str) -> str:
    team = result.get("team", {})
    players = result.get("players", [])
    by_team = team.get("by_team", {})
    green = by_team.get("green", {})
    red   = by_team.get("red", {})

    player_lines = []
    for p in players:
        player_lines.append(
            f"  - Jugador #{p['rank']} (equipo {p['team']}): posición {p['best_position']}, "
            f"zona {p['zone']}, {p['distance_km']} km, {p['speed_kmh']} km/h, "
            f"{p['possession_pct']}% posesión, presencia {p['presence_pct']}%"
        )
    players_block = "\n".join(player_lines) if player_lines else "  Sin datos de jugadores."

    prompt = f"""Eres un analista táctico de fútbol de élite. Analiza el siguiente partido y proporciona un informe táctico detallado y accionable.

DATOS DEL PARTIDO
=================
Rival: {opponent}
Frames totales: {result.get("frames_total", "N/A")}
Frames analizados: {result.get("frames_analyzed", "N/A")}
Jugadores detectados: {result.get("players_detected", "N/A")}
Pases registrados: {result.get("pass_count", "N/A")}

ESTADÍSTICAS DE EQUIPO
======================
Distancia total: {team.get("total_distance_km", "N/A")} km
Distancia media por jugador: {team.get("avg_distance_km", "N/A")} km
Posesión global: {team.get("possession_pct", "N/A")}%

Equipo Verde ({green.get("player_count", 0)} jugadores):
  Distancia total: {green.get("total_distance_km", "N/A")} km
  Posesión media: {green.get("avg_possession_pct", "N/A")}%

Equipo Rojo ({red.get("player_count", 0)} jugadores):
  Distancia total: {red.get("total_distance_km", "N/A")} km
  Posesión media: {red.get("avg_possession_pct", "N/A")}%

DATOS INDIVIDUALES
==================
{players_block}

INFORME REQUERIDO
=================
Proporciona un análisis estructurado con las siguientes secciones:

1. **Resumen ejecutivo** (2-3 frases sobre el rendimiento global)
2. **Análisis táctico por equipo** (formación inferida, pressing, transiciones)
3. **Jugadores destacados** (el más activo, el de más posesión, el mejor posicionado)
4. **Áreas de mejora** (zonas desprotegidas, desequilibrios físicos, errores tácticos)
5. **Recomendaciones** (3-5 acciones concretas para el entrenador)

Sé directo, técnico y usa terminología de fútbol profesional."""

    return prompt
