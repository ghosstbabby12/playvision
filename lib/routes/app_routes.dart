import 'package:flutter/material.dart';
import '../features/matches/presentation/home_page.dart';

class AppRoutes {
  static const home = "/";

  static final routes = <String, WidgetBuilder>{
    home: (context) => const HomePage(),
  };
}
