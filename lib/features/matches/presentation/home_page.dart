import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/supabase/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? videoFile;
  final ImagePicker picker = ImagePicker();
  final SupabaseService supabaseService = SupabaseService();

  List<Map<String, dynamic>> teams = [];
  bool loadingTeams = false;

  Future<void> pickVideo() async {
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        videoFile = File(video.path);
      });
    }
  }

  Future<void> loadTeams() async {
    setState(() => loadingTeams = true);

    try {
      final data = await supabaseService.getTeams();
      if (!mounted) return;
      setState(() {
        teams = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando equipos: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => loadingTeams = false);
    }
  }

  Future<void> createDemoTeam() async {
    try {
      await supabaseService.createTeam(
        name: 'Club Deportivo Pasto',
        category: 'Juvenil',
        club: 'PlayVision FC',
      );

      await loadTeams();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipo creado en Supabase')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creando equipo: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xFF111111),
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.sports_soccer,
                          color: Color(0xFFE84C1E), size: 28),
                      SizedBox(width: 10),
                      Text(
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
                      onPressed: createDemoTeam,
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
                        'CREAR EQUIPO DEMO',
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
            Container(height: 4, color: const Color(0xFFE84C1E)),
            Container(
              color: const Color(0xFF0D0D0D),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    'Nuestras soluciones de análisis permiten tomar mejores decisiones técnico-tácticas a partir del video y los datos del partido.',
                    style: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _FeatureItem(
                    icon: Icons.search,
                    text: 'Análisis exhaustivo de los rivales',
                  ),
                  const _FeatureItem(
                    icon: Icons.sports,
                    text: 'Preparación táctica previa al partido',
                  ),
                  const _FeatureItem(
                    icon: Icons.bolt,
                    text: 'Toma de decisiones durante el partido',
                  ),
                  const _FeatureItem(
                    icon: Icons.bar_chart,
                    text: 'Análisis individual y colectivo pospartido',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: loadTeams,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE84C1E)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('RECARGAR EQUIPOS'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Equipos guardados en la base de datos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (loadingTeams)
                    const Center(child: CircularProgressIndicator())
                  else if (teams.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF222222)),
                      ),
                      child: const Text(
                        'No hay equipos todavía. Usa "CREAR EQUIPO DEMO".',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    Column(
                      children: teams.map((team) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF222222)),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xFFE84C1E),
                                child: Icon(Icons.groups, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      team['name'] ?? 'Sin nombre',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${team['club'] ?? 'Sin club'} • ${team['category'] ?? 'Sin categoría'}',
                                      style: const TextStyle(
                                        color: Color(0xFFAAAAAA),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
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
