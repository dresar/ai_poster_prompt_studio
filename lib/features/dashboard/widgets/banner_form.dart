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

class BannerForm extends StatefulWidget {
  final DropdownState dropdownState;
  final List<NeoDropdownOption> dynamicVisualStyles;
  final bool loadingVisualStyles;
  final bool isGenerating;
  final bool isAnalyzing;
  final Future<void> Function(Map<String, dynamic> payload) onGenerate;
  final Future<Map<String, String>?> Function(String topic) onAnalyzeCerdas;

  const BannerForm({
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
  State<BannerForm> createState() => _BannerFormState();
}

class _BannerFormState extends State<BannerForm> {
  XFile? _refImage;
  final _topicController = TextEditingController();
  final _descController = TextEditingController();
  final _extraController = TextEditingController();
  final _ctaController = TextEditingController();
  String _watermarkText = '';

  NeoDropdownOption? _selectedStyle;
  NeoDropdownOption? _selectedRatio;
  NeoDropdownOption? _selectedColor;
  NeoDropdownOption? _selectedTextRule;
  NeoDropdownOption? _selectedCharFocus;

  int _slideCount = 1;
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
      'feature': 'banner',
      'topic': _topicController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'callToAction': _ctaController.text.trim(),
      'watermark': _watermarkText,
      'referenceImage': _refImage,
      'style': _selectedStyle?.value ?? 'auto',
      'aspectRatio': _selectedRatio?.value ?? '16:9',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'textRule': _selectedTextRule?.value ?? 'flexible',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
      'slideCount': _slideCount,
    });
  }

  @override
  Widget build(BuildContext context) {
    final styles = widget.dropdownState.groups['gaya_banner'] ?? [];
    final ratios = widget.dropdownState.groups['rasio_banner'] ?? [];
    final colors = widget.dropdownState.groups['palet_warna_banner'] ?? [];
    final textRules = widget.dropdownState.groups['aturan_teks_banner'] ?? [];
    final charFocus = widget.dropdownState.groups['fokus_karakter_poster'] ?? [];

    if (_selectedStyle == null && styles.isNotEmpty) _selectedStyle = styles.first;
    if (_selectedRatio == null && ratios.isNotEmpty) _selectedRatio = ratios.first;
    if (_selectedColor == null && colors.isNotEmpty) _selectedColor = colors.first;
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
          title: 'Topik & Judul Banner',
          emoji: '⚡',
          backgroundColor: const Color(0xFFFBE8EB),
          child: Column(
            children: [
              NeoTextField(
                key: const ValueKey('banner_topic'),
                label: 'Topik / Judul Banner',
                placeholder: 'mis: Promo Diskon 50% Akhir Tahun Hijab Modern',
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
                      defaultCategory: 'banner',
                      onIdeaSelected: (idea) {
                        setState(() {
                          _topicController.text = idea;
                        });
                        _runAnalyze();
                      },
                    ),
                  ),
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
          title: 'Deskripsi Singkat Promo',
          emoji: '📝',
          child: NeoTextField(
            label: 'Deskripsi Singkat Banner',
            placeholder: 'Tuliskan promosi atau penawaran menarik banner...',
            controller: _descController,
            maxLines: 3,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Slogan / Teks Tambahan',
          emoji: '💬',
          child: NeoTextField(
            label: 'Teks Tambahan / Slogan',
            placeholder: 'mis: Beli 2 Gratis 1 / Hubungi 0812345678',
            controller: _extraController,
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Parameter Visual Banner',
          emoji: '⚙️',
          child: Column(
            children: [
              NeoDropdownField(
                label: 'Gaya Desain Banner',
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
                label: 'Rasio Banner',
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
                  label: 'Teks Call-to-Action (Opsional)',
                  placeholder: 'Contoh: Belanja Sekarang! / Promo Terbatas!',
                  controller: _ctaController,
                  maxLines: 1,
                ),
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
                NeoWatermarkListField(
                  initialValue: _watermarkText,
                  onChanged: (val) => setState(() => _watermarkText = val),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),

        NeoPrimaryButton(
          text: '⚡ GENERATE BANNER (1 Kredit)',
          onPressed: _submit,
        ),
      ],
    );
  }
}
