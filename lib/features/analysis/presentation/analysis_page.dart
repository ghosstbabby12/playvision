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

  String selectedSourceType = 'upload';

  static const Color _background = Color(0xFF0B1020);
  static const Color _surface = Color(0xFF121832);
  static const Color _card = Color(0xFF1B2142);
  static const Color _border = Color(0xFF2A3366);

  static const Color _primary = Color(0xFF6C3BFF);
  static const Color _secondary = Color(0xFF9D4EDD);
  static const Color _accent = Color(0xFF2F6BFF);

  static const Color _success = Color(0xFF22C55E);
  static const Color _warning = Color(0xFFF59E0B);

  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFAAB3D1);
  static const Color _muted = Color(0xFF7C86B2);

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

      int? nextSelectedId = selectedMatchId;

      if (data.isEmpty) {
        nextSelectedId = null;
      } else {
        final exists = data.any((match) => match['id'] == selectedMatchId);
        nextSelectedId = exists ? selectedMatchId : data.first['id'] as int;
      }

      setState(() {
        matches = data;
        selectedMatchId = nextSelectedId;
      });

      _hydrateInputsFromSelectedMatch();
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

  Map<String, dynamic>? getSelectedMatch() {
    for (final match in matches) {
      if (match['id'] == selectedMatchId) {
        return match;
      }
    }
    return null;
  }

  void _hydrateInputsFromSelectedMatch() {
    final match = getSelectedMatch();
    if (match == null) return;

    final sourceType = (match['source_type'] ?? 'upload').toString();
    final sourceUrl = (match['source_url'] ?? '').toString().trim();

    if (!mounted) return;

    setState(() {
      if (sourceType == 'youtube' ||
          sourceType == 'external' ||
          sourceType == 'upload') {
        selectedSourceType = sourceType;
      } else {
        selectedSourceType = 'upload';
      }

      videoUrlController.text = sourceUrl;
      selectedVideo = null;
    });
  }

  Future<void> pickVideo() async {
    final XFile? video = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (video == null) return;

    if (!mounted) return;
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

    final sourceUrl = videoUrlController.text.trim();
    final needsUrl =
        selectedSourceType == 'youtube' || selectedSourceType == 'external';

    if (needsUrl && sourceUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pega el link del video')),
      );
      return;
    }

    if (needsUrl &&
        !(sourceUrl.startsWith('http://') ||
            sourceUrl.startsWith('https://'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La URL debe comenzar con http:// o https://'),
        ),
      );
      return;
    }

    if (selectedSourceType == 'youtube' &&
        !(sourceUrl.contains('youtube.com') || sourceUrl.contains('youtu.be'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un enlace válido de YouTube'),
        ),
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
          videoUrl: null,
          sourceUrl: sourceUrl,
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
        if (selectedSourceType == 'upload') {
          videoUrlController.clear();
        }
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
        team is Map ? (team['name'] ?? 'Sin equipo').toString() : 'Sin equipo';
    final opponent = (match['opponent'] ?? 'Sin rival').toString();
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

  String currentSourceDescription() {
    switch (selectedSourceType) {
      case 'upload':
        return 'Recomendado para la versión final de la app. Úsalo para clips cortos subidos desde el celular.';
      case 'youtube':
        return 'Modo beta. Puede requerir configuración adicional del backend para funcionar de forma estable.';
      case 'external':
        return 'Modo beta. Usa una URL pública directa del video.';
      default:
        return '';
    }
  }

  String selectedMatchStatus() {
    final match = getSelectedMatch();
    if (match == null) return 'uploaded';
    return (match['status'] ?? 'uploaded').toString();
  }

  String selectedMatchSourceSummary() {
    final match = getSelectedMatch();
    if (match == null) return 'Sin fuente registrada';

    final sourceType = (match['source_type'] ?? 'upload').toString();
    final sourceUrl = (match['source_url'] ?? '').toString().trim();
    final videoUrl = (match['video_url'] ?? '').toString().trim();

    if (sourceType == 'upload' && videoUrl.isNotEmpty) {
      return 'Fuente actual: video subido';
    }

    if ((sourceType == 'youtube' || sourceType == 'external') &&
        sourceUrl.isNotEmpty) {
      return 'Fuente actual: enlace guardado';
    }

    return 'Sin fuente registrada';
  }

  Color statusColor(String status) {
    switch (status) {
      case 'done':
        return _success;
      case 'processing':
        return _warning;
      case 'uploaded':
      default:
        return _accent;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'done':
        return 'Analizado';
      case 'processing':
        return 'Procesando';
      case 'uploaded':
      default:
        return 'Cargado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = selectedMatchStatus();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        centerTitle: true,
        title: const Text(
          'ANÁLISIS',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadingMatches ? null : loadMatches,
            icon: const Icon(Icons.refresh_rounded, color: _accent),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _secondary, _accent],
              ),
            ),
          ),
        ),
      ),
      body: loadingMatches
          ? const Center(
              child: CircularProgressIndicator(color: _primary),
            )
          : RefreshIndicator(
              color: _primary,
              backgroundColor: _card,
              onRefresh: loadMatches,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('PARTIDO'),
                    const SizedBox(height: 10),
                    _buildMatchSelector(currentStatus),
                    const SizedBox(height: 20),
                    _buildSectionTitle('FUENTE DEL VIDEO'),
                    const SizedBox(height: 10),
                    _buildSourceSelector(),
                    const SizedBox(height: 8),
                    Text(
                      currentSourceDescription(),
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(currentSourceLabel().toUpperCase()),
                    const SizedBox(height: 10),
                    if (selectedSourceType == 'upload')
                      _buildUploadCard()
                    else
                      _buildUrlCard(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: saving ? null : saveAnalysisSource,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        disabledBackgroundColor: const Color(0xFF2A2F45),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        saving ? 'GUARDANDO...' : 'GUARDAR FUENTE DEL VIDEO',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_surface, _card, Color(0xFF24195A)],
        ),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [_primary, _accent],
              ),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Configura la fuente del análisis',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona un partido, define cómo llegará el video y guarda la fuente para que el backend procese el análisis.',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchSelector(String currentStatus) {
    if (matches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: const Text(
          'No hay partidos registrados todavía.',
          style: TextStyle(color: _textSecondary),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            value: selectedMatchId,
            dropdownColor: _surface,
            style: const TextStyle(color: _textPrimary),
            iconEnabledColor: _accent,
            decoration: _inputDecoration('Selecciona el partido'),
            items: matches.map((match) {
              return DropdownMenuItem<int>(
                value: match['id'] as int,
                child: Text(
                  matchLabel(match),
                  style: const TextStyle(color: _textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMatchId = value;
              });
              _hydrateInputsFromSelectedMatch();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor(currentStatus).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: statusColor(currentStatus).withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  statusLabel(currentStatus),
                  style: TextStyle(
                    color: statusColor(currentStatus),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selectedMatchSourceSummary(),
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedSourceType,
        dropdownColor: _surface,
        style: const TextStyle(color: _textPrimary),
        iconEnabledColor: _accent,
        decoration: _inputDecoration('Tipo de fuente'),
        items: const [
          DropdownMenuItem(
            value: 'upload',
            child: Text(
              'Subir video corto (recomendado)',
              style: TextStyle(color: _textPrimary),
            ),
          ),
          DropdownMenuItem(
            value: 'youtube',
            child: Text(
              'YouTube (beta)',
              style: TextStyle(color: _textPrimary),
            ),
          ),
          DropdownMenuItem(
            value: 'external',
            child: Text(
              'Link externo (beta)',
              style: TextStyle(color: _textPrimary),
            ),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            selectedSourceType = value;
            selectedVideo = null;
            if (value == 'upload') {
              videoUrlController.clear();
            }
          });
        },
      ),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: pickVideo,
            child: Container(
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selectedVideo != null
                      ? [
                          _primary.withValues(alpha: 0.18),
                          _accent.withValues(alpha: 0.14),
                        ]
                      : [
                          _surface,
                          const Color(0xFF151D39),
                        ],
                ),
                border: Border.all(
                  color: selectedVideo != null ? _primary : _border,
                  width: 1.4,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedVideo != null
                          ? _primary.withValues(alpha: 0.18)
                          : _accent.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      selectedVideo != null
                          ? Icons.check_circle_rounded
                          : Icons.upload_file_rounded,
                      color: selectedVideo != null ? _primary : _accent,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    selectedVideo != null
                        ? 'Video seleccionado'
                        : 'Subir clip corto',
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      selectedVideo != null
                          ? selectedVideo!.name
                          : 'Toca aquí para seleccionar un video desde la galería',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'En Supabase Free usa esta opción solo para videos cortos.',
            style: TextStyle(
              color: _muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: videoUrlController,
            keyboardType: TextInputType.url,
            style: const TextStyle(color: _textPrimary),
            decoration: _inputDecoration('Pega aquí el link del video'),
          ),
          const SizedBox(height: 10),
          Text(
            selectedSourceType == 'youtube'
                ? 'Acepta enlaces de YouTube como youtube.com o youtu.be.'
                : 'Usa un enlace público directo que empiece con http:// o https://.',
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _muted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _textSecondary),
      filled: true,
      fillColor: _surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }
}
