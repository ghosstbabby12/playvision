import 'package:flutter/material.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';
import '../domain/training_session.dart';

class TrainingSessionDetailPage extends StatelessWidget {
  final TrainingSession session;
  final VoidCallback onDelete;

  const TrainingSessionDetailPage({
    super.key,
    required this.session,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c         = context.colors;
    final catColor  = TrainingSession.categoryColor(session.category);
    final imageUrl  = session.imageUrl ?? TrainingSession.categoryImage(session.category);

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          // ── Hero ──────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF080C08),
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: catColor.withValues(alpha: 0.3)),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20, right: 20, bottom: 20,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(session.category,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 10),
                    Text(session.title,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 24,
                            fontWeight: FontWeight.w900, height: 1.2)),
                  ]),
                ),
              ]),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Duration + date strip
                Row(children: [
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: '${session.durationMinutes} min',
                    c: c,
                  ),
                  const SizedBox(width: 10),
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: _formatDate(session.createdAt),
                    c: c,
                  ),
                ]),
                const SizedBox(height: 28),

                // Description
                if (session.description != null && session.description!.isNotEmpty) ...[
                  Text('Description',
                      style: TextStyle(color: c.text, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(session.description!,
                      style: TextStyle(color: c.muted, fontSize: 14, height: 1.6)),
                  const SizedBox(height: 28),
                ],

                // Placeholder content by category
                Text('Session Plan',
                    style: TextStyle(color: c.text, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                ..._buildPlanItems(session.category, c),
                const SizedBox(height: 40),

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Starting: ${session.title}'),
                          backgroundColor: catColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Session',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    style: FilledButton.styleFrom(
                      backgroundColor: TrainingSession.categoryColor(session.category),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlanItems(String category, AppColorTokens c) {
    final plans = switch (category) {
      'Tactical'  => [
          ('Warm-up', '10 min', 'Activation and positional awareness drills'),
          ('Main block', '60 min', 'High press shape + transition triggers'),
          ('Scrimmage', '15 min', 'Apply concepts in 7v7 game'),
          ('Cool-down', '5 min', 'Stretching and debrief'),
        ],
      'Technical' => [
          ('Warm-up', '10 min', 'Ball mastery and rondos'),
          ('Passing circuits', '25 min', 'One-touch passing at pace'),
          ('Positional play', '30 min', 'Pattern runs from build-up'),
          ('Finishing', '10 min', 'Shots from cutbacks and crosses'),
        ],
      'Physical'  => [
          ('Dynamic warm-up', '10 min', 'Mobility and activation'),
          ('Interval runs', '20 min', 'High-intensity sprint intervals'),
          ('Endurance block', '25 min', 'Sustained effort at 75% max HR'),
          ('Strength', '5 min', 'Core and lower-body activation'),
        ],
      'Set piece' => [
          ('Warm-up', '10 min', 'Shape practice and communication'),
          ('Corner routines', '15 min', 'Near post, far post, flick-on'),
          ('Free kicks', '15 min', 'Direct and layoff variations'),
          ('Defensive set pieces', '5 min', 'Zonal vs man-marking'),
        ],
      _           => <(String, String, String)>[],
    };

    return plans.map((item) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: TrainingSession.categoryColor(category).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(item.$2,
              style: TextStyle(
                  color: TrainingSession.categoryColor(category),
                  fontSize: 11, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.$1,
              style: TextStyle(color: c.textHi, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(item.$3, style: TextStyle(color: c.muted, fontSize: 12)),
        ])),
      ]),
    )).toList();
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete session?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text('This will permanently remove "${session.title}".',
            style: const TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColorTokens c;
  const _InfoChip({required this.icon, required this.label, required this.c});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: c.muted, size: 14),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      );
}
