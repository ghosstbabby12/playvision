import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends ChangeNotifier {
  bool isLoading   = false;
  bool isLoginMode = true;
  String? errorMessage;
  String? successMessage;

  Future<void> signIn(String email, String password) async {
    _startLoading();
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Ha ocurrido un error inesperado.';
    } finally {
      _stopLoading();
    }
  }

  Future<void> signUp(String email, String password) async {
    _startLoading();
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      successMessage = '¡Cuenta creada! Ahora puedes iniciar sesión.';
      isLoginMode = true;
    } on AuthException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Ocurrió un error al registrarte.';
    } finally {
      _stopLoading();
    }
  }

  void toggleMode() {
    isLoginMode    = !isLoginMode;
    errorMessage   = null;
    successMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    errorMessage   = null;
    successMessage = null;
  }

  void _startLoading() {
    isLoading      = true;
    errorMessage   = null;
    successMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    isLoading = false;
    notifyListeners();
  }
}
