import 'package:flutter/material.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'ENTRENAMIENTO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE84C1E)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: const Color(0xFFE84C1E)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 4),
          // Stats row
          Row(
            children: [
              _StatBox(label: 'Sesiones', value: '24'),
              const SizedBox(width: 12),
              _StatBox(label: 'Esta semana', value: '3'),
              const SizedBox(width: 12),
              _StatBox(label: 'Horas', value: '48h'),
            ],
          ),
          const SizedBox(height: 28),
          const _SectionLabel('SESIONES RECIENTES'),
          const SizedBox(height: 12),
          _TrainingCard(
            title: 'Pressing alto y transiciones',
            date: '14 Mar 2026',
            duration: '90 min',
            category: 'Táctica',
            categoryColor: Color(0xFF4A90D9),
          ),
          _TrainingCard(
            title: 'Juego de posición 4-3-3',
            date: '12 Mar 2026',
            duration: '75 min',
            category: 'Técnica',
            categoryColor: Color(0xFF2ECC71),
          ),
          _TrainingCard(
            title: 'Preparación física pretemporada',
            date: '10 Mar 2026',
            duration: '60 min',
            category: 'Físico',
            categoryColor: Color(0xFFFFAA00),
          ),
          _TrainingCard(
            title: 'Balón parado — córners ofensivos',
            date: '8 Mar 2026',
            duration: '45 min',
            category: 'Set piece',
            categoryColor: Color(0xFFE84C1E),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'NUEVA SESIÓN',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE84C1E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF888888),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF222222)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFE84C1E),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  final String title;
  final String date;
  final String duration;
  final String category;
  final Color categoryColor;

  const _TrainingCard({
    required this.title,
    required this.date,
    required this.duration,
    required this.category,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.fitness_center, color: categoryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 11, color: Color(0xFF888888)),
                    const SizedBox(width: 4),
                    Text(
                      '$date · $duration',
                      style: const TextStyle(
                          color: Color(0xFF888888), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: categoryColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
