import 'package:flutter/material.dart';
import '../../features/live_matches/data/match_model.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    // Definimos el color verde oscuro que usas de fondo en tu diseño
    final backgroundColor = Color(0xFF0D1B14); // Ajusta al color hexadecimal exacto de tu app

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: Colors.white12, width: 1)), // Línea separadora
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // COLUMNA 1: Hora y Fecha (o Minutos jugados si es en vivo)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.elapsed > 0 ? "En Vivo" : "Programado", // Si el minuto > 0, está en vivo
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Text(
                match.elapsed > 0 ? "${match.elapsed}'" : "18:51", // Muestra el minuto actual
                style: TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "Hoy", // Aquí puedes formatear la fecha real que viene de la API
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),

          SizedBox(width: 16),

          // COLUMNA 2: Equipos y Marcador (El centro de tu diseño)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Logo/Inicial Equipo Local
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.green.withValues(alpha: 0.2),
                  child: match.homeLogo.isNotEmpty 
                      ? Image.network(match.homeLogo, width: 16, height: 16)
                      : Text(match.homeTeam[0], style: TextStyle(color: Colors.green, fontSize: 12)),
                ),
                SizedBox(width: 8),
                // Nombre Equipo Local
                Text(
                  match.homeTeam,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                
                // Texto "vs" o el MARCADOR EN VIVO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: match.elapsed > 0 
                      // Si el partido empezó, muestra los goles
                      ? Text(
                          "${match.homeGoals} - ${match.awayGoals}",
                          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16),
                        )
                      // Si no, muestra el "vs" de tu diseño
                      : Text("vs", style: TextStyle(color: Colors.white38, fontSize: 12)),
                ),

                // Logo/Inicial Equipo Visitante
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.green.withValues(alpha: 0.2),
                  child: match.awayLogo.isNotEmpty 
                      ? Image.network(match.awayLogo, width: 16, height: 16)
                      : Text(match.awayTeam[0], style: TextStyle(color: Colors.green, fontSize: 12)),
                ),
                SizedBox(width: 8),
                // Nombre Equipo Visitante
                Text(
                  match.awayTeam,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),

          // COLUMNA 3: Botón de la derecha
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Color(0xFF1A262C), // Color oscuro del botón derecho
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text("-", style: TextStyle(color: Colors.white54, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }
}