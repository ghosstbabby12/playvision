import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const PlayVisionApp());
}

class PlayVisionApp extends StatelessWidget {
  const PlayVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
