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

class BeritaForm extends StatefulWidget {
  final DropdownState dropdownState;
  final List<NeoDropdownOption> dynamicVisualStyles;
  final bool loadingVisualStyles;
  final bool isGenerating;
  final bool isAnalyzing;
  final Future<void> Function(Map<String, dynamic> payload) onGenerate;
  final void Function(Map<String, dynamic> payload) onGenerateExternal;
  final Future<Map<String, String>?> Function(String topic) onAnalyzeCerdas;

  const BeritaForm({
    super.key,
    required this.dropdownState,
    required this.dynamicVisualStyles,
    required this.loadingVisualStyles,
    required this.isGenerating,
    required this.isAnalyzing,
    required this.onGenerate,
    required this.onGenerateExternal,
    required this.onAnalyzeCerdas,
  });

  @override
  State<BeritaForm> createState() => _BeritaFormState();
}

class _BeritaFormState extends State<BeritaForm> {
  XFile? _refImage;
  final _topicController = TextEditingController();
  final _locationController = TextEditingController();
  final _incidentStyleController = TextEditingController();
  final _descController = TextEditingController();
  final _extraController = TextEditingController();
  final _ctaController = TextEditingController();
  final _hookController = TextEditingController();
  String _watermarkText = '';

  NeoDropdownOption? _selectedStyle;
  NeoDropdownOption? _selectedLayout;
  NeoDropdownOption? _selectedRatio;
  NeoDropdownOption? _selectedColor;
  NeoDropdownOption? _selectedMood;
  NeoDropdownOption? _selectedTextRule;
  NeoDropdownOption? _selectedCharFocus;

  int _slideCount = 5; // Default 5 slides max for news carousel
  bool _useManualLogo = false;
  bool _showAdvanced = false;
  bool _showSlideCountCard = true;

