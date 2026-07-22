import 'dart:convert' show JsonEncoder, base64Encode;
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../saved_codes/saved_codes_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/neo_theme.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/clipboard_helper.dart';
import '../../core/utils/file_directory_helper.dart';


class HistoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> promptData;

  const HistoryDetailPage({super.key, required this.promptData});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  int _viewTab = 0;
  bool _isFavorite = false;
  bool _isSavingImage = false;
  bool _isSavingTemplate = false;
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
  late String? _previewImageUrl;
  late Map<String, dynamic> _viralBreakdown;
  // Multi-image support (max 10)
  List<String> _referenceImageUrls = [];
  bool _isUploadingPhoto = false;
  bool _showCdnInput = false;
  XFile? _pendingPickedFile; // for local preview before upload
  final TextEditingController _imageUrlController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

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
    _previewImageUrl = widget.promptData['referenceImageUrl'] as String?;
    // Fallback to imageUrl field for photo enhance mode
    if (_previewImageUrl == null || _previewImageUrl!.isEmpty) {
      final payload = widget.promptData['payloadJson'] ?? {};
      _previewImageUrl = payload['input']?['imageUrl'] as String?;
    }

    // Load multi-image array
    final rawUrls = widget.promptData['referenceImageUrls'];
    if (rawUrls is List && rawUrls.isNotEmpty) {
      _referenceImageUrls = rawUrls.map((e) => e.toString()).toList();
    } else if (_previewImageUrl != null && _previewImageUrl!.isNotEmpty) {
      _referenceImageUrls = [_previewImageUrl!];
    }

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

    _viralBreakdown = {
      'hook': widget.promptData['viralScore'] != null ? 80 : 0,
      'visual': widget.promptData['viralScore'] != null ? 85 : 0,
      'education': widget.promptData['viralScore'] != null ? 80 : 0,
      'engagement': widget.promptData['viralScore'] != null ? 85 : 0,
    };

    _payloadJsonString = _prettyJson(payload);

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

  String _prettyJson(dynamic obj) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(obj);
    } catch (_) {
      return obj.toString();
    }
  }

  Future<void> _toggleFavorite() async {
    if (_promptId.isEmpty) return;
    try {
      final response = await dioClient.patch('/history/$_promptId/favorite');
      if (response.data['success'] == true) {
        setState(() => _isFavorite = !_isFavorite);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message']),
              backgroundColor: NeoTheme.accentGreen,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Favorite error: $e');
    }
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_referenceImageUrls.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 10 foto sudah tercapai'), backgroundColor: Colors.orange),
      );
      return;
    }
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (picked != null) {
        setState(() => _pendingPickedFile = picked);
        await _uploadPhoto(picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka galeri.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _uploadPhoto(XFile file) async {
    setState(() => _isUploadingPhoto = true);
    try {
      final bytes = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      final ext = file.name.split('.').last.toLowerCase();
      final mimePrefix = 'data:image/${ext == 'jpg' ? 'jpeg' : ext};base64,';
      final base64Full = '$mimePrefix$base64Str';

      final response = await dioClient.post('/poster/upload', data: {
        'image': base64Full,
        'fileName': '${_promptId}_${DateTime.now().millisecondsSinceEpoch}.$ext',
      });

      if (response.data['success'] == true) {
        final url = response.data['url'] as String;
        final newList = [..._referenceImageUrls, url];
        await _saveAllImages(newList);
        if (mounted) {
          setState(() {
            _referenceImageUrls = newList;
            _previewImageUrl = newList.first;
            _pendingPickedFile = null;
          });
          final storageType = response.data['storageType'] ?? 'local';
          final storageLabel = storageType == 'storage_gateway' ? '☁️ Storage Gateway'
              : storageType == 'user_imagekit' ? '☁️ ImageKit pribadi Anda'
              : storageType == 'admin_imagekit' ? '☁️ ImageKit server'
              : '💾 Server lokal';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Foto ${_referenceImageUrls.length}/10 disimpan di $storageLabel'),
              backgroundColor: NeoTheme.accentGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _pendingPickedFile = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload foto: ${e.toString().length > 60 ? "Server error" : e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _removeImage(int index) async {
    final newList = List<String>.from(_referenceImageUrls)..removeAt(index);
    try {
      await _saveAllImages(newList);
      setState(() {
        _referenceImageUrls = newList;
        _previewImageUrl = newList.isNotEmpty ? newList.first : null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto dihapus'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus foto'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveAllImages(List<String> urls) async {
    await dioClient.patch('/history/$_promptId/images', data: {'imageUrls': urls});
  }

  Future<void> _saveCdnUrl() async {
    final url = _imageUrlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan URL CDN terlebih dahulu'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_referenceImageUrls.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 10 foto sudah tercapai'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isSavingImage = true);
    try {
      final newList = [..._referenceImageUrls, url];
      await _saveAllImages(newList);
      setState(() {
        _referenceImageUrls = newList;
        _previewImageUrl = newList.first;
        _showCdnInput = false;
        _imageUrlController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ URL CDN berhasil ditambahkan!'), backgroundColor: NeoTheme.accentGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan URL. Coba lagi.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingImage = false);
    }
  }

  Future<void> _saveAsTemplate() async {
    final topic = widget.promptData['topic'] ?? '';
    final mode = widget.promptData['mode'] ?? 'poster';
    final payload = widget.promptData['payloadJson'] ?? {};
    final viralScore = widget.promptData['viralScore'] ?? 0;

    // Show category input dialog
    String? selectedCategory;
    await showDialog(
      context: context,
      builder: (ctx) {
        final categoryCtrl = TextEditingController(text: mode);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 2.5),
          ),
          title: const Text('⭐ Jadikan Template', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Topik: $topic', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              const Text('Kategori Template:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: categoryCtrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black, width: 2)),
                  hintText: 'Contoh: poster, banner, logo...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (v) => selectedCategory = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                selectedCategory = categoryCtrl.text.trim();
                Navigator.pop(ctx, true);
              },
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (selectedCategory == null || selectedCategory!.isEmpty) return;

    setState(() => _isSavingTemplate = true);
    try {
      final response = await dioClient.post('/admin/templates', data: {
        'category': selectedCategory,
        'template': _promptFinal,
        'previewImageUrl': _previewImageUrl,
        'viralScore': viralScore,
        'payloadJson': payload,
        'hooks': _hooks,
      });
      if (response.data['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⭐ Berhasil disimpan sebagai template!'), backgroundColor: NeoTheme.accentGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan template. Pastikan akun Anda memiliki akses admin.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingTemplate = false);
    }
  }

  void _copyText(String text, String successMsg) {
    try {
      Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMsg), backgroundColor: NeoTheme.accentBlue),
        );
      }
    } catch (e) {
      debugPrint('Copy failed: $e');
    }
  }

  Future<void> _downloadActiveFile() async {
    try {
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String content = '';
      String ext = 'txt';
      String prefix = 'History';

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
      final saveResult = await FileDirectoryHelper.saveFile(
        fileName: fileName,
        content: content,
      );

      if (!saveResult.isSuccess) {
        throw Exception(saveResult.errorMessage ?? 'Gagal menyimpan file');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text('⚡ Terdownload ke: ${saveResult.displayLocation}/$fileName'),
            backgroundColor: NeoTheme.accentGreen,
            action: SnackBarAction(
              label: 'Lihat',
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
    final topic = widget.promptData['topic'] ?? '';
    final mode = widget.promptData['mode'] ?? '';
    final dateStr = widget.promptData['createdAt'] ?? '';

    final showLogoTab = _feature == 'logo' &&
        _logoExplanation.isNotEmpty &&
        _logoExplanation.toLowerCase() != 'n/a';
    final showAnalysisTab = _analysisShortcomings.isNotEmpty || _hooks.isNotEmpty;
    final showSlidesTab = _slides.isNotEmpty;
    final showCaptionTab = _socialMediaCaption.isNotEmpty;

    final List<Map<String, dynamic>> tabs = _feature == 'advanced_video' ? [
      {'label': 'STORYBOARD', 'index': 10},
      {'label': 'OPTIMIZED PROMPTS', 'index': 11},
      {'label': 'CONTINUITY & NEGATIVE', 'index': 12},
      {'label': 'SMART AUDITOR', 'index': 13},
      {'label': 'PAYLOAD JSON', 'index': 2},
    ] : [
      {'label': 'DSL CODE', 'index': 0},
      if (showSlidesTab) {'label': _feature == 'video' ? 'SEGMENTS' : 'SLIDES', 'index': 4},
      if (showCaptionTab) {'label': 'CAPTION', 'index': 5},
      if (showLogoTab) {'label': 'FILOSOFI', 'index': 1},
      if (showAnalysisTab) {'label': 'ANALISIS & HOOKS', 'index': 3},
      {'label': 'PAYLOAD JSON', 'index': 2},
    ];

    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      appBar: AppBar(
        backgroundColor: NeoTheme.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          topic.isEmpty ? 'Detail Riwayat' : topic,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? NeoTheme.accentYellow : NeoTheme.textPrimary,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // ─────────────── Image Preview (top) ───────────────
          if (_previewImageUrl != null && _previewImageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _previewImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '📷 Foto Referensi',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ─────────────── Topic + Meta ───────────────
          Row(
            children: [
              (() {
                final normalized = mode.toLowerCase();
                String label = mode.toUpperCase();
                Color bg = NeoTheme.accentPink;

                if (normalized == 'poster') {
                  label = 'POSTER';
                  bg = NeoTheme.accentBlue;
                } else if (normalized == 'video') {
                  label = 'VIDEO PROMPT';
                  bg = Colors.deepPurpleAccent;
                }

                return Container(
                  decoration: BoxDecoration(
                    color: bg,
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                );
              })(),
              const SizedBox(width: 8),
              if (viralScore > 0)
                Container(
                  decoration: BoxDecoration(
                    color: NeoTheme.accentYellow,
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    '🔥 Viral Score: $viralScore',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            topic,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: const TextStyle(color: NeoTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // ─────────────── Upload Gambar (max 10) ───────────────
          Container(
            decoration: NeoTheme.neoBoxDecoration(color: const Color(0xFFFFF9C4), borderRadius: 16, hasShadow: true),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header + count
                Row(
                  children: [
                    const Icon(Icons.photo_library_rounded, size: 16, color: Colors.black),
                    const SizedBox(width: 6),
                    const Text('FOTO HASIL DESAIN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.6)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _referenceImageUrls.length >= 10 ? Colors.red : Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_referenceImageUrls.length}/10',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Image grid
                if (_referenceImageUrls.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _referenceImageUrls.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: index == 0 ? Colors.black : Colors.grey[400]!,
                                  width: index == 0 ? 2 : 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.network(
                                _referenceImageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                ),
                              ),
                            ),
                          ),
                          // Primary badge
                          if (index == 0)
                            Positioned(
                              bottom: 6, left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: NeoTheme.accentYellow,
                                  border: Border.all(color: Colors.black, width: 1.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('UTAMA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                              ),
                            ),
                          // Delete button
                          Positioned(
                            top: 4, right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: const Icon(Icons.close, color: Colors.white, size: 12),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                // Pending upload preview (local file before server response)
                if (_pendingPickedFile != null && _isUploadingPhoto)
                  Padding(
                    padding: EdgeInsets.only(top: _referenceImageUrls.isNotEmpty ? 8 : 0),
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.network(_pendingPickedFile!.path, fit: BoxFit.cover)
                                : Image.file(io.File(_pendingPickedFile!.path), fit: BoxFit.cover),
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.5),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                  SizedBox(height: 4),
                                  Text('Mengupload...', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // Add photo button (disabled at 10)
                GestureDetector(
                  onTap: (_isUploadingPhoto || _referenceImageUrls.length >= 10) ? null : _pickPhoto,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _referenceImageUrls.length >= 10 ? Colors.grey[200] : Colors.white,
                      border: Border.all(
                        color: _referenceImageUrls.length >= 10 ? Colors.grey : Colors.black,
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _referenceImageUrls.length >= 10
                          ? []
                          : const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                    ),
                    child: _isUploadingPhoto
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                              SizedBox(width: 8),
                              Text('Mengupload...', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 18,
                                color: _referenceImageUrls.length >= 10 ? Colors.grey : Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _referenceImageUrls.length >= 10
                                    ? 'Batas 10 foto tercapai'
                                    : _referenceImageUrls.isEmpty
                                        ? 'Pilih dari Galeri'
                                        : 'Tambah Foto (${_referenceImageUrls.length}/10)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: _referenceImageUrls.length >= 10 ? Colors.grey : Colors.black,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (_referenceImageUrls.isEmpty && !_isUploadingPhoto)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Center(
                      child: Text('Foto diupload ke storage Anda otomatis', style: TextStyle(fontSize: 10, color: NeoTheme.textMuted)),
                    ),
                  ),

                // CDN URL toggle (optional)
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => setState(() => _showCdnInput = !_showCdnInput),
                  child: Row(
                    children: [
                      Icon(_showCdnInput ? Icons.expand_less : Icons.expand_more, size: 14, color: NeoTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        _showCdnInput ? 'Sembunyikan input CDN URL' : 'Atau tambah via URL CDN (opsional)',
                        style: const TextStyle(fontSize: 11, color: NeoTheme.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (_showCdnInput) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _imageUrlController,
                          decoration: InputDecoration(
                            hintText: 'https://cdn.example.com/gambar.jpg',
                            hintStyle: const TextStyle(fontSize: 11, color: NeoTheme.textMuted),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black, width: 2)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black, width: 2)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _isSavingImage ? null : _saveCdnUrl,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                          ),
                          child: _isSavingImage
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save_alt_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─────────────── Viral Score Breakdown ───────────────
          if (viralScore > 0) ...[
            Container(
              decoration: NeoTheme.neoBoxDecoration(color: Colors.white, borderRadius: 16, hasShadow: true),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: NeoTheme.accentYellow,
                      border: Border.all(color: Colors.black, width: 2.5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('$viralScore', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VIRAL SCORE BREAKDOWN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                        const SizedBox(height: 8),
                        _buildBar('Hook', _viralBreakdown['hook'] ?? 0, NeoTheme.accentPink),
                        const SizedBox(height: 4),
                        _buildBar('Visual', _viralBreakdown['visual'] ?? 0, NeoTheme.accentGreen),
                        const SizedBox(height: 4),
                        _buildBar('Edukasi', _viralBreakdown['education'] ?? 0, NeoTheme.accentBlue),
                        const SizedBox(height: 4),
                        _buildBar('Engagement', _viralBreakdown['engagement'] ?? 0, Colors.purpleAccent),
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

          // ─────────────── Tab Selector ───────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tabs.map((tab) {
                final isSelected = _viewTab == tab['index'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _viewTab = tab['index'] as int),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        border: Border.all(color: Colors.black, width: 2.5),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected ? null : const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        tab['label'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // ─────────────── Content Viewport ───────────────
          Container(
            constraints: const BoxConstraints(minHeight: 200),
            decoration: NeoTheme.neoBoxDecoration(color: Colors.white, borderRadius: 16, hasShadow: true),
            padding: const EdgeInsets.all(16),
            child: _viewTab == 10
                ? _buildAdvancedVideoStoryboard()
                : _viewTab == 11
                    ? _buildAdvancedVideoOptimizedPrompts()
                    : _viewTab == 12
                        ? _buildAdvancedVideoContinuity()
                        : _viewTab == 13
                            ? _buildAdvancedVideoAuditor()
                            : _viewTab == 3
                                ? _buildAnalysisTab()
                                : _viewTab == 5
                                    ? SelectableText(
                                        _socialMediaCaption,
                                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.5),
                                      )
                                : _viewTab == 4
                                    ? _buildSlidesTab()
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                                            child: Text(
                                              '${(_viewTab == 0 ? _promptFinal : _viewTab == 1 ? _logoExplanation : _payloadJsonString).length} karakter',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                                            ),
                                          ),
                                          SelectableText(
                                            _viewTab == 0 ? _promptFinal : _viewTab == 1 ? _logoExplanation : _payloadJsonString,
                                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.5),
                                          ),
                                        ],
                                      ),
          ),
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
          // ─────────────── Action Buttons ───────────────
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  text: _viewTab == 3
                      ? 'Salin Hooks'
                      : _viewTab == 4
                          ? 'Salin Slide Ini'
                          : _viewTab == 5
                              ? 'Salin Caption'
                              : _viewTab == 10
                                  ? 'Salin Sinopsis'
                                  : _viewTab == 12
                                      ? 'Salin Continuity'
                                      : _viewTab == 13
                                          ? 'Salin Rekomendasi'
                                          : 'Salin DSL',
                  icon: Icons.copy,
                  onTap: () {
                    if (_viewTab == 3) {
                      _copyText(_hooks.join('\n'), 'Hooks disalin!');
                    } else if (_viewTab == 5) {
                      _copyText(_socialMediaCaption, 'Caption disalin!');
                    } else if (_viewTab == 4 && _slides.isNotEmpty) {
                      final s = _slides[_selectedSlideIndex];
                      _copyText(
                        s['prompt'] ?? '',
                        'Slide ${_selectedSlideIndex + 1} disalin!',
                      );
                    } else if (_viewTab == 10) {
                      _copyText(_projectSummary['description'] ?? '', 'Sinopsis disalin!');
                    } else if (_viewTab == 12) {
                      _copyText(_continuityRules, 'Aturan kontinuitas disalin!');
                    } else if (_viewTab == 13) {
                      final recs = _analyzerReport['recommendations'];
                      final allRecs = recs is List ? recs.join('\n') : '';
                      _copyText(allRecs, 'Rekomendasi disalin!');
                    } else {
                      _copyText(_promptFinal, 'DSL disalin!');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionButton(
                  text: 'Download',
                  icon: Icons.download,
                  onTap: _downloadActiveFile,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  text: 'Salin JSON',
                  icon: Icons.code,
                  onTap: () {
                    _copyText(_payloadJsonString, 'JSON disalin!');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ─────────────── Jadikan Template ───────────────
          GestureDetector(
            onTap: _isSavingTemplate ? null : _saveAsTemplate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: NeoTheme.accentYellow,
                border: Border.all(color: Colors.black, width: 2.5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSavingTemplate)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                  else
                    const Icon(Icons.star_rounded, size: 18, color: Colors.black),
                  const SizedBox(width: 6),
                  Text(
                    _isSavingTemplate ? 'Menyimpan...' : '⭐ JADIKAN TEMPLATE',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$value', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildAnalysisTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_analysisShortcomings.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: NeoTheme.accentPink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: NeoTheme.accentPink.withOpacity(0.4), width: 1.5),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️ ANALISIS KEKURANGAN PAYLOAD:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentPink)),
                const SizedBox(height: 8),
                Text(_analysisShortcomings, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (_hooks.isNotEmpty) ...[
          const Text('🔥 COPYWRITING HOOKS VIRAL:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          ..._hooks.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final hook = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: NeoTheme.accentYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: NeoTheme.accentPink,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Text(
                            'Hook #$idx',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _copyText(hook, 'Hook #$idx disalin!'),
                          child: const Icon(Icons.copy, size: 14, color: NeoTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(hook, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
            );
          }),
        ],
        if (_hooks.isEmpty && _analysisShortcomings.isEmpty)
          const Center(child: Text('Tidak ada data analisis untuk prompt ini.', style: TextStyle(color: NeoTheme.textMuted))),
      ],
    );
  }

  Widget _buildSlidesTab() {
    if (_slides.isEmpty) return Center(child: Text(_feature == 'video' ? 'Tidak ada data segmen video.' : 'Tidak ada data slide.'));
    final s = _slides[_selectedSlideIndex];

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
                  'Segmen ${_selectedSlideIndex + 1} / ${_slides.length} (${s['timestamp'] ?? ''})',
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
          const SizedBox(height: 12),
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
                    child: Text('Segmen ${idx + 1}', style: TextStyle(color: active ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          if (s.containsKey('visualPrompt')) ...[
            const Text('🎥 VISUAL ACTIONS & SCENE:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentPink)),
            const SizedBox(height: 4),
            Text(s['visualPrompt'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],

          if (s.containsKey('motionPrompt')) ...[
            const Text('🏃‍♂️ CAMERA & MOTION PATH:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentBlue)),
            const SizedBox(height: 4),
            Text(s['motionPrompt'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],

          if (s.containsKey('transitionPrompt')) ...[
            const Text('🔄 TRANSITION DIRECTIVE:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentGreen)),
            const SizedBox(height: 4),
            Text(s['transitionPrompt'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],

          if (s['textOverlay'] != null && s['textOverlay'].toString().trim().isNotEmpty) ...[
            const Text('💬 TEXT OVERLAY (SUBTITLE):', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.orange)),
            const SizedBox(height: 4),
            Text(s['textOverlay'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],

          if (s['audioSuggestion'] != null && s['audioSuggestion'].toString().trim().isNotEmpty) ...[
            const Text('🎵 AUDIO SUGGESTION:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.purple)),
            const SizedBox(height: 4),
            Text(s['audioSuggestion'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FINAL COMPILED PROMPT FOR VIDEO GENERATOR:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.indigo)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                child: Text(
                  '${(s['prompt'] ?? '').length} karakter',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(12),
            child: SelectableText(s['prompt'] ?? '', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _actionButton(
              text: 'Salin Prompt Segmen Ini',
              icon: Icons.copy,
              onTap: () {
                final promptStr = s['prompt'] ?? '';
                _copyText(promptStr, 'Prompt Segmen ${_selectedSlideIndex + 1} disalin!');
              },
            ),
          ),
        ],
      );
    }

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
              child: Text('Slide ${_selectedSlideIndex + 1} / ${_slides.length}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            ),
            Row(
              children: [
                if (_selectedSlideIndex > 0)
                  GestureDetector(
                    onTap: () => setState(() => _selectedSlideIndex--),
                    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.chevron_left, size: 18)),
                  ),
                const SizedBox(width: 6),
                if (_selectedSlideIndex < _slides.length - 1)
                  GestureDetector(
                    onTap: () => setState(() => _selectedSlideIndex++),
                    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.chevron_right, size: 18, color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
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
                  child: Text('Slide ${idx + 1}', style: TextStyle(color: active ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('SLIDE PROMPT:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentPink)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
              child: Text(
                '${(s['prompt'] ?? s['visualPrompt'] ?? '').length} karakter',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(12),
          child: SelectableText(s['prompt'] ?? s['visualPrompt'] ?? '', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _actionButton(
            text: 'Salin Prompt Slide Ini',
            icon: Icons.copy,
            onTap: () {
              final promptStr = s['prompt'] ?? s['visualPrompt'] ?? '';
              _copyText(promptStr, 'Prompt Slide ${_selectedSlideIndex + 1} disalin!');
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton({required String text, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          ],
        ),
      ),
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

  Widget _buildAdvancedVideoStoryboard() {
    final title = _projectSummary['title'] ?? 'Proyek Tanpa Judul';
    final desc = _projectSummary['description'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3)),
        const Divider(height: 20, color: Colors.black12),
        
        const Text('STORY BIBLE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentPink)),
        const SizedBox(height: 6),
        _buildDetailRow('Story Type', _storyBible['storyType']),
        _buildDetailRow('Narrative Flow', _storyBible['narrative']),
        _buildDetailRow('Conflict', _storyBible['conflict']),
        _buildDetailRow('Resolution', _storyBible['resolution']),
        _buildDetailRow('Emotional Arc', _storyBible['emotionalArc']),
        
        const Divider(height: 20, color: Colors.black12),
        
        const Text('CHARACTER BIBLE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentBlue)),
        const SizedBox(height: 6),
        if (_characterBible.isEmpty)
          const Text('Tidak ada karakter didefinisikan.', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _characterBible.map((c) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text('Rambut: ${c['hair'] ?? '-'}', style: const TextStyle(fontSize: 9)),
                    Text('Baju: ${c['clothes'] ?? '-'}', style: const TextStyle(fontSize: 9, color: Colors.black54)),
                  ],
                ),
              )).toList(),
            ),
          ),
          
        const Divider(height: 20, color: Colors.black12),
        
        const Text('SCENE BREAKDOWN & TIMELINE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentGreen)),
        const SizedBox(height: 6),
        if (_sceneBreakdown.isEmpty)
          const Text('Tidak ada scene didefinisikan.', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic))
        else ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _sceneBreakdown.asMap().entries.map((entry) {
                final idx = entry.key;
                final sc = entry.value;
                final active = _selectedVideoSceneIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedVideoSceneIndex = idx),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6, bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Scene ${sc['sceneNumber'] ?? (idx + 1)}',
                      style: TextStyle(color: active ? Colors.white : Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          () {
            final activeScene = _sceneBreakdown[_selectedVideoSceneIndex];
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.black12, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activeScene['title'] ?? 'Scene Detail', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black87)),
                  const SizedBox(height: 6),
                  _buildDetailRow('Goal', activeScene['goal']),
                  _buildDetailRow('Duration', '${activeScene['duration']}s'),
                  _buildDetailRow('Subject', activeScene['mainSubject']),
                  _buildDetailRow('Action', activeScene['action']),
                  _buildDetailRow('Camera', activeScene['camera']),
                  _buildDetailRow('Lighting', activeScene['lighting']),
                  _buildDetailRow('Transition', activeScene['transition']),
                  if (activeScene['dialogue'] != null && activeScene['dialogue'].toString().isNotEmpty)
                    _buildDetailRow('Dialogue/VO', activeScene['dialogue']),
                  if (activeScene['soundEffect'] != null && activeScene['soundEffect'].toString().isNotEmpty)
                    _buildDetailRow('Sound FX', activeScene['soundEffect']),
                ],
              ),
            );
          }(),
        ],
      ],
    );
  }

  Widget _buildAdvancedVideoOptimizedPrompts() {
    final platforms = ['geminiVeo', 'kling', 'runway', 'pika', 'hailuo'];
    final activePrompt = _optimizedPrompts[_selectedVideoPlatform] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PILIH ENGINE SASUARAN:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: platforms.map((p) {
              final active = _selectedVideoPlatform == p;
              return GestureDetector(
                onTap: () => setState(() => _selectedVideoPlatform = p),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? Colors.purple : Colors.white,
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.toUpperCase(),
                    style: TextStyle(color: active ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 9),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.black38, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            activePrompt.isEmpty ? 'Prompt untuk platform ini belum digenerate.' : activePrompt,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.4),
          ),
        ),
        const SizedBox(height: 10),
        if (activePrompt.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: _actionButton(
              text: 'Copy Prompt ${_selectedVideoPlatform.toUpperCase()}',
              icon: Icons.copy,
              onTap: () => _copyText(activePrompt, 'Prompt berhasil disalin!'),
            ),
          ),
      ],
    );
  }

  Widget _buildAdvancedVideoContinuity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CONTINUITY RULES & VISUAL TRACKING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NeoTheme.accentPink)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.black12, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_continuityRules.isEmpty ? 'Tidak ada aturan kontinuitas khusus.' : _continuityRules, style: const TextStyle(fontSize: 11, height: 1.4)),
        ),
        const SizedBox(height: 16),
        const Text('VIDEO NEGATIVE PROMPTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFFFFEBEE),
            border: Border.all(color: Colors.redAccent, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_negativePromptVal.isEmpty ? 'Tidak ada prompt negatif khusus.' : _negativePromptVal, style: const TextStyle(fontSize: 11, height: 1.4, color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildAdvancedVideoAuditor() {
    final grade = _analyzerReport['qualityGrade'] ?? 'A';
    final recs = _analyzerReport['recommendations'];
    List<String> recommendationList = [];
    if (recs is List) {
      recommendationList = recs.map((e) => e.toString()).toList();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('SMART AI AUDITOR REPORT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black87)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: NeoTheme.accentGreen,
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'GRADE $grade',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDetailRow('Character Consistency', _analyzerReport['characterConsistency']),
        _buildDetailRow('Story Logic', _analyzerReport['storyLogic']),
        _buildDetailRow('Camera Flow', _analyzerReport['cameraFlow']),
        _buildDetailRow('Lighting Consistency', _analyzerReport['lightingConsistency']),
        _buildDetailRow('Continuity evaluation', _analyzerReport['continuityEvaluation']),
        if (_analyzerReport['instructionConflicts'] != null)
          _buildDetailRow('Instruction Conflicts', _analyzerReport['instructionConflicts']),
          
        const Divider(height: 20, color: Colors.black12),
        const Text('AI RECOMMENDATIONS:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.blueGrey)),
        const SizedBox(height: 6),
        if (recommendationList.isEmpty)
          const Text('Semua sistem optimal. Tidak ada peringatan khusus.', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic))
        else
          ...recommendationList.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️ ', style: TextStyle(fontSize: 11)),
                Expanded(child: Text(rec, style: const TextStyle(fontSize: 11, height: 1.3))),
              ],
            ),
          )),
      ],
    );
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

