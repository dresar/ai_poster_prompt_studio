import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../saved_codes/saved_codes_screen.dart';
import '../../core/theme/neo_theme.dart';
import '../../shared/widgets/neo_buttons.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/file_directory_helper.dart';

class ResultView extends StatefulWidget {
  final Map<String, dynamic> promptData;
  final Map<String, dynamic> viralBreakdown;
  final ScrollController? scrollController;
  final VoidCallback onBack;

  const ResultView({
    super.key,
    required this.promptData,
    required this.viralBreakdown,
    this.scrollController,
    required this.onBack,
  });

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  int _viewTab = 0; // 0 = Prompt Final, 1 = Filosofi Logo, 2 = Payload JSON, 3 = Analisis & Hooks, 4 = Slides
  bool _isFavorite = false;
  late String _promptId;
  late String _promptFinal;
  late String _feature;
  late String _logoExplanation;
  late String _analysisShortcomings;
  late List<String> _hooks;
  late String _socialMediaCaption;
  late String _payloadJsonString;
  List<Map<String, dynamic>> _slides = [];
  int _selectedSlideIndex = 0;
  final List<String> _templateImages = [];

  // New Image evaluation metrics
  int _promptScore = 0;
  int _detailScore = 0;
  int _creativityScore = 0;
  int _compositionScore = 0;
  String _promptImprovement = '';
  List<String> _aiSuggestions = [];

  // Advanced video state keys
  Map<String, dynamic> _projectSummary = {};
  Map<String, dynamic> _storyBible = {};
  List<Map<String, dynamic>> _characterBible = [];
  List<Map<String, dynamic>> _environmentBible = [];
  Map<String, dynamic> _cameraBible = {};
  Map<String, dynamic> _motionBible = {};
  List<Map<String, dynamic>> _sceneBreakdown = [];
  String _continuityRules = '';
  String _negativePromptVal = '';
  Map<String, String> _optimizedPrompts = {};
  Map<String, dynamic> _analyzerReport = {};
  int _selectedVideoSceneIndex = 0;
  String _selectedVideoPlatform = 'geminiVeo';

