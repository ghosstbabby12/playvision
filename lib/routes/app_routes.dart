import 'package:flutter/material.dart';
import '../app/main_screen.dart';
// Asegúrate de que esta ruta coincida donde guardaste el login_page.dart
import '../features/auth/presentation/login_page.dart'; 

class AppRoutes {
  static const main = "/";
  static const login = "/login"; // Nueva ruta para el login

  static final routes = <String, WidgetBuilder>{
    main: (context) => const MainScreen(),
    login: (context) => const LoginPage(),
  };
}