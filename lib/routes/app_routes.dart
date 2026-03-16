import 'package:flutter/material.dart';
import '../features/matches/presentation/main_screen.dart';

class AppRoutes {
  static const home = "/";

  static final routes = <String, WidgetBuilder>{
    home: (context) => const MainScreen(),
  };
}
