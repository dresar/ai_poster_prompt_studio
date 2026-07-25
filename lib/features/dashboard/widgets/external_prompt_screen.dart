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

  Map<String, dynamic> _sanitizeFormState(Map<String, dynamic> raw) {
    final clean = <String, dynamic>{};
    raw.forEach((key, value) {
      if (value == null) return;
      if (value.runtimeType.toString().contains('XFile')) {
        clean[key] = (value as dynamic).path;
      } else if (value is Map<String, dynamic>) {
        clean[key] = _sanitizeFormState(value);
      } else if (value is List) {
        clean[key] = value.map((e) => e != null && e.runtimeType.toString().contains('XFile') ? (e as dynamic).path : e).toList();
      } else {
        try {
          jsonEncode(value);
          clean[key] = value;
        } catch (_) {
          clean[key] = value.toString();
        }
      }
    });
    return clean;
  }

  Future<void> _saveDraftManual() async {
    setState(() => _isSavingDraft = true);
    try {
      final safeState = _sanitizeFormState(widget.formState);
      final res = await dioClient.post('/poster/save-external-draft', data: {
        if (_draftId != null) 'draftId': _draftId,
        'formState': safeState,
        'instructionsText': _parts.fullPrompt,
      });

      if (res.data['success'] == true && res.data['data'] != null) {
        if (mounted) {
          setState(() {
            _draftId = res.data['data']['id']?.toString();
            _draftSavedSuccess = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('💾 Draf berhasil disimpan ke Riwayat!'),
              backgroundColor: Colors.black,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error manual saving external prompt draft: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menyimpan draf: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
        content: Text('📋 $partLabel berhasil disalin ke clipboard!'),
        backgroundColor: Colors.black,
      ),
    );
  }

  void _processPastedJsonContent(String content) {
    if (content.trim().isEmpty) return;

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
                ? '📂 Teks JSON dimuat & terbagi otomatis ke Form 1, 2, 3, & 4!'
                : '📂 Teks JSON dimuat ke Form 1!',
          ),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  void _showPasteCanvasModal() {
    final modalController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 2.5),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.65,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('📋 Canvas Paste JSON AI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tempelkan seluruh hasil teks JSON yang Anda salin dari ChatGPT / Claude di sini. Sistem akan membaginya otomatis ke Form 1 - 4!',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: modalController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      decoration: const InputDecoration(
                        hintText: 'Tempelkan (Paste) teks JSON di sini...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black, width: 1.8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) {
                            modalController.text = data!.text!;
                          }
                        },
                        icon: const Icon(Icons.content_paste, size: 16, color: Colors.black),
                        label: const Text('Tempel Clipboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NeoTheme.accentYellow,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          final text = modalController.text.trim();
                          if (text.isEmpty) return;
                          _processPastedJsonContent(text);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.flash_on, size: 16, color: Colors.black),
                        label: const Text('IMPOR & ISI FORM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
          _processPastedJsonContent(content);
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
      final payload = _sanitizeFormState(widget.formState);
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
            // Status Draft Indicator Banner with Manual Save Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _draftSavedSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    _draftSavedSuccess ? Icons.cloud_done : Icons.bookmark_add_outlined,
                    size: 18,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isSavingDraft
                          ? 'Menyimpan draf...'
                          : _draftSavedSuccess
                              ? '💾 Draf tersimpan di Riwayat.'
                              : 'Klik simpan untuk menyimpan draf ke Riwayat.',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _isSavingDraft ? null : _saveDraftManual,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: NeoTheme.accentYellow,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isSavingDraft
                              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.save_outlined, size: 14, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(
                            _draftSavedSuccess ? 'UPDATE DRAF' : 'SIMPAN DRAF',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
                          ),
                        ],
                      ),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: NeoTheme.accentPink,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1.8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(1, 1)),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: _showPasteCanvasModal,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.content_paste, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'CANVAS TEMPEL',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
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
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload_file, size: 14, color: Colors.black),
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
                ],
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
