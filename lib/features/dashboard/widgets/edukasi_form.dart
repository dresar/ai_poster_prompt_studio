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

class EdukasiForm extends StatefulWidget {
  final DropdownState dropdownState;
  final List<NeoDropdownOption> dynamicVisualStyles;
  final bool loadingVisualStyles;
  final bool isGenerating;
  final bool isAnalyzing;
  final Future<void> Function(Map<String, dynamic> payload) onGenerate;
  final Future<Map<String, String>?> Function(String topic) onAnalyzeCerdas;

  const EdukasiForm({
    super.key,
    required this.dropdownState,
    required this.dynamicVisualStyles,
    required this.loadingVisualStyles,
    required this.isGenerating,
    required this.isAnalyzing,
    required this.onGenerate,
    required this.onAnalyzeCerdas,
  });

  @override
  State<EdukasiForm> createState() => _EdukasiFormState();
}

class _EdukasiFormState extends State<EdukasiForm> {
  XFile? _refImage;
  final _topicController = TextEditingController();
  final _descController = TextEditingController();
  final _extraController = TextEditingController();
  final _ctaController = TextEditingController();
  String _watermarkText = '';

  NeoDropdownOption? _selectedStyle;
  NeoDropdownOption? _selectedLayout;
  NeoDropdownOption? _selectedRatio;
  NeoDropdownOption? _selectedColor;
  NeoDropdownOption? _selectedMood;
  NeoDropdownOption? _selectedTextRule;
  NeoDropdownOption? _selectedCharFocus;

  int _slideCount = 3; // Default 3 slides for educational content
  bool _useManualLogo = false;
  bool _showAdvanced = false;

  @override
  void dispose() {
    _topicController.dispose();
    _descController.dispose();
    _extraController.dispose();
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
      });
    }
  }

  void _submit() {
    widget.onGenerate({
      'feature': 'edukasi',
      'topic': _topicController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'callToAction': _ctaController.text.trim(),
      'watermark': _watermarkText,
      'referenceImage': _refImage,
      'style': _selectedStyle?.value ?? 'auto',
      'layout': _selectedLayout?.value ?? 'auto',
      'aspectRatio': _selectedRatio?.value ?? '9:16',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'mood': _selectedMood?.value ?? 'bright_cheerful',
      'textRule': _selectedTextRule?.value ?? 'flexible',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
      'slideCount': _slideCount,
      'useManualLogo': _useManualLogo,
      'includeCaption': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    // All options fetched from DB via dropdownProvider (SQLite-first cache)
    final styles = widget.dropdownState.groups['gaya_edukasi'] ?? [];
    final layouts = widget.dropdownState.groups['tata_letak_edukasi'] ?? [];
    final ratios = widget.dropdownState.groups['rasio_edukasi'] ?? [];
    final colors = widget.dropdownState.groups['palet_warna_edukasi'] ?? [];
    // Reuse shared mood/textRule/charFocus from poster — sourced from DB
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
        NeoSectionCard(
          title: 'Referensi',
          emoji: '📸',
          isOptional: true,
          child: NeoUploadBox(
            title: 'Unggah Gambar',
            subtitle: 'Format bebas',
            initialFile: _refImage,
            onFilePicked: (file) => setState(() => _refImage = file),
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Materi Edukasi Utama',
          emoji: '🎓',
          backgroundColor: const Color(0xFFEBF3FB),
          child: Column(
            children: [
              NeoTextField(
                key: const ValueKey('edukasi_topic'),
                label: 'Judul Materi / Konsep Edukasi',
                placeholder: 'mis: Penjelasan Hukum Newton dalam Kehidupan',
                controller: _topicController,
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: [
                  NeoSecondaryButton(
                    text: 'IDE TOPIK',
                    icon: const Icon(Icons.lightbulb_outline, color: Colors.black),
                    onPressed: () => IdeasHelper.showIdeasDialog(
                      context: context,
                      defaultCategory: 'edukasi',
                      onIdeaSelected: (idea) {
                        setState(() {
                          _topicController.text = idea;
                        });
                        _runAnalyze();
                      },
                    ),
                  ),
                  NeoSecondaryButton(
                    text: 'ANALISIS MATERI',
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
          title: 'Ringkasan & Inti Materi',
          emoji: '📝',
          child: NeoTextField(
            label: 'Penjelasan / Ringkasan Materi',
            placeholder: 'Tuliskan deskripsi detail atau materi ringkas yang ingin dibahas...',
            controller: _descController,
            maxLines: 4,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Sub-poin Edukasi',
          emoji: '🪜',
          child: NeoTextField(
            label: 'Poin-Poin Edukasi Penting',
            placeholder: 'Tuliskan urutan poin (satu per baris)...',
            controller: _extraController,
            maxLines: 4,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Jumlah Slide',
          emoji: '📱',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jumlah Slide Infografis:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                label: '$_slideCount Halaman',
                onChanged: (val) => setState(() => _slideCount = val.round()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Spesifikasi Gaya Edukasi',
          emoji: '⚙️',
          child: Column(
            children: [
              NeoDropdownField(
                label: 'Gaya Visual Infografis',
                leadingEmoji: '⭐',
                selectedOption: _selectedStyle,
                // dynamicVisualStyles = from DB (/poster/visual-styles)
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
                  placeholder: 'Contoh: Simpan infografis ini! / Share ke temanmu',
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
                  // charFocus fetched from DB via dropdownProvider (group: fokus_karakter_poster)
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
          title: 'Logo',
          emoji: '🛡️',
          child: Column(
            children: [
              const SizedBox(height: 12),
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
          ),
        ),
        const SizedBox(height: 32),

        NeoPrimaryButton(
          text: '⚡ GENERATE MATERI EDUKASI (1 Kredit)',
          onPressed: _submit,
        ),
      ],
    );
  }
}
