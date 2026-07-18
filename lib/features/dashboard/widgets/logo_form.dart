import 'package:flutter/material.dart';
import '../../../core/theme/neo_theme.dart';
import '../../../shared/widgets/neo_section_card.dart';
import '../../../shared/widgets/neo_text_field.dart';
import '../../../shared/widgets/neo_dropdown_field.dart';
import '../../../shared/widgets/neo_buttons.dart';
import '../../../core/utils/ideas_helper.dart';
import '../dropdown_provider.dart';

class LogoForm extends StatefulWidget {
  final DropdownState dropdownState;
  final List<NeoDropdownOption> dynamicVisualStyles;
  final bool loadingVisualStyles;
  final bool isGenerating;
  final bool isAnalyzing;
  final Future<void> Function(Map<String, dynamic> payload) onGenerate;
  final Future<Map<String, String>?> Function(String topic) onAnalyzeCerdas;

  const LogoForm({
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
  State<LogoForm> createState() => _LogoFormState();
}

class _LogoFormState extends State<LogoForm> {
  final _topicController = TextEditingController();
  final _descController = TextEditingController();
  final _extraController = TextEditingController();

  NeoDropdownOption? _selectedStyle;
  NeoDropdownOption? _selectedColor;
  NeoDropdownOption? _selectedTextRule;
  NeoDropdownOption? _selectedCharFocus;

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
      'feature': 'logo',
      'topic': _topicController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'watermark': '', // No watermark on logos
      'style': _selectedStyle?.value ?? 'auto',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'textRule': _selectedTextRule?.value ?? 'flexible',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
      'slideCount': 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    final styles = widget.dropdownState.groups['gaya_logo'] ?? [];
    final colors = widget.dropdownState.groups['palet_warna_logo'] ?? [];
    final textRules = widget.dropdownState.groups['aturan_teks_logo'] ?? [];
    final charFocus = widget.dropdownState.groups['fokus_karakter_poster'] ?? [];

    if (_selectedStyle == null && styles.isNotEmpty) _selectedStyle = styles.first;
    if (_selectedColor == null && colors.isNotEmpty) _selectedColor = colors.first;
    if (_selectedTextRule == null && textRules.isNotEmpty) _selectedTextRule = textRules.first;
    if (_selectedCharFocus == null && charFocus.isNotEmpty) _selectedCharFocus = charFocus.first;

    return Column(
      children: [
        NeoSectionCard(
          title: 'Brand / Nama Bisnis',
          emoji: '💎',
          backgroundColor: const Color(0xFFEBFBF9),
          child: Column(
            children: [
              NeoTextField(
                key: const ValueKey('logo_topic'),
                label: 'Nama Brand / Bisnis Logo',
                placeholder: 'mis: Kopi Seduh Nusantara',
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
                      defaultCategory: 'logo',
                      onIdeaSelected: (idea) {
                        setState(() {
                          _topicController.text = idea;
                        });
                        _runAnalyze();
                      },
                    ),
                  ),
                  NeoSecondaryButton(
                    text: 'ANALISIS BRAND',
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
          title: 'Filosofi & Bidang Usaha',
          emoji: '📝',
          child: NeoTextField(
            label: 'Industri & Filosofi Logo',
            placeholder: 'Tuliskan jenis usaha, target audiens, dan kesan filosofi yang ingin ditampilkan...',
            controller: _descController,
            maxLines: 4,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Slogan / Tagline Pendukung',
          emoji: '💬',
          child: NeoTextField(
            label: 'Slogan / Tagline (Opsional)',
            placeholder: 'mis: Kenikmatan Asli Kopi Indonesia',
            controller: _extraController,
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Konfigurasi Logo',
          emoji: '⚙️',
          child: Column(
            children: [
              NeoDropdownField(
                label: 'Gaya Desain Logo',
                leadingEmoji: '⭐',
                selectedOption: _selectedStyle,
                options: widget.dynamicVisualStyles.isNotEmpty ? widget.dynamicVisualStyles : styles,
                isLoading: widget.loadingVisualStyles || widget.dropdownState.isLoading,
                onSelected: (opt) => setState(() => _selectedStyle = opt),
                isVisualHorizontal: true,
              ),
              NeoSelectedPreview(option: _selectedStyle),
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
                  label: 'Palet Warna Logo',
                  leadingEmoji: '🌈',
                  selectedOption: _selectedColor,
                  options: colors,
                  isLoading: widget.dropdownState.isLoading,
                  onSelected: (opt) => setState(() => _selectedColor = opt),
                ),
                const SizedBox(height: 16),
                NeoDropdownField(
                  label: 'Aturan Penulisan Teks',
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
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),

        NeoPrimaryButton(
          text: '⚡ GENERATE LOGO (1 Kredit)',
          onPressed: _submit,
        ),
      ],
    );
  }
}
