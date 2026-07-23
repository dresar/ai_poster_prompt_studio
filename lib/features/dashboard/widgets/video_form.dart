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
  final void Function(Map<String, dynamic> payload) onGenerateExternal;
  final Future<Map<String, String>?> Function(String topic) onAnalyzeCerdas;

  const VideoForm({
    super.key,
    required this.dropdownState,
    required this.isGenerating,
    required this.isAnalyzing,
    required this.onGenerate,
    required this.onGenerateExternal,
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
  final _hookController = TextEditingController();
  final _ctaController = TextEditingController();
  bool _autoHook = false;
  bool _autoCta = false;
  bool _useManualLogo = false;
  int _slideCount = 1;
  bool _showSlideCountCard = true;

  @override
  void dispose() {
    _topicController.dispose();
    _descController.dispose();
    _extraController.dispose();
    _hookController.dispose();
    _ctaController.dispose();
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
        if (_autoHook && result['hook'] != null && result['hook']!.isNotEmpty) {
          _hookController.text = result['hook']!;
        }
        if (_autoCta && result['cta'] != null && result['cta']!.isNotEmpty) {
          _ctaController.text = result['cta']!;
        }
      });
    }
  }

  void _submit() {
    widget.onGenerate({
      'feature': 'video',
      'topic': _topicController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'hook': _hookController.text.trim(),
      'callToAction': _ctaController.text.trim(),
      'watermark': _watermarkText,
      'referenceImage': _refImage,
      'style': _selectedStyle?.value ?? 'auto',
      'cameraMovement': _selectedMotion?.value ?? 'auto',
      'aspectRatio': _selectedRatio?.value ?? '9:16',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
      'duration': _duration,
      'slideCount': _slideCount,
      'useManualLogo': _useManualLogo,
    });
  }

  void _submitExternal() {
    widget.onGenerateExternal({
      'feature': 'video',
      'topic': _topicController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'hook': _hookController.text.trim(),
      'callToAction': _ctaController.text.trim(),
      'watermark': _watermarkText,
      'referenceImage': _refImage,
      'style': _selectedStyle?.value ?? 'auto',
      'cameraMovement': _selectedMotion?.value ?? 'auto',
      'aspectRatio': _selectedRatio?.value ?? '9:16',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
      'duration': _duration,
      'slideCount': _slideCount,
      'useManualLogo': _useManualLogo,
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
              NeoTextField(
                key: const ValueKey('video_hook'),
                label: 'Hook / Kalimat Pemikat',
                placeholder: 'mis: Mau tahu cara bangun pagi tanpa lelah? (Opsional)',
                controller: _hookController,
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
                      onIdeaSelected: (idea, {slideCount, autoHook = false, autoCta = false}) {
                        setState(() {
                          _topicController.text = idea;
                          _autoHook = autoHook;
                          _autoCta = autoCta;
                          if (slideCount != null) {
                            _slideCount = slideCount;
                            _showSlideCountCard = false;
                          }
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
          trailing: NeoFullscreenButton(
            onTap: () => NeoTextField.showExpandedModal(
              context,
              controller: _descController,
              label: 'Rincian Alur / Cerita Video',
              placeholder: 'Tulis rincian apa yang ingin ditampilkan dalam video...',
            ),
          ),
          child: NeoTextField(
            label: '',
            placeholder: 'Tulis rincian apa yang ingin ditampilkan dalam video...',
            controller: _descController,
            maxLines: 4,
            showFullScreenButton: false,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Detail Ekstra (Instruksi Visual)',
          emoji: '🎨',
          trailing: NeoFullscreenButton(
            onTap: () => NeoTextField.showExpandedModal(
              context,
              controller: _extraController,
              label: 'Detail Ekstra (Instruksi Visual)',
              placeholder: 'Contoh: nuansa retro, pergerakan dinamis, dsb.',
            ),
          ),
          child: NeoTextField(
            label: '',
            placeholder: 'Contoh: nuansa retro, pergerakan dinamis, dsb.',
            controller: _extraController,
            maxLines: 3,
            showFullScreenButton: false,
          ),
        ),
        const SizedBox(height: 20),

        if (_showSlideCountCard)
          NeoSectionCard(
            title: 'Jumlah Slide',
            emoji: '📱',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pilih Jumlah Slide (Max 10):', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Text('$_slideCount Slide', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _slideCount.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey[300],
                  label: '$_slideCount Slide',
                  onChanged: (val) => setState(() => _slideCount = val.round()),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jumlah Slide: $_slideCount Slide',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _showSlideCountCard = true),
                          child: const Text(
                            'Ubah',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: NeoTheme.accentPink,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                 const SizedBox(height: 16),
                 NeoTextField(
                   label: 'Teks Call-to-Action (Opsional)',
                   placeholder: 'Contoh: Subscribe untuk info lebih lanjut! / Like dan Share!',
                   controller: _ctaController,
                   maxLines: 1,
                 ),
                 const SizedBox(height: 16),
                 const Divider(color: Colors.black, thickness: 1.5),
                 const SizedBox(height: 16),
                 const Align(
                   alignment: Alignment.centerLeft,
                   child: Text('Pengaturan Branding & Watermark', style: TextStyle(fontWeight: FontWeight.bold)),
                 ),
                 const SizedBox(height: 8),
                 SwitchListTile(
                   title: const Text('⚠️ Gunakan Logo (Upload Manual)', style: TextStyle(fontWeight: FontWeight.bold)),
                   subtitle: const Text('Instruksi ke AI agar memberi tempat kosong untuk logo.', style: TextStyle(fontSize: 12)),
                   value: _useManualLogo,
                   activeColor: Colors.black,
                   onChanged: (val) => setState(() => _useManualLogo = val),
                 ),
                 const SizedBox(height: 12),
                 NeoWatermarkListField(
                   initialValue: _watermarkText,
                   onChanged: (val) => setState(() => _watermarkText = val),
                 ),
              ],
            ],
          ),
        ),
          Row(
            children: [
              Expanded(
                child: NeoPrimaryButton(
                  text: '⚡ GENERATE (AI BAWAAN)',
                  onPressed: _submit,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeoPrimaryButton(
                  text: '📋 SALIN PROMPT (AI LAIN)',
                  onPressed: _submitExternal,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