  @override
  void dispose() {
    _topicController.dispose();
    _locationController.dispose();
    _incidentStyleController.dispose();
    _descController.dispose();
    _extraController.dispose();
    _ctaController.dispose();
    _hookController.dispose();
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

  void _submitExternal() {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Judul/Topik Kejadian Berita tidak boleh kosong!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    widget.onGenerateExternal({
      'feature': 'berita',
      'topic': topic,
      'location': _locationController.text.trim(),
      'incidentStyleExtra': _incidentStyleController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'hook': _hookController.text.trim(),
      'callToAction': _ctaController.text.trim(),
      'watermark': _watermarkText,
      'referenceImage': _refImage,
      'useManualLogo': _useManualLogo,
      'slideCount': _slideCount,
      'style': _selectedStyle?.value ?? 'auto',
      'layout': _selectedLayout?.value ?? 'auto',
      'aspectRatio': _selectedRatio?.value ?? 'auto',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'mood': _selectedMood?.value ?? 'auto',
      'textRule': _selectedTextRule?.value ?? 'auto',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
    });
  }

  @override
  Widget build(BuildContext context) {
    final styles = widget.dropdownState.groups['gaya_edukasi'] ?? [];
    final layouts = widget.dropdownState.groups['tata_letak_edukasi'] ?? [];
    final ratios = widget.dropdownState.groups['rasio_edukasi'] ?? [];
    final colors = widget.dropdownState.groups['palet_warna_edukasi'] ?? [];
    final moods = widget.dropdownState.groups['mood_poster'] ?? [];
    final textRules = widget.dropdownState.groups['aturan_teks_poster'] ?? [];
    final charFocus = widget.dropdownState.groups['fokus_karakter_poster'] ?? [];

    if (_selectedStyle == null && styles.isNotEmpty) _selectedStyle = styles.first;
    if (_selectedLayout == null && layouts.isNotEmpty) _selectedLayout = layouts.first;
    if (_selectedRatio == null && ratios.isNotEmpty) _selectedRatio = ratios.first;
    if (_selectedColor == null && colors.isNotEmpty) _selectedColor = colors.first;
    if (_selectedMood == null && moods.isNotEmpty) _selectedMood = moods.first;
    if (_selectedTextRule == null && textRules.isNotEmpty) _selectedTextRule = textRules.first;
    if (_selectedCharFocus == null && charFocus.isNotEmpty) _selectedCharFocus = charFocus.first;

    return Column(
      children: [
        // Banner Pemberitahuan Ringkas (1 Baris)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(2, 2)),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.newspaper, color: Colors.black, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '📰 BERITA CAROUSEL (AI EKSTERNAL 2026)\n'
                  'Riset berita & fakta 5W+1H real-time dari sumber terpercaya.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
        ),

        // Referensi Gambar (Opsional)
        NeoSectionCard(
          title: 'Referensi Gambar (Opsional)',
          emoji: '📸',
          isOptional: true,
          child: NeoUploadBox(
            title: 'Unggah Foto Kejadian',
            subtitle: 'Format gambar bebas',
            initialFile: _refImage,
            onFilePicked: (file) => setState(() => _refImage = file),
          ),
        ),
        const SizedBox(height: 20),

        // Section 1: Detail Kejadian Berita Utama
        NeoSectionCard(
          title: 'Detail Kejadian Berita Utama',
          emoji: '📰',
          backgroundColor: const Color(0xFFEBF3FB),
          child: Column(
            children: [
              NeoTextField(
                key: const ValueKey('berita_topic'),
                label: 'Judul / Kejadian Berita Utama *',
                placeholder: 'mis: Kecelakaan Maut di Jalan Tol Medan 2026...',
                controller: _topicController,
              ),
              const SizedBox(height: 16),
              NeoTextField(
                key: const ValueKey('berita_location'),
                label: 'Lokasi & Waktu Kejadian (Opsional)',
                placeholder: 'mis: Medan, Sumatera Utara / Pagi hari 2026',
                controller: _locationController,
              ),
              const SizedBox(height: 16),
              NeoTextField(
                key: const ValueKey('berita_incident_style'),
                label: 'Tambahan Gaya Ilustrasi Kejadian',
                placeholder: 'mis: Gaya ilustrasi 3D insiden malam hari, suasana dramatis',
                controller: _incidentStyleController,
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: [
                  NeoSecondaryButton(
                    text: 'IDE BERITA',
                    icon: const Icon(Icons.lightbulb_outline, color: Colors.black),
                    onPressed: () => IdeasHelper.showIdeasDialog(
                      context: context,
                      defaultCategory: 'edukasi',
                      onIdeaSelected: (idea, {slideCount, autoHook = false, autoCta = false}) {
                        setState(() {
                          _topicController.text = idea;
                          if (slideCount != null) {
                            _slideCount = slideCount > 5 ? 5 : slideCount;
                            _showSlideCountCard = true;
                          }
                        });
                        _runAnalyze();
                      },
                    ),
                  ),
                  NeoSecondaryButton(
                    text: 'ANALISIS BERITA CERDAS',
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

        // Section 2: Ringkasan Kronologi & Fakta
        NeoSectionCard(
          title: 'Ringkasan Kronologi & Fakta',
          emoji: '📝',
          trailing: NeoFullscreenButton(
            onTap: () => NeoTextField.showExpandedModal(
              context,
              controller: _descController,
              label: 'Ringkasan Kronologi & Fakta',
              placeholder: 'Fakta kronologi awal jika ada (AI akan memperlengkap riset 2026)...',
            ),
          ),
          child: NeoTextField(
            label: '',
            placeholder: 'Fakta kronologi awal jika ada (AI akan memperlengkap riset 2026)...',
            controller: _descController,
            maxLines: 4,
            showFullScreenButton: false,
          ),
        ),
        const SizedBox(height: 20),

        // Section 3: Jumlah Slide Berita (Maksimal 5 Slide)
        if (_showSlideCountCard)
          NeoSectionCard(
            title: 'Jumlah Slide Berita (Maksimal 5)',
            emoji: '📊',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jumlah Slide Berita:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  max: 5,
                  divisions: 4,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey[300],
                  label: '$_slideCount Halaman',
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

        // Section 4: Spesifikasi Gaya Berita
        NeoSectionCard(
          title: 'Spesifikasi Gaya Berita',
          emoji: '⚙️',
          child: Column(
            children: [
              NeoDropdownField(
                label: 'Gaya Visual Berita',
                leadingEmoji: '⭐',
                selectedOption: _selectedStyle,
                options: widget.dynamicVisualStyles.isNotEmpty ? widget.dynamicVisualStyles : styles,
                isLoading: widget.loadingVisualStyles || widget.dropdownState.isLoading,
                onSelected: (opt) => setState(() => _selectedStyle = opt),
                isVisualHorizontal: true,
              ),
              NeoSelectedPreview(option: _selectedStyle),
              const SizedBox(height: 16),
              NeoDropdownField(
                label: 'Tata Letak Alur',
                leadingEmoji: '🎯',
                selectedOption: _selectedLayout,
                options: layouts,
                isLoading: widget.dropdownState.isLoading,
                onSelected: (opt) => setState(() => _selectedLayout = opt),
              ),
              const SizedBox(height: 16),
              NeoDropdownField(
                label: 'Rasio Gambar',
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
                NeoTextField(
                  label: 'Teks CTA / Ajakan (Opsional)',
                  placeholder: 'Contoh: Simpan berita ini! / Share ke temanmu',
                  controller: _ctaController,
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                NeoDropdownField(
                  label: 'Palet Warna Dominan',
                  leadingEmoji: '🌈',
                  selectedOption: _selectedColor,
                  options: colors,
                  isLoading: widget.dropdownState.isLoading,
                  onSelected: (opt) => setState(() => _selectedColor = opt),
                ),
                const SizedBox(height: 16),
                NeoDropdownField(
                  label: 'Nuansa (Mood)',
                  leadingEmoji: '☀️',
                  selectedOption: _selectedMood,
                  options: moods,
                  isLoading: widget.dropdownState.isLoading,
                  onSelected: (opt) => setState(() => _selectedMood = opt),
                ),
                const SizedBox(height: 16),
                NeoDropdownField(
                  label: 'Aturan Teks',
                  leadingEmoji: '🔒',
                  selectedOption: _selectedTextRule,
                  options: textRules,
                  isLoading: widget.dropdownState.isLoading,
                  onSelected: (opt) => setState(() => _selectedTextRule = opt),
                ),
                const SizedBox(height: 16),
                NeoDropdownField(
                  label: 'Fokus Karakter',
                  leadingEmoji: '🎲',
                  selectedOption: _selectedCharFocus,
                  options: charFocus,
                  isLoading: widget.dropdownState.isLoading,
                  onSelected: (opt) => setState(() => _selectedCharFocus = opt),
                  isVisualGrid: true,
                ),
                NeoSelectedPreview(option: _selectedCharFocus, height: 120),
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
                  activeThumbColor: Colors.black,
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
        const SizedBox(height: 24),

        // Action Button: Directly opens External Prompt Screen!
        NeoPrimaryButton(
          text: '⚡ GENERATE DENGAN AI EKSTERNAL',
          icon: const Icon(Icons.psychology, color: Colors.white, size: 20),
          isLoading: widget.isGenerating,
          onPressed: widget.isGenerating ? null : _submitExternal,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
