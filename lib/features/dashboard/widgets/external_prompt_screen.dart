import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/neo_theme.dart';
import '../../../shared/widgets/neo_section_card.dart';
import '../../../shared/widgets/neo_text_field.dart';
import '../../../shared/widgets/neo_buttons.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/json_repair_helper.dart';
import 'external_prompts/external_prompt_compiler.dart';

// ignore_for_file: avoid_returning_null_for_void

class ExternalPromptScreen extends StatefulWidget {
  final Map<String, dynamic> formState;
  final String? draftId;

  const ExternalPromptScreen({
    super.key,
    required this.formState,
    this.draftId,
  });

  @override
  State<ExternalPromptScreen> createState() => _ExternalPromptScreenState();
}

class _ExternalPromptScreenState extends State<ExternalPromptScreen> {
  final _jsonController1 = TextEditingController();
  final _jsonController2 = TextEditingController();
  final _jsonController3 = TextEditingController();
  final _jsonController4 = TextEditingController();

  bool _isLoading = false;
  bool _isSavingDraft = false;
  bool _draftSavedSuccess = false;

  late ExternalPromptParts _parts;
  int _selectedPartIndex = 0; // 0: Part 1, 1: Part 2, 2: Part 3, 3: Part 4, 4: All
  String? _draftId;

  @override
  void initState() {
    super.initState();
    _draftId = widget.draftId;
    _parts = compileExternalPromptParts(widget.formState);
    _saveDraftSilently();
  }

  @override
  void dispose() {
    _jsonController1.dispose();
    _jsonController2.dispose();
    _jsonController3.dispose();
    _jsonController4.dispose();
    super.dispose();
  }

  String get _currentTextToDisplay {
    switch (_selectedPartIndex) {
      case 0:
        return _parts.part1;
      case 1:
        return _parts.part2;
      case 2:
        return _parts.part3;
      case 3:
        return _parts.part4;
      case 4:
      default:
        return _parts.fullPrompt;
    }
  }

