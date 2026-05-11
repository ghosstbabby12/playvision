import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _languageCodeKey = 'languageCode';

  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  LocaleProvider();

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_languageCodeKey);

    if (languageCode != null && ['en', 'es'].contains(languageCode)) {
      _locale = Locale(languageCode);
    } else {
      _locale = const Locale('es');
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'es'].contains(locale.languageCode)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
  }

  Future<void> clearLocale() async {
    _locale = const Locale('es');
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageCodeKey);
  }

  bool get isSpanish => _locale.languageCode == 'es';

  bool get isEnglish => _locale.languageCode == 'en';
}