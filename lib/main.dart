import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    throw Exception('SUPABASE_URL is missing from the .env file');
  }

  if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    throw Exception('SUPABASE_ANON_KEY is missing from the .env file');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const PlayVisionApp());
}

class PlayVisionApp extends StatelessWidget {
  const PlayVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Revisamos si el usuario ya tiene una sesión iniciada
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'PlayVision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      
      // Si hay sesión iniciada lo mandamos a "/", si no, lo mandamos a "/login"
      initialRoute: session != null ? AppRoutes.main : AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}