  @override
  void initState() {
    super.initState();
    _promptId = widget.promptData['id'] ?? '';
    _promptFinal = widget.promptData['promptFinal'] ?? '';
    _isFavorite = widget.promptData['isFavorite'] ?? false;
    
    final payload = widget.promptData['payloadJson'] ?? {};
    _feature = payload['feature'] ?? widget.promptData['feature'] ?? '';
    _logoExplanation = payload['output']?['logoExplanation'] ?? '';
    _analysisShortcomings = payload['output']?['analysisShortcomings'] ?? '';
    _socialMediaCaption = payload['output']?['socialMediaCaption'] ?? '';
    
    final hooksRaw = payload['output']?['hooks'] ?? widget.promptData['hooks'] ?? [];
    if (hooksRaw is List) {
      _hooks = hooksRaw.map((e) => e.toString()).toList();
    } else {
      _hooks = [];
    }

    final isVideo = _feature == 'video';
    var slidesOrSegmentsRaw = [];
    if (isVideo) {
      slidesOrSegmentsRaw = payload['segmentsContent'] ?? payload['output']?['segments'] ?? [];
    } else {
      slidesOrSegmentsRaw = payload['output']?['slides'] ?? [];
    }
    if (slidesOrSegmentsRaw is List) {
      _slides = slidesOrSegmentsRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else {
      _slides = [];
    }
    
    _payloadJsonString = const JsonEncoder.withIndent('  ').convert(payload);

    // Image evaluations extraction
    final output = payload['output'] ?? {};
    _promptScore = output['promptScore'] ?? 80;
    _detailScore = output['detailScore'] ?? 80;
    _creativityScore = output['creativityScore'] ?? 80;
    _compositionScore = output['compositionScore'] ?? 80;
    _promptImprovement = output['promptImprovement'] ?? '';
    final suggestionsRaw = output['aiSuggestions'];
    if (suggestionsRaw is List) {
      _aiSuggestions = suggestionsRaw.map((e) => e.toString()).toList();
    } else {
      _aiSuggestions = [];
    }

    // Advanced video extraction
    if (_feature == 'advanced_video') {
      _viewTab = 10; // Default to Storyboard tab
      _projectSummary = payload['projectSummary'] ?? {};
      _storyBible = payload['storyBible'] ?? {};
      
      final chars = payload['characterBible'];
      if (chars is List) {
        _characterBible = chars.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      
      final envs = payload['environmentBible'];
      if (envs is List) {
        _environmentBible = envs.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      
      _cameraBible = payload['cameraBible'] ?? {};
      _motionBible = payload['motionBible'] ?? {};
      
      final scenes = payload['sceneBreakdown'];
      if (scenes is List) {
        _sceneBreakdown = scenes.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      
      _continuityRules = payload['continuityRules'] ?? '';
      _negativePromptVal = payload['negativePrompt'] ?? '';
      
      final opts = payload['optimizedPrompts'] ?? {};
      if (opts is Map) {
        _optimizedPrompts = opts.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
      
      _analyzerReport = payload['analyzerReport'] ?? {};
    }
  }

  Future<void> _toggleFavorite() async {
    if (_promptId.isEmpty) return;

    try {
      final response = await dioClient.patch('/history/$_promptId/favorite');
      if (response.data['success'] == true) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message']),
            backgroundColor: NeoTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Favorite error: $e');
    }
  }

  void _copyToClipboard(String text, String message) {
    try {
      Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      debugPrint('Copy failed: $e');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: NeoTheme.accentBlue,
      ),
    );
  }

  Future<void> _downloadActiveFile() async {
    try {
      final appDir = await FileDirectoryHelper.getPublicDirectory();

      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String content = '';
      String ext = 'txt';
      String prefix = 'Prompt';

      if (_viewTab == 1) {
        content = _logoExplanation;
        prefix = 'Filosofi';
      } else if (_viewTab == 2) {
        content = _payloadJsonString;
        ext = 'json';
        prefix = 'Payload';
      } else if (_viewTab == 3) {
        content = 'ANALISIS KEKURANGAN:\n$_analysisShortcomings\n\nHOOKS VIRAL:\n${_hooks.join('\n')}';
        prefix = 'Hooks';
      } else if (_viewTab == 5) {
        content = _socialMediaCaption;
        prefix = 'Caption';
      } else if (_viewTab == 4) {
        if (_slides.isNotEmpty) {
          final currentSlide = _slides[_selectedSlideIndex];
          content = currentSlide['prompt'] ?? currentSlide['visualPrompt'] ?? '';
          prefix = 'Slide_${_selectedSlideIndex + 1}';
        }
      } else {
        content = _promptFinal;
        prefix = 'DSL';
      }

      final fileName = '${prefix}_$dateStr.$ext';
      final file = File('${appDir.path}/$fileName');
      await file.writeAsString(content);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File disimpan: $fileName'),
            backgroundColor: NeoTheme.accentGreen,
            action: SnackBarAction(
              label: 'Buka',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedCodesScreen()));
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan file: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viralScore = widget.promptData['viralScore'] ?? 0;
    
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'HASIL PROMPT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? NeoTheme.accentPink : NeoTheme.textMuted,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (_viewTab == 3) _buildAnalysisTab(),
          
          if (viralScore > 0) ...[
            Container(
              decoration: NeoTheme.neoBoxDecoration(
                color: Colors.white,
                borderRadius: 20,
                hasShadow: true,
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: NeoTheme.accentYellow,
                      border: Border.all(color: Colors.black, width: 2.5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$viralScore',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VIRAL SCORE',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 8),
                        _buildBreakdownBar('Hook', widget.viralBreakdown['hook'] ?? 0, NeoTheme.accentPink),
                        const SizedBox(height: 4),
                        _buildBreakdownBar('Visual', widget.viralBreakdown['visual'] ?? 0, NeoTheme.accentGreen),
                        const SizedBox(height: 4),
                        _buildBreakdownBar('Edukasi', widget.viralBreakdown['education'] ?? 0, NeoTheme.accentBlue),
                        const SizedBox(height: 4),
                        _buildBreakdownBar('Engagement', widget.viralBreakdown['engagement'] ?? 0, Colors.purpleAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (_feature != 'video' && _feature != 'advanced_video') ...[
            const SizedBox(height: 16),
            Container(
              decoration: NeoTheme.neoBoxDecoration(
                color: Colors.white,
                borderRadius: 20,
                hasShadow: true,
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI IMAGE PROMPT EVALUATION',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 12),
                  _buildBreakdownBar('Prompt Score', _promptScore, Colors.teal),
                  const SizedBox(height: 4),
                  _buildBreakdownBar('Detail Score', _detailScore, Colors.orange),
                  const SizedBox(height: 4),
                  _buildBreakdownBar('Creativity Score', _creativityScore, Colors.pink),
                  const SizedBox(height: 4),
                  _buildBreakdownBar('Composition', _compositionScore, Colors.indigo),
                  if (_promptImprovement.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'PROMPT IMPROVEMENT:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 4),
                    Text(_promptImprovement, style: const TextStyle(fontSize: 12, height: 1.4)),
                  ],
                  if (_aiSuggestions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'AI SUGGESTIONS / REKOMENDASI:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 4),
                    ..._aiSuggestions.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡 ', style: TextStyle(fontSize: 12)),
                          Expanded(child: Text(s, style: const TextStyle(fontSize: 12, height: 1.4))),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Tab bar — only for non-advanced_video features
          if (_feature != 'advanced_video') () {
            final showLogoTab = _feature == 'logo' &&
                _logoExplanation.isNotEmpty &&
                _logoExplanation.toLowerCase() != 'n/a' &&
                _logoExplanation.toLowerCase() != 'tidak ada' &&
                _logoExplanation.toLowerCase() != 'none';
            final showAnalysisTab = _analysisShortcomings.isNotEmpty || _hooks.isNotEmpty;
            final showSlidesTab = _slides.isNotEmpty;
            final showCaptionTab = _socialMediaCaption.isNotEmpty;
            final List<Map<String, dynamic>> tabs = [
              {'label': 'DSL CODE', 'index': 0},
              if (showSlidesTab) {'label': _feature == 'video' ? 'SEGMENTS' : 'SLIDES', 'index': 4},
              if (showCaptionTab) {'label': 'CAPTION', 'index': 5},
              if (showLogoTab) {'label': 'FILOSOFI', 'index': 1},
              if (showAnalysisTab) {'label': 'ANALISIS', 'index': 3},
              {'label': 'PAYLOAD JSON', 'index': 2},
            ];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(tabs.length, (i) {
                  final tab = tabs[i];
                  final label = tab['label'] as String;
                  final index = tab['index'] as int;
                  final isSelected = _viewTab == index;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () => setState(() => _viewTab = index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.white,
                          border: Border.all(color: Colors.black, width: 2.5),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected ? null : const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }(),
          const SizedBox(height: 16),

          if (_feature == 'advanced_video')
            _buildAdvancedVideoFullContent()
          else
            Container(
              height: 450,
              decoration: NeoTheme.neoBoxDecoration(
                color: Colors.white,
                borderRadius: 20,
                hasShadow: true,
              ),
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: _viewTab == 3
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_analysisShortcomings.isNotEmpty) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: NeoTheme.accentPink.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: NeoTheme.borderStrong, width: 1.5),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Text('⚠️ ', style: TextStyle(fontSize: 16)),
                                      Text(
                                        'ANALISIS KEKURANGAN PAYLOAD:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: NeoTheme.accentPink,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _analysisShortcomings,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (_hooks.isNotEmpty) ...[
                            const Text(
                              '🔥 COPYWRITING HOOKS VIRAL:',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._hooks.map((hook) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: NeoTheme.accentYellow.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: NeoTheme.borderStrong, width: 1.5),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('🎯 ', style: TextStyle(fontSize: 14)),
                                        Expanded(
                                          child: Text(
                                            hook,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ],
                        ],
                      )
                    : _viewTab == 5
                        ? SelectableText(
                            _socialMediaCaption,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          )
                        : _viewTab == 4
                            ? _buildSlidesView()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${(_viewTab == 0 ? _promptFinal : _viewTab == 1 ? _logoExplanation : _payloadJsonString).length} karakter',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                  ),
                                  SelectableText(
                                    _viewTab == 0
                                        ? _promptFinal
                                        : _viewTab == 1
                                            ? _logoExplanation
                                            : _payloadJsonString,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
              ),
            ),
          const SizedBox(height: 24),
          if (_viewTab == 4 && _slides.length > 1)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 20, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'TIPS: Copy prompt ini SATU PER SATU ke ChatGPT agar AI menghasilkan gambar terpisah (bukan grid/kolase).',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          Row(
              children: <Widget>[
                Expanded(
                  child: NeoSecondaryButton(
                    text: _viewTab == 1
                        ? 'Salin Filosofi'
                        : _viewTab == 3
                            ? 'Salin Hooks'
                            : _viewTab == 4
                                ? 'Salin Slide Ini'
                                : _viewTab == 5
                                    ? 'Salin Caption'
                                    : 'Salin DSL',
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () {
                      if (_viewTab == 1) {
                        _copyToClipboard(_logoExplanation, 'Filosofi logo disalin!');
                      } else if (_viewTab == 2) {
                        _copyToClipboard(_payloadJsonString, 'JSON disalin!');
                      } else if (_viewTab == 3) {
                        final allHooks = _hooks.join('\n');
                        _copyToClipboard(
                          'ANALISIS KEKURANGAN:\n$_analysisShortcomings\n\nHOOKS VIRAL:\n$allHooks',
                          'Analisis & Hooks disalin!',
                        );
                      } else if (_viewTab == 5) {
                        _copyToClipboard(_socialMediaCaption, 'Caption disalin!');
                      } else if (_viewTab == 4) {
                        if (_slides.isNotEmpty) {
                          final currentSlide = _slides[_selectedSlideIndex];
                          _copyToClipboard(
                            currentSlide['prompt'] ?? currentSlide['visualPrompt'] ?? '',
                            'Slide ${_selectedSlideIndex + 1} disalin!',
                          );
                        }
                      } else {
                        _copyToClipboard(_promptFinal, 'DSL disalin!');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeoPrimaryButton(
                    text: 'Download',
                    icon: const Icon(Icons.download, size: 16),
                    backgroundColor: NeoTheme.accentBlue,
                    onPressed: _downloadActiveFile,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          NeoPrimaryButton(
            text: 'TUTUP HASIL',
            onPressed: widget.onBack,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🖼️ TEMPLATE IMAGES',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.indigo),
            ),
            Text(
              '${_templateImages.length}/10',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...List.generate(_templateImages.length, (i) {
                return Container(
                  width: 90,
                  height: 90,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(_templateImages[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => setState(() => _templateImages.removeAt(i)),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                );
              }),
              if (_templateImages.length < 10)
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
                    if (file == null) return;
                    final bytes = await file.readAsBytes();
                    final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                    try {
                      final resp = await dioClient.post('/poster/upload', data: {
                        'image': base64Str,
                        'fileName': 'template_${DateTime.now().millisecondsSinceEpoch}.jpg',
                      });
                      final url = resp.data['url'] ?? '';
                      if (url.isNotEmpty) {
                        setState(() => _templateImages.add(url));
                      }
                    } catch (e) {
                      debugPrint('Upload template image error: $e');
                    }
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.black, width: 2, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 28, color: Colors.grey),
                        SizedBox(height: 4),
                        Text('Tambah', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_templateImages.isNotEmpty) ...[
          const SizedBox(height: 8),
          NeoSecondaryButton(
            text: 'SALIN SEMUA URL',
            icon: const Icon(Icons.copy, color: Colors.black, size: 14),
            onPressed: () => _copyToClipboard(
              _templateImages.join('\n'),
              '${_templateImages.length} URL template disalin!',
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSlidesView() {
    if (_slides.isEmpty) {
      return Center(child: Text(_feature == 'video' ? 'Tidak ada segmen video' : 'Tidak ada slide untuk gaya ini'));
    }

    final currentItem = _slides[_selectedSlideIndex];

    if (_feature == 'video') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: NeoTheme.accentYellow,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Segmen ${_selectedSlideIndex + 1} / ${_slides.length} (${currentItem['timestamp'] ?? ''})',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
              Row(
                children: [
                  if (_selectedSlideIndex > 0)
                    GestureDetector(
                      onTap: () => setState(() => _selectedSlideIndex--),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.chevron_left, size: 18),
                      ),
                    ),
                  const SizedBox(width: 6),
                  if (_selectedSlideIndex < _slides.length - 1)
                    GestureDetector(
                      onTap: () => setState(() => _selectedSlideIndex++),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.chevron_right, size: 18, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Segment selection horizontal row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_slides.length, (idx) {
                final active = _selectedSlideIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlideIndex = idx),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Segmen ${idx + 1}',
                      style: TextStyle(
                        color: active ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          if (currentItem.containsKey('visualPrompt')) ...[
            const Text(
              '🎥 VISUAL ACTIONS & SCENE:',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentPink),
            ),
            const SizedBox(height: 4),
            Text(
              currentItem['visualPrompt'] ?? '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],

          if (currentItem.containsKey('motionPrompt')) ...[
            const Text(
              '🏃‍♂️ CAMERA & MOTION PATH:',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentBlue),
            ),
            const SizedBox(height: 4),
            Text(
              currentItem['motionPrompt'] ?? '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],

          if (currentItem.containsKey('transitionPrompt')) ...[
            const Text(
              '🔄 TRANSITION DIRECTIVE:',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentGreen),
            ),
            const SizedBox(height: 4),
            Text(
              currentItem['transitionPrompt'] ?? '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],

          if (currentItem['textOverlay'] != null && currentItem['textOverlay'].toString().trim().isNotEmpty) ...[
            const Text(
              '💬 TEXT OVERLAY (SUBTITLE):',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.orange),
            ),
            const SizedBox(height: 4),
            Text(
              currentItem['textOverlay'] ?? '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],

          if (currentItem['audioSuggestion'] != null && currentItem['audioSuggestion'].toString().trim().isNotEmpty) ...[
            const Text(
              '🎵 AUDIO SUGGESTION:',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.purple),
            ),
            const SizedBox(height: 4),
            Text(
              currentItem['audioSuggestion'] ?? '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FINAL COMPILED PROMPT FOR VIDEO GENERATOR:',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.indigo),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(currentItem['prompt'] ?? '').length} karakter',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              currentItem['prompt'] ?? '',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: NeoSecondaryButton(
              text: 'Salin Prompt Segmen Ini',
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () {
                final promptStr = currentItem['prompt'] ?? '';
                _copyToClipboard(promptStr, 'Prompt Segmen ${_selectedSlideIndex + 1} disalin!');
              },
            ),
          ),
        ],
      );
    }

    final currentSlide = currentItem;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: NeoTheme.accentYellow,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Slide ${_selectedSlideIndex + 1} / ${_slides.length}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
            Row(
              children: [
                if (_selectedSlideIndex > 0)
                  GestureDetector(
                    onTap: () => setState(() => _selectedSlideIndex--),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chevron_left, size: 18),
                    ),
                  ),
                const SizedBox(width: 6),
                if (_selectedSlideIndex < _slides.length - 1)
                  GestureDetector(
                    onTap: () => setState(() => _selectedSlideIndex++),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chevron_right, size: 18, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Slide selection horizontal row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_slides.length, (idx) {
              final active = _selectedSlideIndex == idx;
              return GestureDetector(
                onTap: () => setState(() => _selectedSlideIndex = idx),
                child: Container(
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? Colors.black : Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Slide ${idx + 1}',
                    style: TextStyle(
                      color: active ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RAW SLIDE JSON:',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentPink),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(currentSlide['prompt'] ?? currentSlide['visualPrompt'] ?? '').length} karakter',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(12),
            ),
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            currentSlide['prompt'] ?? currentSlide['visualPrompt'] ?? '',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: NeoSecondaryButton(
            text: 'Salin Prompt Slide Ini',
            icon: const Icon(Icons.copy, size: 16),
            onPressed: () {
              final promptStr = currentSlide['prompt'] ?? currentSlide['visualPrompt'] ?? '';
              _copyToClipboard(promptStr, 'Prompt Slide ${_selectedSlideIndex + 1} disalin!');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownBar(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NeoTheme.textMuted),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAdvancedVideoFullContent() {
    // ── Hero Project Summary ──────────────────────────────────────────────────
    final title = _projectSummary['title'] ?? 'Proyek Tanpa Judul';
    final desc = _projectSummary['description'] ?? '';
    final totalDuration = _projectSummary['totalDuration'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── HERO CARD ───────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1.5),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purpleAccent, width: 1),
                    ),
                    child: const Text('🎬 FILM PROMPT STUDIO', style: TextStyle(color: Colors.purpleAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NeoTheme.accentYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: NeoTheme.accentYellow, width: 1),
                    ),
                    child: Text('⏱ ${totalDuration}s', style: const TextStyle(color: NeoTheme.accentYellow, fontSize: 11, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.2, letterSpacing: -0.5),
              ),
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5)),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildHeroBadge('📖 ${_storyBible['storyType'] ?? 'Story'}', Colors.blue),
                  const SizedBox(width: 8),
                  _buildHeroBadge('🎭 ${_characterBible.length} Karakter', Colors.orange),
                  const SizedBox(width: 8),
                  _buildHeroBadge('🎬 ${_sceneBreakdown.length} Scene', Colors.green),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ─── STORY BIBLE ──────────────────────────────────────────────────────
        _buildVideoSection(
          emoji: '📖',
          title: 'STORY BIBLE',
          color: const Color(0xFFF3E5F5),
          accentColor: Colors.purple,
          child: Column(
            children: [
              _buildStoryRow('🎨 Story Type', _storyBible['storyType']),
              _buildStoryRow('💬 Narrative', _storyBible['narrative']),
              _buildStoryRow('⚡ Conflict', _storyBible['conflict']),
              _buildStoryRow('✅ Resolution', _storyBible['resolution']),
              _buildStoryRow('📈 Emotional Arc', _storyBible['emotionalArc']),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ─── CHARACTER BIBLE ──────────────────────────────────────────────────
        if (_characterBible.isNotEmpty) ...[
          _buildVideoSection(
            emoji: '👤',
            title: 'CHARACTER BIBLE',
            color: const Color(0xFFE3F2FD),
            accentColor: Colors.blue,
            child: Column(
              children: _characterBible.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.blue.shade200, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue.shade400, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text((c['name'] ?? 'X')[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue.shade700, fontSize: 16)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                              if (c['age'] != null) Text('Usia ${c['age']} • ${c['personality'] ?? ''}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 4,
                      children: [
                        if (c['hair'] != null) _buildCharChip('💇 ${c['hair']}'),
                        if (c['clothes'] != null) _buildCharChip('👕 ${c['clothes']}'),
                        if (c['skin'] != null) _buildCharChip('🌟 ${c['skin']}'),
                        if (c['face'] != null) _buildCharChip('😎 ${c['face']}'),
                      ],
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ─── SCENE BREAKDOWN ──────────────────────────────────────────────────
        _buildVideoSection(
          emoji: '🎬',
          title: 'SCENE BREAKDOWN — ${_sceneBreakdown.length} scene × 10 detik',
          color: const Color(0xFFE8F5E9),
          accentColor: Colors.green,
          child: Column(
            children: _sceneBreakdown.asMap().entries.map((entry) {
              final idx = entry.key;
              final sc = entry.value;
              final isExpanded = _selectedVideoSceneIndex == idx;
              return GestureDetector(
                onTap: () => setState(() => _selectedVideoSceneIndex = isExpanded ? -1 : idx),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isExpanded ? const Color(0xFF1B5E20).withValues(alpha: 0.08) : Colors.white,
                    border: Border.all(
                      color: isExpanded ? Colors.green : Colors.black12,
                      width: isExpanded ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: isExpanded ? Colors.green : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'S${sc['sceneNumber'] ?? (idx + 1)}',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: isExpanded ? Colors.white : Colors.black),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sc['title'] ?? 'Scene ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                                  Text('⏱ ${sc['duration'] ?? 10}s • ${sc['camera'] ?? ''}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 12, color: Colors.black12),
                              _buildStoryRow('🎯 Goal', sc['goal']),
                              _buildStoryRow('🚶 Action', sc['action']),
                              _buildStoryRow('😊 Emotion', sc['emotion']),
                              _buildStoryRow('💡 Lighting', sc['lighting']),
                              _buildStoryRow('🌍 Environment', sc['environment']),
                              _buildStoryRow('➡️ Transition', sc['transition']),
                              if (sc['dialogue'] != null && sc['dialogue'].toString().isNotEmpty)
                                _buildStoryRow('🗣️ Dialogue', sc['dialogue']),
                              if (sc['soundEffect'] != null && sc['soundEffect'].toString().isNotEmpty)
                                _buildStoryRow('🎵 Sound', sc['soundEffect']),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // ─── OPTIMIZED PROMPTS ────────────────────────────────────────────────
        if (_optimizedPrompts.isNotEmpty)
          _buildVideoSection(
            emoji: '⚡',
            title: 'OPTIMIZED PROMPTS PER PLATFORM',
            color: const Color(0xFFFFF3E0),
            accentColor: Colors.orange,
            child: Column(
              children: [
                ..._optimizedPrompts.entries.map((entry) {
                  final platformLabel = _platformLabel(entry.key);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.orange.shade200, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Text(platformLabel['emoji']!, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(platformLabel['name']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                                  Text(platformLabel['hint']!, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                ],
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _copyToClipboard(entry.value, '${platformLabel['name']} prompt disalin!'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade600,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.copy, color: Colors.white, size: 13),
                                      SizedBox(width: 4),
                                      Text('COPY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: SelectableText(
                            entry.value,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.5, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // ─── CONTINUITY & NEGATIVE PROMPTS ────────────────────────────────────
        _buildVideoSection(
          emoji: '🔗',
          title: 'CONTINUITY & NEGATIVE PROMPTS',
          color: const Color(0xFFE8EAF6),
          accentColor: Colors.indigo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CONTINUITY RULES:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.indigo)),
              const SizedBox(height: 8),
              if (_continuityRules.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Text(_continuityRules, style: const TextStyle(fontSize: 12, height: 1.5)),
                ),
              const SizedBox(height: 14),
              const Text('VIDEO NEGATIVE PROMPTS:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.red)),
              const SizedBox(height: 8),
              if (_negativePromptVal.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: SelectableText(_negativePromptVal, style: const TextStyle(fontSize: 12, height: 1.5, color: Colors.red)),
                ),
              if (_negativePromptVal.isNotEmpty) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _copyToClipboard(_negativePromptVal, 'Negative prompt disalin!'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text('Copy Negative Prompt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ─── SMART AI AUDITOR ─────────────────────────────────────────────────
        _buildVideoSection(
          emoji: '🔮',
          title: 'SMART AI AUDITOR REPORT',
          color: const Color(0xFFF1F8E9),
          accentColor: Colors.teal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('QUALITY GRADE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.teal.shade900, width: 1.5),
                    ),
                    child: Text(
                      'GRADE ${_analyzerReport['qualityGrade'] ?? 'A'}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAuditRow('👤 Character Consistency', _analyzerReport['characterConsistency'], Colors.blue),
              _buildAuditRow('📚 Story Logic', _analyzerReport['storyLogic'], Colors.purple),
              _buildAuditRow('🎥 Camera Flow', _analyzerReport['cameraFlow'], Colors.indigo),
              _buildAuditRow('💡 Lighting Consistency', _analyzerReport['lightingConsistency'], Colors.amber),
              _buildAuditRow('🔗 Continuity Eval', _analyzerReport['continuityEvaluation'], Colors.teal),
              if (_analyzerReport['instructionConflicts'] != null)
                _buildAuditRow('⚠️ Conflicts', _analyzerReport['instructionConflicts'], Colors.red),
              () {
                final recs = _analyzerReport['recommendations'];
                List<String> recList = [];
                if (recs is List) recList = recs.map((e) => e.toString()).toList();
                if (recList.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text('📝 REKOMENDASI:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.blueGrey)),
                    const SizedBox(height: 6),
                    ...recList.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 5, right: 8), decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle)),
                          Expanded(child: Text(rec, style: const TextStyle(fontSize: 12, height: 1.4))),
                        ],
                      ),
                    )),
                  ],
                );
              }(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ─── PAYLOAD JSON (for advanced_video) ───────────────────────────────
        _buildVideoSection(
          emoji: '🗋️',
          title: 'PAYLOAD JSON LENGKAP',
          color: Colors.grey.shade100,
          accentColor: Colors.grey.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                _payloadJsonString,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10, height: 1.5),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _copyToClipboard(_payloadJsonString, 'JSON disalin!'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text('Copy JSON', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection({
    required String emoji,
    required String title,
    required Color color,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: accentColor, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildHeroBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildCharChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: Colors.blue.shade800)),
    );
  }

  Widget _buildStoryRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildAuditRow(String label, String? value, Color color) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: color)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, height: 1.4))),
        ],
      ),
    );
  }

  Map<String, String> _platformLabel(String key) {
    const map = {
      'geminiVeo': {'emoji': '🔵', 'name': 'Gemini Veo', 'hint': 'Google Veo — sinematik tinggi'},
      'kling': {'emoji': '⭐', 'name': 'Kling', 'hint': 'Kling AI — narasi visual aksi'},
      'runway': {'emoji': '🟢', 'name': 'Runway', 'hint': 'Runway — kamera & kompresi visual'},
      'pika': {'emoji': '🟡', 'name': 'Pika', 'hint': 'Pika Labs — parameter friendly'},
      'hailuo': {'emoji': '🔴', 'name': 'Hailuo', 'hint': 'Hailuo — dramatis & alur visual'},
    };
    return (map[key] ?? {'emoji': '🎥', 'name': key.toUpperCase(), 'hint': 'Platform video AI'}) as Map<String, String>;
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black54)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 10, color: Colors.black87))),
        ],
      ),
    );
  }
}
