import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/neo_theme.dart';
import '../../../shared/widgets/neo_section_card.dart';
import '../../../shared/widgets/neo_upload_box.dart';
import '../../../shared/widgets/neo_text_field.dart';
import '../../../shared/widgets/neo_dropdown_field.dart';
import '../../../shared/widgets/neo_buttons.dart';
import '../dropdown_provider.dart';

class EnhancePhotoForm extends StatefulWidget {
  final DropdownState dropdownState;
  final bool isGenerating;
  final Future<void> Function(Map<String, dynamic> payload) onGenerate;

  const EnhancePhotoForm({
    super.key,
    required this.dropdownState,
    required this.isGenerating,
    required this.onGenerate,
  });

  @override
  State<EnhancePhotoForm> createState() => _EnhancePhotoFormState();
}

class _EnhancePhotoFormState extends State<EnhancePhotoForm> {
  XFile? _enhanceImage;
  final _enhanceNotesController = TextEditingController();

  NeoDropdownOption? _selectedEnhanceStyle;
  NeoDropdownOption? _selectedEnhanceChange;

  @override
  void dispose() {
    _enhanceNotesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_enhanceImage == null) return;
    widget.onGenerate({
      'feature': 'photo_enhance',
      'referenceImage': _enhanceImage,
      'enhanceStyle': _selectedEnhanceStyle?.value ?? 'kpop_aesthetic',
      'changeLevel': _selectedEnhanceChange?.value ?? 'natural',
      'notes': _enhanceNotesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final styles = widget.dropdownState.groups['enhance_style'] ?? [];
    final changes = widget.dropdownState.groups['change_level'] ?? [];

    if (_selectedEnhanceStyle == null && styles.isNotEmpty) _selectedEnhanceStyle = styles.first;
    if (_selectedEnhanceChange == null && changes.isNotEmpty) _selectedEnhanceChange = changes.first;

    return Column(
      children: [
        NeoSectionCard(
          title: 'Foto Wajah Kamu',
          emoji: '🙋‍♂️',
          backgroundColor: const Color(0xFFFBEBF1),
          child: NeoUploadBox(
            title: 'Pilih / Ambil Foto',
            subtitle: 'Wajah jelas, pencahayaan cukup. Wajah tidak akan diubah.',
            initialFile: _enhanceImage,
            onFilePicked: (file) => setState(() => _enhanceImage = file),
          ),
        ),
        const SizedBox(height: 20),

        NeoSectionCard(
          title: 'Retouch Parameter',
          emoji: '✨',
          child: Column(
            children: [
              NeoDropdownField(
                label: 'Mau Jadi Seperti Apa?',
                leadingEmoji: '🇰🇷',
                selectedOption: _selectedEnhanceStyle,
                options: styles,
                isLoading: widget.dropdownState.isLoading,
                onSelected: (opt) => setState(() => _selectedEnhanceStyle = opt),
              ),
              const SizedBox(height: 16),
              NeoDropdownField(
                label: 'Tingkat Perubahan',
                leadingEmoji: '🌱',
                selectedOption: _selectedEnhanceChange,
                options: changes,
                isLoading: widget.dropdownState.isLoading,
                onSelected: (opt) => setState(() => _selectedEnhanceChange = opt),
              ),
              const SizedBox(height: 16),
              NeoTextField(
                label: 'Catatan Tambahan (Opsional)',
                placeholder: 'mis: ganti background jadi studio, rambut lebih tebal, dsb.',
                controller: _enhanceNotesController,
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        NeoPrimaryButton(
          text: '⚡ GENERATE RETOUCH PHOTO (1 Kredit)',
          onPressed: _enhanceImage == null ? null : _submit,
        ),
      ],
    );
  }
}
