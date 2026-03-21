import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/supabase/supabase_service.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final ImagePicker picker = ImagePicker();
  final SupabaseService supabaseService = SupabaseService();
  final TextEditingController videoUrlController = TextEditingController();

  List<Map<String, dynamic>> matches = [];
  int? selectedMatchId;
  XFile? selectedVideo;

  bool loadingMatches = true;
  bool saving = false;

  String selectedSourceType = 'youtube';

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  @override
  void dispose() {
    videoUrlController.dispose();
    super.dispose();
  }

  Future<void> loadMatches() async {
    setState(() => loadingMatches = true);

    try {
      final data = await supabaseService.getMatches();

      if (!mounted) return;

      setState(() {
        matches = data;
        if (data.isNotEmpty) {
          selectedMatchId = data.first['id'] as int;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando partidos: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => loadingMatches = false);
      }
    }
  }

  Future<void> pickVideo() async {
    final XFile? video = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (video == null) return;

    setState(() {
      selectedVideo = video;
    });
  }

  Future<void> saveAnalysisSource() async {
    if (selectedMatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un partido')),
      );
      return;
    }

    if (selectedSourceType == 'upload' && selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un video corto')),
      );
      return;
    }

    if (selectedSourceType != 'upload' &&
        videoUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pega el link del video')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      if (selectedSourceType == 'upload') {
        final bytes = await selectedVideo!.readAsBytes();

        await supabaseService.uploadShortMatchVideoBytes(
          matchId: selectedMatchId!,
          bytes: bytes,
          originalFileName: selectedVideo!.name,
        );
      } else {
        await supabaseService.updateMatchVideoSource(
          matchId: selectedMatchId!,
          sourceType: selectedSourceType,
          videoUrl: videoUrlController.text.trim(),
          status: 'processing',
        );
      }

      await loadMatches();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fuente de video guardada correctamente'),
        ),
      );

      setState(() {
        selectedVideo = null;
        videoUrlController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando la fuente: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  String matchLabel(Map<String, dynamic> match) {
    final team = match['teams'];
    final teamName =
        team is Map ? (team['name'] ?? 'Sin equipo') : 'Sin equipo';
    final opponent = match['opponent'] ?? 'Sin rival';
    return '$teamName vs $opponent';
  }

  String currentSourceLabel() {
    switch (selectedSourceType) {
      case 'youtube':
        return 'YouTube';
      case 'external':
        return 'Link externo';
      case 'upload':
        return 'Subir video corto';
      default:
        return 'Fuente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'ANÁLISIS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            color: const Color(0xFFE84C1E),
          ),
        ),
      ),
      body: loadingMatches
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'PARTIDO',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (matches.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF222222)),
                      ),
                      child: const Text(
                        'No hay partidos registrados todavía.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    DropdownButtonFormField<int>(
                      initialValue: selectedMatchId,
                      dropdownColor: const Color(0xFF1A1A1A),
                      decoration: _inputDecoration('Selecciona el partido'),
                      items: matches.map((match) {
                        return DropdownMenuItem<int>(
                          value: match['id'] as int,
                          child: Text(
                            matchLabel(match),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMatchId = value;
                        });
                      },
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'FUENTE DEL VIDEO',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSourceType,
                    dropdownColor: const Color(0xFF1A1A1A),
                    decoration: _inputDecoration('Tipo de fuente'),
                    items: const [
                      DropdownMenuItem(
                        value: 'youtube',
                        child: Text('YouTube',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: 'external',
                        child: Text('Link externo',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: 'upload',
                        child: Text('Subir video corto',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedSourceType = value;
                        selectedVideo = null;
                        videoUrlController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    currentSourceLabel().toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedSourceType == 'upload')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: pickVideo,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selectedVideo != null
                                    ? const Color(0xFFE84C1E)
                                    : const Color(0xFF333333),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  selectedVideo != null
                                      ? Icons.check_circle
                                      : Icons.upload_file,
                                  color: const Color(0xFFE84C1E),
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  selectedVideo != null
                                      ? 'Video seleccionado'
                                      : 'Subir clip corto',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    selectedVideo != null
                                        ? selectedVideo!.name
                                        : 'Usa esta opción para clips pequeños',
                                    style: const TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'En Supabase Free usa esta opción solo para videos cortos.',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    TextField(
                      controller: videoUrlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Pega aquí el link del video'),
                    ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: saving ? null : saveAnalysisSource,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE84C1E),
                      disabledBackgroundColor: const Color(0xFF333333),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      saving ? 'GUARDANDO...' : 'GUARDAR FUENTE DEL VIDEO',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF333333)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE84C1E)),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
