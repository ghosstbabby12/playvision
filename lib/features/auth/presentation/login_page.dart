import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/providers/theme_controller.dart';
import '../../../../../core/providers/locale_provider.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../shared/widgets/soccer_logo.dart';
import 'login_controller.dart';

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
    final l10n     = AppLocalizations.of(context)!;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _controller.errorMessage = _controller.isLoginMode
            ? l10n.loginTitle
            : l10n.registerTitle;
      });
      return;
    }

    if (_controller.isLoginMode) {
      _controller.signIn(email, password).then((_) {
        if (!mounted) return;
        if (_controller.errorMessage == null) {
          Navigator.pushReplacementNamed(context, '/');
        }
      });
    } else {
      _controller.signUp(email, password).then((_) {
        if (mounted) _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n            = AppLocalizations.of(context)!;
    final themeController = Provider.of<ThemeController?>(context, listen: true);
    final isDark          = themeController?.isDark ?? true;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF0F4F0),
        body: Stack(children: [

          // ── Background image ───────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.network(
                'https://images.unsplash.com/photo-1518604964608-5ad2e5a2dcb9?w=900&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF0A0F1E), const Color(0xFF061020)]
                          : [const Color(0xFFD6EDD8), const Color(0xFFEAF4EB)],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Animated overlay (dark / light) ───────────────────
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.42, 1.0],
                  colors: isDark
                      ? [
                          Colors.black.withValues(alpha: 0.40),
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.93),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.38),
                          Colors.white.withValues(alpha: 0.62),
                          Colors.white.withValues(alpha: 0.90),
                        ],
                ),
              ),
            ),
          ),

          // ── Scrollable content ─────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF39D353).withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/playvision_logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SoccerLogo(size: 80),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App title
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0D1B0D),
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                    child: Text(l10n.appTitle),
                  ),
                  const SizedBox(height: 8),

                  // AI badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF39D353).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF39D353).withValues(alpha: 0.50),
                          width: 1.2),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: isDark ? const Color(0xFF39D353) : const Color(0xFF1A7A40),
                          size: 12),
                      const SizedBox(width: 6),
                      Text(
                        l10n.loginAiBadge,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF39D353) : const Color(0xFF1A7A40),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.loginTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.55)
                          : const Color(0xFF444444),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Glass card ───────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.87),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.13)
                                : Colors.black.withValues(alpha: 0.07),
                            width: 1.5,
                          ),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.10),
                                    blurRadius: 28,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card title
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF111111),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                              child: Text(
                                _controller.isLoginMode
                                    ? l10n.loginTitle
                                    : l10n.registerTitle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Error banner
                            if (_controller.errorMessage != null) ...[
                              _GlassBanner(
                                text: _controller.errorMessage!,
                                color: const Color(0xFFE53935),
                                icon: Icons.error_outline_rounded,
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Success banner
                            if (_controller.successMessage != null) ...[
                              _GlassBanner(
                                text: _controller.successMessage!,
                                color: const Color(0xFF39D353),
                                icon: Icons.check_circle_outline_rounded,
                              ),
                              const SizedBox(height: 16),
                            ],

                            _GlassField(
                              controller: _emailController,
                              label: l10n.emailHint,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 14),
                            _GlassField(
                              controller: _passwordController,
                              label: l10n.passwordHint,
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 28),

                            _GreenButton(
                              label: _controller.isLoginMode
                                  ? l10n.loginButton
                                  : l10n.registerButton,
                              isLoading: _controller.isLoading,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 20),

                            // Divider
                            Row(children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.18)
                                      : Colors.black.withValues(alpha: 0.12),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  l10n.loginDividerOr,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.45)
                                        : Colors.black.withValues(alpha: 0.35),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.18)
                                      : Colors.black.withValues(alpha: 0.12),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 20),

                            _GlassOutlineButton(
                              label: _controller.isLoginMode
                                  ? l10n.createAccountButton
                                  : l10n.alreadyHaveAccountButton,
                              isLoading: _controller.isLoading,
                              onPressed: _controller.toggleMode,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Top-right: language + theme toggles ────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 20, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LanguageToggle(isDark: isDark),
                    const SizedBox(width: 10),
                    _ThemeToggle(isDark: isDark, onToggle: themeController?.toggle),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Glass text field ──────────────────────────────────────────────────────────

class _GlassField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool isDark;

  const _GlassField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_GlassField> createState() => _GlassFieldState();
}

class _GlassFieldState extends State<_GlassField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final d = widget.isDark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: d
            ? Colors.white.withValues(alpha: 0.09)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: d
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.12),
        ),
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword && _obscure,
        style: TextStyle(
          color: d ? Colors.white : const Color(0xFF111111),
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: widget.label,
          hintStyle: TextStyle(
            color: d
                ? Colors.white.withValues(alpha: 0.40)
                : Colors.black.withValues(alpha: 0.32),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: d
                ? Colors.white.withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.32),
            size: 20,
          ),
          suffixIcon: widget.isPassword
              ? GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: d
                        ? Colors.white.withValues(alpha: 0.38)
                        : Colors.black.withValues(alpha: 0.28),
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────

class _GreenButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GreenButton(
      {required this.label,
      required this.isLoading,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFF39D353),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF39D353).withValues(alpha: 0.38),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 2.5))
              : Text(label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  )),
        ),
      ),
    );
  }
}

class _GlassOutlineButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isDark;

  const _GlassOutlineButton(
      {required this.label,
      required this.isLoading,
      required this.onPressed,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 54,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.14),
          ),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF111111),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
        ),
      ),
    );
  }
}

// ── Banner ────────────────────────────────────────────────────────────────────

class _GlassBanner extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _GlassBanner(
      {required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

// ── Language toggle ───────────────────────────────────────────────────────────

class _LanguageToggle extends StatelessWidget {
  final bool isDark;
  const _LanguageToggle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final localeProvider =
        Provider.of<LocaleProvider?>(context, listen: true);
    final isEn = (localeProvider?.locale.languageCode ?? 'es') == 'en';
    const h = 32.0;

    return GestureDetector(
      onTap: () => localeProvider?.setLocale(Locale(isEn ? 'es' : 'en')),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: h,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(h / 2),
          border: Border.all(
              color: const Color(0xFF39D353).withValues(alpha: 0.55),
              width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.language_rounded,
              size: 16, color: Color(0xFF39D353)),
          const SizedBox(width: 6),
          Text(isEn ? 'EN' : 'ES',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF111111),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              )),
        ]),
      ),
    );
  }
}

// ── Theme toggle ──────────────────────────────────────────────────────────────

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onToggle;
  const _ThemeToggle({required this.isDark, this.onToggle});

  @override
  Widget build(BuildContext context) {
    const w = 64.0;
    const h = 32.0;
    const circle = 24.0;
    const pad = (h - circle) / 2;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(h / 2),
          border: Border.all(
            color: isDark
                ? const Color(0xFF39D353)
                : const Color(0xFF39D353).withValues(alpha: 0.70),
            width: 1.5,
          ),
        ),
        child: Stack(children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            left: isDark ? w / 2 - 2 : null,
            right: isDark ? null : w / 2 - 2,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                size: 14,
                color: isDark
                    ? const Color(0xFF39D353)
                    : const Color(0xFFF59E0B),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            left: isDark ? pad : w - circle - pad,
            top: pad,
            child: Container(
              width: circle,
              height: circle,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
