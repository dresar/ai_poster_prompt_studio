import 'package:flutter/material.dart';
import '../../../core/theme/neo_theme.dart';
import '../../../shared/widgets/neo_section_card.dart';
import '../../../shared/widgets/neo_text_field.dart';
import '../../../shared/widgets/neo_dropdown_field.dart';
import '../../../shared/widgets/neo_buttons.dart';
import '../../../shared/widgets/neo_watermark_list_field.dart';
import '../../../core/utils/ideas_helper.dart';
import '../dropdown_provider.dart';

class QuotesForm extends StatefulWidget {
  final DropdownState dropdownState;
  final List<NeoDropdownOption> dynamicVisualStyles;
  final bool loadingVisualStyles;
  final bool isGenerating;
  final bool isAnalyzing;
  final Future<void> Function(Map<String, dynamic> payload) onGenerate;
  final Future<Map<String, String>?> Function(String topic) onAnalyzeCerdas;

  const QuotesForm({
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
  State<QuotesForm> createState() => _QuotesFormState();
}

class _QuotesFormState extends State<QuotesForm> {
  final _topicController = TextEditingController();
  final _descController = TextEditingController();
  final _extraController = TextEditingController();
  final _ctaController = TextEditingController();

  NeoDropdownOption? _selectedStyle;
  NeoDropdownOption? _selectedTheme;
  NeoDropdownOption? _selectedRatio;
  NeoDropdownOption? _selectedColor;
  NeoDropdownOption? _selectedCharFocus;

  int _slideCount = 1;
  bool _showAdvanced = false;
  bool _useManualLogo = false;
  bool _includeCaption = false;
  String _watermarkText = '';

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
      'feature': 'quotes',
      'topic': _topicController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'callToAction': _ctaController.text.trim(),
      'watermark': _watermarkText,
      'useManualLogo': _useManualLogo,
      'includeCaption': true,
      'style': _selectedStyle?.value ?? 'auto',
      'theme': _selectedTheme?.value ?? 'auto',
      'aspectRatio': _selectedRatio?.value ?? '9:16',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
      'slideCount': _slideCount,
    });
  }

  @override
  Widget build(BuildContext context) {
    final styles = widget.dropdownState.groups['gaya_quotes'] ?? [];
    final themes = widget.dropdownState.groups['tema_quotes'] ?? [];
    final ratios = widget.dropdownState.groups['rasio_quotes'] ?? [];
    final colors = widget.dropdownState.groups['palet_warna_quotes'] ?? [];
    final charFocus = widget.dropdownState.groups['fokus_karakter_poster'] ?? [];

    if (_selectedStyle == null && styles.isNotEmpty) _selectedStyle = styles.first;
    if (_selectedTheme == null && themes.isNotEmpty) _selectedTheme = themes.first;
    if (_selectedRatio == null && ratios.isNotEmpty) _selectedRatio = ratios.first;
    if (_selectedColor == null && colors.isNotEmpty) _selectedColor = colors.first;
    if (_selectedCharFocus == null && charFocus.isNotEmpty) _selectedCharFocus = charFocus.first;

    return Column(
      children: [
        NeoSectionCard(
          title: 'Isi Kutipan / Kata Mutiara',
          emoji: '✍️',
          backgroundColor: const Color(0xFFFBEBF1),
          child: Column(
            children: [
              NeoTextField(
                key: const ValueKey('quotes_topic'),
                label: 'Kutipan / Kata Mutiara Utama',
                placeholder: 'mis: Kegagalan adalah kunci keberhasilan yang tertunda',
                controller: _topicController,
                maxLines: 3,
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
                      defaultCategory: 'quotes',
                      onIdeaSelected: (idea) {
                        setState(() {
                          _topicController.text = idea;
                        });
                        _runAnalyze();
                      },
                    ),
                  ),
                  NeoSecondaryButton(
                    text: 'PERCANTIK BAHASA',
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
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Catatan Penafsiran (Opsional)',
          emoji: '📝',
          child: NeoTextField(
            label: 'Catatan Visual Tambahan',
            placeholder: 'Penjelasan tambahan tentang mood quotes, dsb...',
            controller: _descController,
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Konfigurasi Quotes',
          emoji: '⚙️',
          child: Column(
            children: [
              NeoDropdownField(
                label: 'Tema Quotes',
                leadingEmoji: '💪',
                selectedOption: _selectedTheme,
                options: themes,
                isLoading: widget.dropdownState.isLoading,
                onSelected: (opt) => setState(() => _selectedTheme = opt),
              ),
              const SizedBox(height: 16),
                NeoDropdownField(
                  label: 'Gaya Desain Quotes',
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
                label: 'Rasio Quotes',
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
                  placeholder: 'Contoh: Bagikan ini! / Setuju?',
                  controller: _ctaController,
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                 NeoDropdownField(
                  label: 'Palet Warna Latar',
                  leadingEmoji: '🌈',
                  selectedOption: _selectedColor,
                  options: colors,
                  isLoading: widget.dropdownState.isLoading,
                  onSelected: (opt) => setState(() => _selectedColor = opt),
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
                activeColor: Colors.black,
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
          text: '⚡ GENERATE QUOTES (1 Kredit)',
          isLoading: widget.isGenerating,
          onPressed: _submit,
        ),
      ],
    );
  }
}
