import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_color_tokens.dart';
import '../../../shared/widgets/soccer_logo.dart';
import '../controller/auth_controller.dart';
import 'widgets/login_message_card.dart';
import 'widgets/login_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _controller         = AuthController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onAuthChanged);
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    if (!_controller.isLoading &&
        _controller.errorMessage == null &&
        _controller.successMessage == null &&
        !_controller.isLoginMode == false) {
      if (mounted) Navigator.pushReplacementNamed(context, '/');
    }
    if (mounted) setState(() {});
  }

  void _submit() {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _controller.errorMessage = _controller.isLoginMode
            ? 'Ingresa tu correo y contraseña para continuar.'
            : 'Llena todos los campos para crear tu cuenta.';
      });
      return;
    }

    if (_controller.isLoginMode) {
      _controller.signIn(email, password).then((_) {
        if (!mounted) return;
        if (_controller.errorMessage == null) Navigator.pushReplacementNamed(context, '/');
      });
    } else {
      _controller.signUp(email, password).then((_) {
        if (mounted) _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: SoccerLogo(size: 110)),
                  const SizedBox(height: 32),
                  Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: c.textHi,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _controller.isLoginMode
                        ? 'Inicia sesión o regístrate para continuar'
                        : 'Crea tu cuenta para empezar a analizar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: c.muted,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (_controller.errorMessage != null) ...[
                    LoginMessageCard(
                      text: _controller.errorMessage!,
                      color: Colors.redAccent,
                      icon: Icons.error_outline,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_controller.successMessage != null) ...[
                    LoginMessageCard(
                      text: _controller.successMessage!,
                      color: c.accent,
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(height: 24),
                  ],
                  LoginTextField(
                    controller: _emailController,
                    label: 'Correo Electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  LoginTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 36),
                  _AuthButton(
                    label: _controller.isLoginMode ? 'Iniciar Sesión' : 'Registrarse',
                    isLoading: _controller.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 24),
                  const _OrDivider(),
                  const SizedBox(height: 24),
                  _AuthButton(
                    label: _controller.isLoginMode ? 'Crear una cuenta nueva' : 'Ya tengo una cuenta',
                    isLoading: _controller.isLoading,
                    onPressed: _controller.toggleMode,
                    outlined: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool outlined;

  const _AuthButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final c     = context.colors;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    const padding = EdgeInsets.symmetric(vertical: 18);

    if (outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          side: BorderSide(color: c.surface, width: 2),
          padding: padding,
          shape: shape,
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: c.accent,
        foregroundColor: c.bg,
        padding: padding,
        elevation: 0,
        shape: shape,
      ),
      child: isLoading
          ? SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(color: c.bg, strokeWidth: 2.5),
            )
          : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(child: Divider(color: c.surface, thickness: 2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('O', style: TextStyle(color: c.muted, fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Divider(color: c.surface, thickness: 2)),
      ],
    );
  }
}
