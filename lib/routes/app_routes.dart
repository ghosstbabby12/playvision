import 'package:flutter/material.dart';
import '../app/main_screen.dart';

class AppRoutes {
  static const home = "/";

  static final routes = <String, WidgetBuilder>{
    home: (context) => const MainScreen(),
  };
}
