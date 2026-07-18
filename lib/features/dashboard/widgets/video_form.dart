import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/neo_theme.dart';
import '../../../shared/widgets/neo_section_card.dart';
import '../../../shared/widgets/neo_upload_box.dart';
import '../../../shared/widgets/neo_text_field.dart';
import '../../../shared/widgets/neo_dropdown_field.dart';
import '../../../shared/widgets/neo_buttons.dart';
import '../../../shared/widgets/neo_watermark_list_field.dart';
import '../../../core/utils/ideas_helper.dart';
import '../dropdown_provider.dart';

class VideoForm extends StatefulWidget {
  final DropdownState dropdownState;
  final bool isGenerating;
  final bool isAnalyzing;
  final Future<void> Function(Map<String, dynamic> payload) onGenerate;
  final Future<Map<String, String>?> Function(String topic) onAnalyzeCerdas;

  const VideoForm({
    super.key,
    required this.dropdownState,
    required this.isGenerating,
    required this.isAnalyzing,
    required this.onGenerate,
    required this.onAnalyzeCerdas,
  });

  @override
  State<VideoForm> createState() => _VideoFormState();
}

class _VideoFormState extends State<VideoForm> {
  XFile? _refImage;
  final _topicController = TextEditingController();
  final _descController = TextEditingController();
  final _extraController = TextEditingController();
  String _watermarkText = '';

  NeoDropdownOption? _selectedStyle;
  NeoDropdownOption? _selectedMotion;
  NeoDropdownOption? _selectedRatio;
  NeoDropdownOption? _selectedColor;
  NeoDropdownOption? _selectedCharFocus;

  int _duration = 30; // default 30 seconds
  bool _showAdvanced = false;

  @override
  void dispose() {
    _topicController.dispose();
    _descController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  void _runAnalyze() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;
    final result = await widget.onAnalyzeCerdas(topic);
    if (result != null) {
      setState(() {
        _descController.text = result['description'] ?? '';
        _extraController.text = result['extraDetails'] ?? '';
      });
    }
  }

  void _submit() {
    widget.onGenerate({
      'feature': 'video',
      'topic': _topicController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'watermark': _watermarkText,
      'referenceImage': _refImage,
      'style': _selectedStyle?.value ?? 'auto',
      'cameraMovement': _selectedMotion?.value ?? 'auto',
      'aspectRatio': _selectedRatio?.value ?? '9:16',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
      'duration': _duration,
      'slideCount': (_duration / 10).ceil(), // to compatibility layer in backend
    });
  }