  Future<void> _saveDraftSilently() async {
    setState(() => _isSavingDraft = true);
    try {
      final res = await dioClient.post('/poster/save-external-draft', data: {
        if (_draftId != null) 'draftId': _draftId,
        'formState': widget.formState,
        'instructionsText': _parts.fullPrompt,
      });

      if (res.data['success'] == true && res.data['data'] != null) {
        if (mounted) {
          setState(() {
            _draftId = res.data['data']['id']?.toString();
            _draftSavedSuccess = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error auto-saving external prompt draft: $e');
    } finally {
      if (mounted) {
        setState(() => _isSavingDraft = false);
      }
    }
  }

  void _copyToClipboard() {
    final textToCopy = _currentTextToDisplay;
    Clipboard.setData(ClipboardData(text: textToCopy));

    String partLabel = _selectedPartIndex == 4
        ? 'Seluruh Teks Prompt'
        : 'Part ${_selectedPartIndex + 1}/4';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📋 $partLabel berhasil disalin! Draf tersimpan di Riwayat.'),
        backgroundColor: Colors.black,
      ),
    );
    _saveDraftSilently();
  }

  Future<void> _pickJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String content = '';

        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        } else if (file.path != null) {
          content = await File(file.path!).readAsString();
        }

        if (content.isNotEmpty) {
          final repaired = JsonRepairHelper.repair(content);
          bool isSplit = false;

          try {
            final parsedObj = jsonDecode(repaired);
            if (parsedObj is Map<String, dynamic>) {
              Map<String, dynamic> p1 = {};
              Map<String, dynamic> p2 = {};
              Map<String, dynamic> p3 = {};
              Map<String, dynamic> p4 = {};

              if (parsedObj.containsKey('systemInit')) p1['systemInit'] = parsedObj['systemInit'];
              if (parsedObj.containsKey('contentPayload')) p1['contentPayload'] = parsedObj['contentPayload'];
              if (parsedObj.containsKey('brandingEngine')) p1['brandingEngine'] = parsedObj['brandingEngine'];

              if (parsedObj.containsKey('designSystem')) p2['designSystem'] = parsedObj['designSystem'];
              if (parsedObj.containsKey('visualBlueprint')) p2['visualBlueprint'] = parsedObj['visualBlueprint'];
              if (parsedObj.containsKey('renderingBlueprint')) p2['renderingBlueprint'] = parsedObj['renderingBlueprint'];

              if (parsedObj.containsKey('slidesContent')) p3['slidesContent'] = parsedObj['slidesContent'];
              if (parsedObj.containsKey('segmentsContent')) p3['segmentsContent'] = parsedObj['segmentsContent'];

              if (parsedObj.containsKey('output')) p4['output'] = parsedObj['output'];

              if (p1.isNotEmpty || p2.isNotEmpty || p3.isNotEmpty || p4.isNotEmpty) {
                const encoder = JsonEncoder.withIndent('  ');
                setState(() {
                  _jsonController1.text = p1.isNotEmpty ? encoder.convert(p1) : '';
                  _jsonController2.text = p2.isNotEmpty ? encoder.convert(p2) : '';
                  _jsonController3.text = p3.isNotEmpty ? encoder.convert(p3) : '';
                  _jsonController4.text = p4.isNotEmpty ? encoder.convert(p4) : '';
                });
                isSplit = true;
              }
            }
          } catch (err) {
            debugPrint('Non-splittable JSON object: $err');
          }

          if (!isSplit) {
            setState(() {
              _jsonController1.text = repaired;
              _jsonController2.clear();
              _jsonController3.clear();
              _jsonController4.clear();
            });
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isSplit
                      ? '📂 File JSON dimuat & terbagi otomatis ke Form 1, 2, 3, & 4!'
                      : '📂 File JSON utuh dimuat & diperbaiki otomatis di Form 1!',
                ),
                backgroundColor: Colors.black,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal membaca file: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _submit() async {
    final partsText = [
      _jsonController1.text,
      _jsonController2.text,
      _jsonController3.text,
      _jsonController4.text,
    ];

    var mergedText = JsonRepairHelper.mergeParts(partsText);

    if (mergedText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Harap tempelkan teks JSON pada minimal salah satu form!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = Map<String, dynamic>.from(widget.formState);
      payload['externalJson'] = mergedText;
      if (_draftId != null) {
        payload['draftId'] = _draftId;
      }

      final res = await dioClient.post('/poster/import-external', data: payload);

      if (res.data['success'] == true) {
        if (mounted) {
          Navigator.pop(context, res.data['data']);
        }
      } else {
        throw Exception(res.data['message'] ?? 'Import failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal mengimpor: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final partNames = const ['Part 1', 'Part 2', 'Part 3', 'Part 4', 'Semua'];

    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 6,
        leadingWidth: 50,
        title: const Text(
          'Generasi Prompt Eksternal',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 15),
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: NeoTheme.accentYellow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5)),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.pop(context),
            child: const Center(
              child: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 18),
            ),
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 2.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Draft Indicator Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _draftSavedSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    _draftSavedSuccess ? Icons.cloud_done : Icons.cloud_upload,
                    size: 16,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isSavingDraft
                          ? 'Menyimpan draf...'
                          : _draftSavedSuccess
                              ? '💾 Draf tersimpan di Riwayat Salin Prompting.'
                              : 'Draf sedang disinkronkan...',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            // ── Section 1: Instructions (4 Part Splitter) ──
            NeoSectionCard(
              title: '1. Salin Instruksi Prompt',
              emoji: '📋',
              backgroundColor: const Color(0xFFE8F5E9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Segmented Selector (Part 1, Part 2, Part 3, Part 4, Semua)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(partNames.length, (index) {
                        final isSelected = _selectedPartIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            selected: isSelected,
                            label: Text(
                              partNames[index],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.black : Colors.black87,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            selectedColor: NeoTheme.accentYellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Colors.black,
                                width: isSelected ? 2.0 : 1.2,
                              ),
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedPartIndex = index);
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Prompt Text View Box
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _currentTextToDisplay,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Copy Button
                  NeoSecondaryButton(
                    text: _selectedPartIndex == 4
                        ? 'SALIN SEMUA PROMPT'
                        : 'SALIN PART ${_selectedPartIndex + 1} (BARIS ${_selectedPartIndex + 1}/4)',
                    icon: const Icon(Icons.copy, color: Colors.black, size: 18),
                    onPressed: _copyToClipboard,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Section 2: 4 Form Input JSON Parts AI ──
            NeoSectionCard(
              title: '2. Hasil JSON AI Eksternal',
              emoji: '📥',
              backgroundColor: const Color(0xFFFFF8E1),
              trailing: Container(
                decoration: BoxDecoration(
                  color: NeoTheme.accentYellow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(1, 1)),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: _pickJsonFile,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file, size: 16, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          'UNGGAH FILE',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NeoTextField(
                    label: 'Form 1',
                    placeholder: 'Tempelkan JSON Part 1 (atau tempel seluruh JSON di sini)...',
                    controller: _jsonController1,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  NeoTextField(
                    label: 'Form 2',
                    placeholder: 'Tempelkan JSON Part 2...',
                    controller: _jsonController2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  NeoTextField(
                    label: 'Form 3',
                    placeholder: 'Tempelkan JSON Part 3...',
                    controller: _jsonController3,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  NeoTextField(
                    label: 'Form 4',
                    placeholder: 'Tempelkan JSON Part 4...',
                    controller: _jsonController4,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            NeoPrimaryButton(
              text: '⚡ IMPORT & GENERATE',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
