import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // ── Backend ────────────────────────────────────────────────────────────────
  static String get apiBase =>
      dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';

  static const Duration analysisTimeout = Duration(minutes: 10);

  // ── App ────────────────────────────────────────────────────────────────────
  static const String appName    = 'PlayVision';
  static const String appTagline = 'PLAYVISION';

  // ── Date formats ───────────────────────────────────────────────────────────
  static const String dateTimeFormat = 'dd MMM yyyy · HH:mm';
  static const String dateFormat     = 'dd/MM/yyyy';

  // ── Match status keys (stored in DB) ──────────────────────────────────────
  static const String statusDone       = 'done';
  static const String statusProcessing = 'processing';
  static const String statusUploaded   = 'uploaded';

  // ── Match status labels (displayed in UI) ─────────────────────────────────
  static const String labelAnalysed   = 'Analysed';
  static const String labelProcessing = 'Processing';
  static const String labelUploaded   = 'Uploaded';

  // ── Video source types ────────────────────────────────────────────────────
  static const String sourceUpload  = 'upload';
  static const String sourceYoutube = 'youtube';
}
