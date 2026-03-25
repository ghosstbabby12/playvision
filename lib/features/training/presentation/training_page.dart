import 'package:flutter/material.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entrenamiento',
                          style: TextStyle(
                            color: Color(0xFFE2E8F4),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          )),
                      SizedBox(height: 4),
                      Text('Gestiona tus sesiones',
                          style: TextStyle(color: Color(0xFF4A5568), fontSize: 13)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2537),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x14FFFFFF)),
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF7C9EBF), size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Stats
            Row(children: const [
              _StatBox('24', 'Sesiones'),
              SizedBox(width: 10),
              _StatBox('3', 'Esta semana'),
              SizedBox(width: 10),
              _StatBox('48h', 'Total'),
            ]),

            const SizedBox(height: 32),
            const _SLabel('SESIONES RECIENTES'),
            const SizedBox(height: 14),

            _SessionCard(
              title: 'Pressing alto y transiciones',
              date: '14 Mar 2026',
              duration: '90 min',
              category: 'Táctica',
              color: const Color(0xFF4A7FA5),
            ),
            _SessionCard(
              title: 'Juego de posición 4-3-3',
              date: '12 Mar 2026',
              duration: '75 min',
              category: 'Técnica',
              color: const Color(0xFF3D7A5E),
            ),
            _SessionCard(
              title: 'Preparación física pretemporada',
              date: '10 Mar 2026',
              duration: '60 min',
              category: 'Físico',
              color: const Color(0xFF7A6A3D),
            ),
            _SessionCard(
              title: 'Balón parado — córners ofensivos',
              date: '8 Mar 2026',
              duration: '45 min',
              category: 'Set piece',
              color: const Color(0xFF5A4A7A),
            ),

            const SizedBox(height: 28),

            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2537),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x1AFFFFFF)),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xFF7C9EBF), size: 18),
                    SizedBox(width: 8),
                    Text('Nueva sesión',
                        style: TextStyle(
                          color: Color(0xFFE2E8F4),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                  color: Color(0xFFE2E8F4),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Color(0xFF4A5568), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String title;
  final String date;
  final String duration;
  final String category;
  final Color color;

  const _SessionCard({
    required this.title,
    required this.date,
    required this.duration,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fitness_center_outlined, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F4),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 5),
                Text('$date · $duration',
                    style: const TextStyle(color: Color(0xFF4A5568), fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(category,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SLabel extends StatelessWidget {
  final String text;
  const _SLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF4A5568),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }
}
