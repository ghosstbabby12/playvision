import 'package:flutter/material.dart';

class TrainingSession {
  final int id;
  final int? teamId;
  final String title;
  final String category;
  final int durationMinutes;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  const TrainingSession({
    required this.id,
    this.teamId,
    required this.title,
    required this.category,
    required this.durationMinutes,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) => TrainingSession(
        id: json['id'] as int,
        teamId: json['team_id'] as int?,
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? 'Tactical',
        durationMinutes: json['duration_minutes'] as int? ?? 60,
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

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
}
