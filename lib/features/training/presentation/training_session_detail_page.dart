import 'dart:async';

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

  List<SessionExercise> get _exercises =>
      session.exercises.isNotEmpty
          ? session.exercises
          : TrainingSession.defaultExercises(session.category);

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final catColor = TrainingSession.categoryColor(session.category);
    final imageUrl = session.imageUrl ?? TrainingSession.categoryImage(session.category);

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
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                    ),
                  ),
                ),
                Positioned(
                  left: 20, right: 20, bottom: 20,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(6)),
                      child: Text(session.category,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
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
                // Duration + date chips
                Row(children: [
                  _InfoChip(icon: Icons.timer_outlined,        label: '${session.durationMinutes} min', c: c),
                  const SizedBox(width: 10),
                  _InfoChip(icon: Icons.calendar_today_outlined, label: _formatDate(session.createdAt), c: c),
                  const SizedBox(width: 10),
                  _InfoChip(icon: Icons.fitness_center_rounded,
                      label: '${_exercises.length} ejercicios', c: c),
                ]),
                const SizedBox(height: 28),

                // Description
                if (session.description != null && session.description!.isNotEmpty) ...[
                  Text('Descripción',
                      style: TextStyle(color: c.text, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(session.description!,
                      style: TextStyle(color: c.muted, fontSize: 14, height: 1.6)),
                  const SizedBox(height: 28),
                ],

                // Session Plan
                Row(children: [
                  Text('Session Plan',
                      style: TextStyle(color: c.text, fontSize: 15, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('${_exercises.fold(0, (s, e) => s + e.durationMinutes)} min total',
                      style: TextStyle(color: c.muted, fontSize: 12)),
                ]),
                const SizedBox(height: 12),
                ..._exercises.asMap().entries.map((entry) =>
                    _ExerciseRow(
                      index: entry.key,
                      exercise: entry.value,
                      catColor: catColor,
                      isLast: entry.key == _exercises.length - 1,
                      c: c,
                    )),
                const SizedBox(height: 40),

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _startSession(context),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Session',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    style: FilledButton.styleFrom(
                      backgroundColor: catColor,
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

  void _startSession(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _SessionRunnerPage(session: session, exercises: _exercises),
    ));
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
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

// ─── Exercise row with timeline connector ─────────────────────────────────────

class _ExerciseRow extends StatelessWidget {
  final int index;
  final SessionExercise exercise;
  final Color catColor;
  final bool isLast;
  final AppColorTokens c;

  const _ExerciseRow({
    required this.index,
    required this.exercise,
    required this.catColor,
    required this.isLast,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Timeline column
        SizedBox(
          width: 40,
          child: Column(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: catColor.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Text('${index + 1}',
                    style: TextStyle(color: catColor, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(exercise.title,
                    style: TextStyle(color: c.textHi, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(exercise.description,
                    style: TextStyle(color: c.muted, fontSize: 12, height: 1.4)),
              ])),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${exercise.durationMinutes} min',
                    style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─── Session Runner ───────────────────────────────────────────────────────────

class _SessionRunnerPage extends StatefulWidget {
  final TrainingSession session;
  final List<SessionExercise> exercises;

  const _SessionRunnerPage({required this.session, required this.exercises});

  @override
  State<_SessionRunnerPage> createState() => _SessionRunnerPageState();
}

class _SessionRunnerPageState extends State<_SessionRunnerPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late int _secondsLeft;
  bool _running = false;
  bool _finished = false;
  Timer? _timer;
  late AnimationController _pulseController;

  SessionExercise get _current => widget.exercises[_currentIndex];
  int get _totalSeconds => _current.durationMinutes * 60;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _current.durationMinutes * 60;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _running = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _timer?.cancel();
          _running = false;
          _advanceOrFinish();
        }
      });
    });
    setState(() {});
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _advanceOrFinish() {
    if (_currentIndex < widget.exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _secondsLeft = _current.durationMinutes * 60;
        _running = false;
      });
    } else {
      setState(() => _finished = true);
    }
  }

  void _goBack() {
    if (_currentIndex > 0) {
      _timer?.cancel();
      setState(() {
        _currentIndex--;
        _secondsLeft = _current.durationMinutes * 60;
        _running = false;
      });
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress => 1 - (_secondsLeft / _totalSeconds);

  @override
  Widget build(BuildContext context) {
    final catColor = TrainingSession.categoryColor(widget.session.category);
    final c = context.colors;

    if (_finished) return _FinishedScreen(session: widget.session, catColor: catColor, c: c);

    return Scaffold(
      backgroundColor: const Color(0xFF080C10),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            // Header
            Row(children: [
              GestureDetector(
                onTap: () => _confirmExit(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.session.title,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis),
                  Text('Ejercicio ${_currentIndex + 1} de ${widget.exercises.length}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.session.category,
                    style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ]),

            // Progress bar
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentIndex + _progress) / widget.exercises.length,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation(catColor),
                minHeight: 4,
              ),
            ),

            const Spacer(),

            // Timer circle
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(catColor),
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  if (_running)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Container(
                        width: 8, height: 8,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: _pulseController.value),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 16),
                  Text(_formatTime(_secondsLeft),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 48,
                          fontWeight: FontWeight.w900, letterSpacing: -2)),
                  Text(_running ? 'En curso' : (_secondsLeft == _totalSeconds ? 'Listo' : 'Pausado'),
                      style: TextStyle(color: catColor, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ]),
            ),

            const SizedBox(height: 32),

            // Exercise name + description
            Text(_current.title,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(_current.description,
                style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center),

            const Spacer(),

            // Controls
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Previous
              _ControlBtn(
                icon: Icons.skip_previous_rounded,
                onTap: _currentIndex > 0 ? _goBack : null,
                size: 52,
              ),
              const SizedBox(width: 20),
              // Play / Pause
              GestureDetector(
                onTap: _running ? _pauseTimer : _startTimer,
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: catColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: catColor.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2),
                    ],
                  ),
                  child: Icon(
                    _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white, size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Skip
              _ControlBtn(
                icon: Icons.skip_next_rounded,
                onTap: _advanceOrFinish,
                size: 52,
              ),
            ]),
            const SizedBox(height: 32),

            // Upcoming exercises
            if (_currentIndex < widget.exercises.length - 1) ...[
              Row(children: [
                const Text('Siguiente', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.exercises[_currentIndex + 1].title,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis)),
                Text('${widget.exercises[_currentIndex + 1].durationMinutes} min',
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ]),
            ] else ...[
              const Text('Último ejercicio', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    _pauseTimer();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Salir de la sesión?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text('Se perderá el progreso actual.',
            style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () { Navigator.of(context).pop(); _startTimer(); },
            child: const Text('Continuar', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
            child: const Text('Salir', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const _ControlBtn({required this.icon, required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: onTap != null ? Colors.white12 : Colors.white.withValues(alpha: 0.04),
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              color: onTap != null ? Colors.white70 : Colors.white24, size: size * 0.48),
        ),
      );
}

// ─── Finished screen ──────────────────────────────────────────────────────────

class _FinishedScreen extends StatelessWidget {
  final TrainingSession session;
  final Color catColor;
  final AppColorTokens c;

  const _FinishedScreen({
    required this.session,
    required this.catColor,
    required this.c,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF080C10),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: catColor, width: 2),
                ),
                child: Icon(Icons.check_rounded, color: catColor, size: 52),
              ),
              const SizedBox(height: 28),
              const Text('Sesión completada',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text(session.title,
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${session.durationMinutes} min completados',
                    style: TextStyle(color: catColor, fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: catColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Volver al inicio',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ]),
          ),
        ),
      );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

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
