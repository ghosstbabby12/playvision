import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  final Color _bgDark = const Color(0xFF0D0E15);
  final Color _surfaceColor = const Color(0xFF1A1C29);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textMuted = const Color(0xFF8F93A2);

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu correo y contraseña para continuar.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Ha ocurrido un error inesperado.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Llena todos los campos para crear tu cuenta.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      
      setState(() {
        _successMessage = '¡Cuenta creada con éxito! Ahora puedes iniciar sesión.';
        _passwordController.clear();
      });
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Ocurrió un error al registrarte.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nuevo Logo Realista / Tecnológico
                const Center(
                  child: ModernSoccerLogo(size: 110),
                ),
                const SizedBox(height: 32),
                
                const Text(
                  'PlayVision',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia sesión o regístrate para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textMuted, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 48),

                if (_errorMessage != null)
                  _buildMessageCard(_errorMessage!, Colors.redAccent, Icons.error_outline),

                if (_successMessage != null)
                  _buildMessageCard(_successMessage!, _accentGreen, Icons.check_circle_outline),

                if (_errorMessage != null || _successMessage != null)
                  const SizedBox(height: 24),

                _buildTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 36),

                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentGreen,
                    foregroundColor: _bgDark,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: _bgDark, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(child: Divider(color: _surfaceColor, thickness: 2)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('O', style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Divider(color: _surfaceColor, thickness: 2)),
                  ],
                ),
                const SizedBox(height: 24),

                OutlinedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: _surfaceColor, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Crear una cuenta nueva',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      keyboardType: keyboardType,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: _textMuted),
        prefixIcon: Icon(icon, color: _textMuted, size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: _textMuted,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: _surfaceColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _accentGreen, width: 2),
        ),
      ),
    );
  }
}

// ============================================================================
// LOGO PERSONALIZADO (Balón Tecnológico 3D)
// ============================================================================
class ModernSoccerLogo extends StatelessWidget {
  final double size;
  const ModernSoccerLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Brillo sutil de fondo
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ModernSoccerPainter(),
      ),
    );
  }
}

class _ModernSoccerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Círculo base oscuro con gradiente
    final baseGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.0,
      colors: [
        const Color(0xFF2C3248),
        const Color(0xFF13141F),
      ],
    );
    final basePaint = Paint()
      ..shader = baseGradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    // 2. Anillo exterior brillante verde
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = const Color(0xFF00E676);
    canvas.drawCircle(center, radius - 2, ringPaint);

    // 3. Pentágono central
    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF00E676);
    
    final path = Path();
    final pentagonRadius = radius * 0.35;
    for (int i = 0; i < 5; i++) {
      // Rotado -18 grados para que el pentágono quede recto
      final angle = (i * 2 * math.pi / 5) - (math.pi / 2);
      final x = center.dx + pentagonRadius * math.cos(angle);
      final y = center.dy + pentagonRadius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, accentPaint);

    // 4. Líneas conectando el pentágono al borde (Costuras del balón)
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = const Color(0xFF00E676)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - (math.pi / 2);
      
      // Desde los vértices del pentágono
      final startX = center.dx + pentagonRadius * math.cos(angle);
      final startY = center.dy + pentagonRadius * math.sin(angle);
      
      // Hacia el borde
      final endX = center.dx + (radius * 0.85) * math.cos(angle);
      final endY = center.dy + (radius * 0.85) * math.sin(angle);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }
    
    // 5. Brillo superior (efecto 3D)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy - radius * 0.4), width: radius * 1.2, height: radius * 0.6),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}