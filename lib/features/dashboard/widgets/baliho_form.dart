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

class BalihoForm extends StatefulWidget {
  final DropdownState dropdownState;
  final List<NeoDropdownOption> dynamicVisualStyles;
  final bool loadingVisualStyles;
  final bool isGenerating;
  final bool isAnalyzing;
  final Future<void> Function(Map<String, dynamic> payload) onGenerate;
  final void Function(Map<String, dynamic> payload) onGenerateExternal;
  final Future<Map<String, String>?> Function(String topic) onAnalyzeCerdas;

  const BalihoForm({
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
  State<BalihoForm> createState() => _BalihoFormState();
}

class _BalihoFormState extends State<BalihoForm> {
  XFile? _refImage;
  final _topicController = TextEditingController();
  final _descController = TextEditingController();
  final _extraController = TextEditingController();
  String _watermarkText = '';

  NeoDropdownOption? _selectedStyle;
  NeoDropdownOption? _selectedLayout;
  NeoDropdownOption? _selectedRatio;
  NeoDropdownOption? _selectedColor;
  NeoDropdownOption? _selectedCharFocus;

  int _slideCount = 1;
  bool _showAdvanced = false;
  final _hookController = TextEditingController();
  final _ctaController = TextEditingController();
  bool _autoHook = false;
  bool _autoCta = false;
  bool _useManualLogo = false;
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
      'feature': 'baliho',
      'topic': _topicController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'hook': _hookController.text.trim(),
      'callToAction': _ctaController.text.trim(),
      'watermark': _watermarkText,
      'referenceImage': _refImage,
      'style': _selectedStyle?.value ?? 'auto',
      'layout': _selectedLayout?.value ?? 'auto',
      'aspectRatio': _selectedRatio?.value ?? '4:3',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
      'slideCount': _slideCount,
      'useManualLogo': _useManualLogo,
    });
  }

  void _submitExternal() {
    widget.onGenerateExternal({
      'feature': 'baliho',
      'topic': _topicController.text.trim(),
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'hook': _hookController.text.trim(),
      'callToAction': _ctaController.text.trim(),
      'watermark': _watermarkText,
      'referenceImage': _refImage,
      'style': _selectedStyle?.value ?? 'auto',
      'layout': _selectedLayout?.value ?? 'auto',
      'aspectRatio': _selectedRatio?.value ?? '4:3',
      'colorPalette': _selectedColor?.value ?? 'auto',
      'characterFocus': _selectedCharFocus?.value ?? 'random',
      'slideCount': _slideCount,
      'useManualLogo': _useManualLogo,
    });
  }

  @override
  Widget build(BuildContext context) {
    final styles = widget.dropdownState.groups['gaya_baliho'] ?? [];
    final layouts = widget.dropdownState.groups['tata_letak_baliho'] ?? [];
    final ratios = widget.dropdownState.groups['rasio_baliho'] ?? [];
    final colors = widget.dropdownState.groups['palet_warna_baliho'] ?? [];
    final charFocus = widget.dropdownState.groups['fokus_karakter_poster'] ?? [];

    if (_selectedStyle == null && styles.isNotEmpty) _selectedStyle = styles.first;
    if (_selectedLayout == null && layouts.isNotEmpty) _selectedLayout = layouts.first;
    if (_selectedRatio == null && ratios.isNotEmpty) _selectedRatio = ratios.first;
    if (_selectedColor == null && colors.isNotEmpty) _selectedColor = colors.first;
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
          title: 'Topik Utama & Instansi',
          emoji: '🏢',
          backgroundColor: const Color(0xFFFBEBF9),
          child: Column(
            children: [
              NeoTextField(
                key: const ValueKey('baliho_topic'),
                label: 'Nama Acara / Instansi / Tokoh',
                placeholder: 'mis: Seminar Nasional Digital Marketing 2026',
                controller: _topicController,
              ),
              const SizedBox(height: 16),
              NeoTextField(
                key: const ValueKey('baliho_hook'),
                label: 'Hook / Kalimat Pemikat',
                placeholder: 'mis: Hadiri Seminar Terbaik Tahun Ini! (Opsional)',
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
                      defaultCategory: 'baliho',
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
          title: 'Visi Misi / Sub-Tema Baliho',
          emoji: '📝',
          trailing: NeoFullscreenButton(
            onTap: () => NeoTextField.showExpandedModal(
              context,
              controller: _descController,
              label: 'Visi Misi / Sub-Tema Baliho',
              placeholder: 'Tuliskan sub-tema, daftar pembicara, atau visi misi yang ingin ditonjolkan...',
            ),
          ),
          child: NeoTextField(
            label: '',
            placeholder: 'Tuliskan sub-tema, daftar pembicara, atau visi misi yang ingin ditonjolkan...',
            controller: _descController,
            maxLines: 4,
            showFullScreenButton: false,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Informasi Waktu & Tempat',
          emoji: '📅',
          trailing: NeoFullscreenButton(
            onTap: () => NeoTextField.showExpandedModal(
              context,
              controller: _extraController,
              label: 'Informasi Waktu & Tempat',
              placeholder: 'mis: Minggu, 12 Oktober 2026 - Aula Utama Serbaguna',
            ),
          ),
          child: NeoTextField(
            label: '',
            placeholder: 'mis: Minggu, 12 Oktober 2026 - Aula Utama Serbaguna',
            controller: _extraController,
            maxLines: 2,
            showFullScreenButton: false,
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Konfigurasi Spanduk',
          emoji: '⚙️',
          child: Column(
            children: [
              NeoDropdownField(
                label: 'Gaya Desain Spanduk',
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
                label: 'Tata Letak Aset',
                leadingEmoji: '🎯',
                selectedOption: _selectedLayout,
                options: layouts,
                isLoading: widget.dropdownState.isLoading,
                onSelected: (opt) => setState(() => _selectedLayout = opt),
              ),
              const SizedBox(height: 16),
              NeoDropdownField(
                label: 'Rasio Ukuran Baliho',
                leadingEmoji: '📏',
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
                  label: 'Palet Warna Baliho',
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
                 const SizedBox(height: 16),
                 NeoTextField(
                   label: 'Teks Call-to-Action (Opsional)',
                   placeholder: 'Contoh: Hubungi Kami Sekarang! / Hadirilah!',
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
