import 'package:flutter/material.dart';

class SessionExercise {
  final String title;
  final int durationMinutes;
  final String description;

  const SessionExercise({
    required this.title,
    required this.durationMinutes,
    required this.description,
  });

  factory SessionExercise.fromJson(Map<String, dynamic> json) => SessionExercise(
        title: json['title'] as String? ?? '',
        durationMinutes: json['duration_minutes'] as int? ?? 10,
        description: json['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'duration_minutes': durationMinutes,
        'description': description,
      };
}

class TrainingSession {
  final int id;
  final int? teamId;
  final String title;
  final String category;
  final int durationMinutes;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final List<SessionExercise> exercises;

  const TrainingSession({
    required this.id,
    this.teamId,
    required this.title,
    required this.category,
    required this.durationMinutes,
    this.description,
    this.imageUrl,
    required this.createdAt,
    this.exercises = const [],
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    final rawEx = json['exercises'];
    final exercises = (rawEx is List)
        ? rawEx.map((e) => SessionExercise.fromJson(e as Map<String, dynamic>)).toList()
        : <SessionExercise>[];
    return TrainingSession(
      id: json['id'] as int,
      teamId: json['team_id'] as int?,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Tactical',
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      exercises: exercises,
    );
  }

  static Color categoryColor(String category) => switch (category) {
        'Tactical'  => const Color(0xFF2D6A4F),
        'Technical' => const Color(0xFF1D5A8A),
        'Physical'  => const Color(0xFF7A5A1D),
        'Set piece' => const Color(0xFF5A2D7A),
        _           => const Color(0xFF2D6A4F),
      };

  static String categoryImage(String category) => switch (category) {
        'Tactical'  => 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&q=80',
        'Technical' => 'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=400&q=80',
        'Physical'  => 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400&q=80',
        'Set piece' => 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&q=80',
        _           => 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&q=80',
      };

  static const categories = ['Tactical', 'Technical', 'Physical', 'Set piece'];

  static List<SessionExercise> defaultExercises(String category) => switch (category) {
    'Tactical' => const [
      SessionExercise(title: 'Warm-up',             durationMinutes: 10, description: 'Activation and positional awareness drills'),
      SessionExercise(title: 'High press shape',     durationMinutes: 20, description: 'Trigger pressing cues and defensive compactness'),
      SessionExercise(title: 'Transition triggers',  durationMinutes: 25, description: 'Counter-press recovery runs after ball loss'),
      SessionExercise(title: 'Scrimmage',            durationMinutes: 15, description: 'Apply concepts in 7v7 game'),
      SessionExercise(title: 'Cool-down',            durationMinutes: 5,  description: 'Stretching and debrief'),
    ],
    'Technical' => const [
      SessionExercise(title: 'Warm-up',             durationMinutes: 10, description: 'Ball mastery and rondos'),
      SessionExercise(title: 'Passing circuits',    durationMinutes: 25, description: 'One-touch passing at pace'),
      SessionExercise(title: 'Positional play',     durationMinutes: 30, description: 'Pattern runs from build-up'),
      SessionExercise(title: 'Finishing',           durationMinutes: 10, description: 'Shots from cutbacks and crosses'),
    ],
    'Physical' => const [
      SessionExercise(title: 'Dynamic warm-up',    durationMinutes: 10, description: 'Mobility and activation'),
      SessionExercise(title: 'Interval runs',      durationMinutes: 20, description: 'High-intensity sprint intervals'),
      SessionExercise(title: 'Endurance block',    durationMinutes: 25, description: 'Sustained effort at 75% max HR'),
      SessionExercise(title: 'Strength & core',   durationMinutes: 5,  description: 'Core and lower-body activation'),
    ],
    'Set piece' => const [
      SessionExercise(title: 'Warm-up',            durationMinutes: 10, description: 'Shape practice and communication'),
      SessionExercise(title: 'Corner routines',    durationMinutes: 15, description: 'Near post, far post, flick-on'),
      SessionExercise(title: 'Free kicks',         durationMinutes: 15, description: 'Direct and layoff variations'),
      SessionExercise(title: 'Defensive set pieces', durationMinutes: 5, description: 'Zonal vs man-marking'),
    ],
    _ => const [
      SessionExercise(title: 'Warm-up',    durationMinutes: 10, description: 'General activation'),
      SessionExercise(title: 'Main block', durationMinutes: 40, description: 'Core session work'),
      SessionExercise(title: 'Cool-down', durationMinutes: 10, description: 'Stretching and recovery'),
    ],
  };
}
