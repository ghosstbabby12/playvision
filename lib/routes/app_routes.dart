import 'package:flutter/material.dart';

import '../features/matches/presentation/main_screen.dart';
import '../features/matches/presentation/match_summary_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String matchSummary = '/match-summary';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const MainScreen(),
    matchSummary: (context) => const MatchSummaryPage(),
  };
}
