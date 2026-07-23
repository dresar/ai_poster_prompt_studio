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
  final void Function(Map<String, dynamic> payload) onGenerateExternal;
  final Future<Map<String, String>?> Function(String topic) onAnalyzeCerdas;

  const BannerForm({
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
  bool _autoCta = false;
  final _hookController = TextEditingController();
  bool _autoHook = false;
  bool _showSlideCountCard = true;
  bool _useManualLogo = false;

  @override
  void dispose() {
    _topicController.dispose();
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
      'feature': 'banner',
      'topic': _topicController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'hook': _hookController.text.trim(),
      'callToAction': _ctaController.text.trim(),
      'watermark': _watermarkText,
      'referenceImage': _refImage,
      'style': _selectedStyle?.value ?? 'auto',
      'aspectRatio': _selectedRatio?.value ?? '16:9',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'textRule': _selectedTextRule?.value ?? 'flexible',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
      'slideCount': _slideCount,
      'useManualLogo': _useManualLogo,
    });
  }

  void _submitExternal() {
    widget.onGenerateExternal({
      'feature': 'banner',
      'topic': _topicController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'hook': _hookController.text.trim(),
      'callToAction': _ctaController.text.trim(),
      'watermark': _watermarkText,
      'referenceImage': _refImage,
      'style': _selectedStyle?.value ?? 'auto',
      'aspectRatio': _selectedRatio?.value ?? '16:9',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'textRule': _selectedTextRule?.value ?? 'flexible',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
      'slideCount': _slideCount,
      'useManualLogo': _useManualLogo,
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
              NeoTextField(
                key: const ValueKey('banner_hook'),
                label: 'Hook / Kalimat Pemikat',
                placeholder: 'mis: Mau cantik di hari raya? (Opsional)',
                controller: _hookController,
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
          trailing: NeoFullscreenButton(
            onTap: () => NeoTextField.showExpandedModal(
              context,
              controller: _descController,
              label: 'Deskripsi Singkat Promo',
              placeholder: 'Tuliskan promosi atau penawaran menarik banner...',
            ),
          ),
          child: NeoTextField(
            label: '',
            placeholder: 'Tuliskan promosi atau penawaran menarik banner...',
            controller: _descController,
            maxLines: 3,
            showFullScreenButton: false,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Slogan / Teks Tambahan',
          emoji: '💬',
          trailing: NeoFullscreenButton(
            onTap: () => NeoTextField.showExpandedModal(
              context,
              controller: _extraController,
              label: 'Slogan / Teks Tambahan',
              placeholder: 'mis: Beli 2 Gratis 1 / Hubungi 0812345678',
            ),
          ),
          child: NeoTextField(
            label: '',
            placeholder: 'mis: Beli 2 Gratis 1 / Hubungi 0812345678',
            controller: _extraController,
            maxLines: 2,
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
         const SizedBox(height: 32),
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
