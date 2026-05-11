import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_controller.dart';
import 'routes/app_routes.dart';
import 'core/providers/locale_provider.dart';

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

  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => localeProvider),
        ChangeNotifierProvider.value(value: themeController),
      ],
      child: const PlayVisionApp(),
    ),
  );
}

class PlayVisionApp extends StatelessWidget {
  const PlayVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final theme = Provider.of<ThemeController>(context);

    return MaterialApp(
      title: 'PlayVision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: theme.mode,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      initialRoute: session != null ? AppRoutes.main : AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}