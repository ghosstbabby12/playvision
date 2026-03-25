def generate_recommendations(stats: dict, players: list[dict]) -> list[dict]:
    recommendations = []

    for player in players:
        if not player.get("stable_player", False):
            continue

        track_id = player["track_id"]
        frames = player.get("frames_detected", 0)
        conf = float(player.get("avg_conf", 0))
        team = player.get("team_label", "unknown")

        if frames < 120:
            recommendations.append({
                "track_id": track_id,
                "target_type": "player",
                "priority": "medium",
                "title": "Aumentar participación visible",
                "body": f"El jugador {track_id} del equipo {team} apareció en pocos frames. Revisa su involucramiento ofensivo y defensivo o la cobertura de cámara.",
            })

        if conf < 0.60:
            recommendations.append({
                "track_id": track_id,
                "target_type": "player",
                "priority": "low",
                "title": "Calidad de seguimiento baja",
                "body": f"El jugador {track_id} tuvo confianza promedio baja en el tracking. Conviene mejorar ángulo, iluminación o cercanía de la toma.",
            })

    if stats.get("max_total_visible", 0) < 8:
        recommendations.append({
            "track_id": None,
            "target_type": "match",
            "priority": "high",
            "title": "Cobertura visual limitada",
            "body": "El video muestra pocos jugadores al mismo tiempo. Para análisis táctico real conviene usar un plano más abierto y estable.",
        })

    if stats.get("unknown_stable_players", 0) > 0:
        recommendations.append({
            "track_id": None,
            "target_type": "match",
            "priority": "medium",
            "title": "Ajustar clasificación por uniforme",
            "body": "Hay jugadores sin clasificar. Ajusta los rangos HSV o usa segmentación/embeddings visuales para separar mejor equipos.",
        })

    return recommendations
