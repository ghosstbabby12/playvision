class PlayerToken {
  final int id;
  final String name;
  final int number;
  final String position;
  final double dx; // 0.0 (left) → 1.0 (right)
  final double dy; // 0.0 (top/attack) → 1.0 (bottom/defense)
  final Map<String, dynamic> stats;

  const PlayerToken({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    required this.dx,
    required this.dy,
    required this.stats,
  });

  PlayerToken copyWith({double? dx, double? dy}) => PlayerToken(
        id: id,
        name: name,
        number: number,
        position: position,
        dx: dx ?? this.dx,
        dy: dy ?? this.dy,
        stats: stats,
      );

  // Normalized radar values (0.0–1.0) for 5 axes: Speed, Pass, Shoot, Defend, Physical
  List<double> get radarValues {
    final dist = (stats['distance'] as num).toDouble();
    final acc  = (stats['passAccuracy'] as num).toDouble();
    final goals = (stats['goals'] as num).toDouble();
    final tackles = (stats['tackles'] as num).toDouble();
    return [
      (dist / 13).clamp(0.0, 1.0),
      acc / 100,
      (goals * 0.3).clamp(0.0, 1.0),
      (tackles / 15).clamp(0.0, 1.0),
      ((dist - 4) / 9).clamp(0.0, 1.0),
    ];
  }
}
