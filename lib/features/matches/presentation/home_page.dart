import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? videoFile;
  final ImagePicker picker = ImagePicker();

  Future<void> pickVideo() async {
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        videoFile = File(video.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero section
            Container(
              color: const Color(0xFF111111),
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo/Brand
                  Row(
                    children: [
                      const Icon(Icons.sports_soccer,
                          color: Color(0xFFE84C1E), size: 28),
                      const SizedBox(width: 10),
                      const Text(
                        'PLAYVISION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // Hero headline
                  const Text(
                    'MEJORA EL\nRENDIMIENTO\nDE TU CLUB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    width: 60,
                    color: const Color(0xFFE84C1E),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Con las herramientas de video y datos más avanzadas para el fútbol.',
                    style: TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // CTA buttons
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: pickVideo,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'SUBIR VIDEO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE84C1E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'EMPEZAR ANÁLISIS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (videoFile != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Icon(Icons.check_circle,
                            color: Color(0xFFE84C1E), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Video cargado correctamente',
                          style: TextStyle(
                            color: Color(0xFFE84C1E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Divider accent
            Container(height: 4, color: const Color(0xFFE84C1E)),

            // Analysis section
            Container(
              color: const Color(0xFF0D0D0D),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Análisis del rendimiento',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nuestras soluciones de Análisis brindan la posibilidad de generar un impacto en la toma de decisiones técnico-tácticas en cada etapa del ciclo del juego a través de perspectivas basadas en los datos y el análisis de video. Permite que tu equipo mejore el desempeño y evolucione con mayor rapidez.',
                    style: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _FeatureItem(
                    icon: Icons.search,
                    text: 'Análisis exhaustivo de los Rivales',
                  ),
                  _FeatureItem(
                    icon: Icons.sports,
                    text: 'Preparación táctica detallada previa al partido',
                  ),
                  _FeatureItem(
                    icon: Icons.bolt,
                    text: 'Toma de decisiones en tiempo real durante el partido',
                  ),
                  _FeatureItem(
                    icon: Icons.bar_chart,
                    text: 'Análisis detallado individual y colectivo pospartido',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE84C1E), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