  @override
  Widget build(BuildContext context) {
    final styles = widget.dropdownState.groups['gaya_video'] ?? [];
    final motions = widget.dropdownState.groups['gerakan_kamera_video'] ?? [];
    final ratios = widget.dropdownState.groups['rasio_video'] ?? [];
    final colors = widget.dropdownState.groups['palet_warna_video'] ?? [];
    final charFocus = widget.dropdownState.groups['fokus_karakter_video'] ?? [];

    if (_selectedStyle == null && styles.isNotEmpty) _selectedStyle = styles.first;
    if (_selectedMotion == null && motions.isNotEmpty) _selectedMotion = motions.first;
    if (_selectedRatio == null && ratios.isNotEmpty) _selectedRatio = ratios.first;
    if (_selectedColor == null && colors.isNotEmpty) _selectedColor = colors.first;
    if (_selectedCharFocus == null && charFocus.isNotEmpty) _selectedCharFocus = charFocus.first;

    final segmentCount = (_duration / 10).ceil();

    return Column(
      children: [
        NeoSectionCard(
          title: 'Referensi Gambar (Opsional)',
          emoji: '📸',
          isOptional: true,
          child: NeoUploadBox(
            title: 'Unggah Gambar Referensi',
            subtitle: 'Format bebas (opsional)',
            initialFile: _refImage,
            onFilePicked: (file) => setState(() => _refImage = file),
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Gagasan & Topik Utama',
          emoji: '⚡',
          backgroundColor: const Color(0xFFE3F2FD),
          child: Column(
            children: [
              NeoTextField(
                key: const ValueKey('video_topic'),
                label: 'Topik Video',
                placeholder: 'mis: 3 tips produktif bangun pagi bagi pekerja kantoran',
                controller: _topicController,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeoSecondaryButton(
                    text: 'IDE TOPIK',
                    icon: const Icon(Icons.lightbulb_outline, color: Colors.black),
                    onPressed: () => IdeasHelper.showIdeasDialog(
                      context: context,
                      defaultCategory: 'video',
                      onIdeaSelected: (idea) {
                        setState(() {
                          _topicController.text = idea;
                        });
                        _runAnalyze();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  NeoSecondaryButton(
                    text: 'ANALISIS CERDAS',
                    isLoading: widget.isAnalyzing,
                    icon: const Icon(Icons.bolt, color: Colors.black),
                    onPressed: _runAnalyze,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Rincian Alur / Cerita Video',
          emoji: '📝',
          child: NeoTextField(
            label: 'Alur Cerita Video',
            placeholder: 'Tulis rincian apa yang ingin ditampilkan dalam video...',
            controller: _descController,
            maxLines: 4,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Detail Ekstra (Instruksi Visual)',
          emoji: '🎨',
          child: NeoTextField(
            label: 'Petunjuk Visual / Catatan',
            placeholder: 'Contoh: nuansa retro, pergerakan dinamis, dsb.',
            controller: _extraController,
            maxLines: 3,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Durasi Video',
          emoji: '⏳',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tentukan Durasi Video:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text('$_duration Detik ($segmentCount Segmen)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Slider(
                value: _duration.toDouble(),
                min: 10,
                max: 120,
                divisions: 11,
                activeColor: Colors.black,
                inactiveColor: Colors.grey[300],
                label: '$_duration Detik',
                onChanged: (val) => setState(() => _duration = val.round()),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Catatan: Generator video Google membatasi durasi per generate 10 detik. Durasi video Anda akan dibagi menjadi beberapa segmen 10 detik dengan prompt berkesinambungan.',
                  style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Parameter Visual Video',
          emoji: '🎬',
          child: Column(
            children: [
              NeoDropdownField(
                label: 'Gaya Visual Video',
                leadingEmoji: '⭐',
                selectedOption: _selectedStyle,
                options: styles,
                isLoading: widget.dropdownState.isLoading,
                onSelected: (opt) => setState(() => _selectedStyle = opt),
              ),
              const SizedBox(height: 16),
              NeoDropdownField(
                label: 'Gerakan Kamera',
                leadingEmoji: '🎥',
                selectedOption: _selectedMotion,
                options: motions,
                isLoading: widget.dropdownState.isLoading,
                onSelected: (opt) => setState(() => _selectedMotion = opt),
              ),
              const SizedBox(height: 16),
              NeoDropdownField(
                label: 'Rasio Video',
                leadingEmoji: '📱',
                selectedOption: _selectedRatio,
                options: ratios,
                isLoading: widget.dropdownState.isLoading,
                onSelected: (opt) => setState(() => _selectedRatio = opt),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                child: Row(
                  children: [
                    Text(
                      _showAdvanced ? 'Tutup Pengaturan Lanjutan ▴' : 'Pengaturan Lanjutan ▾',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: NeoTheme.accentPink),
                    ),
                  ],
                ),
              ),
              if (_showAdvanced) ...[
                const SizedBox(height: 16),
                NeoDropdownField(
                  label: 'Palet Warna',
                  leadingEmoji: '🌈',
                  selectedOption: _selectedColor,
                  options: colors,
                  isLoading: widget.dropdownState.isLoading,
                  onSelected: (opt) => setState(() => _selectedColor = opt),
                ),
                const SizedBox(height: 16),
                NeoDropdownField(
                  label: 'Fokus Karakter',
                  leadingEmoji: '👤',
                  selectedOption: _selectedCharFocus,
                  options: charFocus,
                  isLoading: widget.dropdownState.isLoading,
                  onSelected: (opt) => setState(() => _selectedCharFocus = opt),
                  isVisualGrid: true,
                ),
                NeoSelectedPreview(option: _selectedCharFocus, height: 120),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Branding & Watermark',
          emoji: '🛡️',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: NeoWatermarkListField(
              initialValue: _watermarkText,
              onChanged: (val) => setState(() => _watermarkText = val),
            ),
          ),
        ),
        const SizedBox(height: 32),

        NeoPrimaryButton(
          text: '⚡ GENERATE VIDEO PROMPT (1 Kredit)',
          onPressed: _submit,
        ),
      ],
    );
  }
}
