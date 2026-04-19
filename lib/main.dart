import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
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

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const PlayVisionApp());
}

class PlayVisionApp extends StatelessWidget {
  const PlayVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        title: 'PlayVision',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.mode,
        initialRoute: session != null ? AppRoutes.main : AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}
