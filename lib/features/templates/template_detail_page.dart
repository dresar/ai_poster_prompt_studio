import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/neo_theme.dart';
import '../../shared/widgets/neo_buttons.dart';
import '../../shared/widgets/image_carousel_modal.dart';
import '../../core/utils/file_directory_helper.dart';

class TemplateDetailPage extends StatefulWidget {
  final Map<String, dynamic> templateData;
  final Function(String category)? onUseTemplate;

  const TemplateDetailPage({
    super.key,
    required this.templateData,
    this.onUseTemplate,
  });

  @override
  State<TemplateDetailPage> createState() => _TemplateDetailPageState();
}

class _TemplateDetailPageState extends State<TemplateDetailPage> {
  late String _title;
  late String _category;
  late String _promptText;
  String? _previewImageUrl;
  int _viralScore = 0;
  Map<String, dynamic> _viralBreakdown = {};
  Map<String, dynamic> _payloadJson = {};
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _parseData();
  }

  void _parseData() {
    final data = widget.templateData;
    _category = (data['category'] ?? 'poster').toString();

    _payloadJson = Map<String, dynamic>.from(data['payloadJson'] ?? {});
    final formState = Map<String, dynamic>.from(_payloadJson['formState'] ?? {});

    final topic = data['title'] ?? formState['topic'] ?? _payloadJson['topic'] ?? '';
    if (topic.toString().isNotEmpty) {
      _title = topic.toString();
    } else {
      final catLabel = _category.isNotEmpty
          ? '${_category.substring(0, 1).toUpperCase()}${_category.substring(1)}'
          : 'Poster';
      _title = 'Template $catLabel';
    }

    _promptText = data['template'] ?? _payloadJson['output']?['promptFinal'] ?? _payloadJson['promptFinal'] ?? '';
    _previewImageUrl = data['previewImageUrl'] as String?;

    _viralScore = (data['viralScore'] as int?) ?? (_payloadJson['output']?['viralScore'] as int?) ?? 85;

    final bd = data['viralBreakdown'] ?? _payloadJson['output']?['viralBreakdown'] ?? _payloadJson['viralBreakdown'];
    if (bd is Map<String, dynamic>) {
      _viralBreakdown = bd;
    } else {
      _viralBreakdown = {
        'hook': 90,
        'visual': 88,
        'education': 85,
        'engagement': 92,
      };
    }

    // Collect images if available
    _imageUrls = [];
    if (_previewImageUrl != null && _previewImageUrl!.isNotEmpty) {
      _imageUrls.add(_previewImageUrl!);
    }

    final slides = _payloadJson['slidesContent'] ?? _payloadJson['output']?['slidesContent'];
    if (slides is List) {
      for (final s in slides) {
        if (s is Map && s['imageUrl'] != null && s['imageUrl'].toString().isNotEmpty) {
          final url = s['imageUrl'].toString();
          if (!_imageUrls.contains(url)) {
            _imageUrls.add(url);
          }
        }
      }
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

  Future<void> _downloadJson() async {
    try {
      final jsonStr = const JsonEncoder.withIndent('  ').convert(_payloadJson);
      final filename = 'template_${DateTime.now().millisecondsSinceEpoch}.json';
      await FileDirectoryHelper.saveFile(
        content: jsonStr,
        fileName: filename,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚡ File JSON berhasil diunduh!'), backgroundColor: NeoTheme.accentGreen),
        );
      }
    } catch (e) {
      debugPrint('Download error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      appBar: AppBar(
        backgroundColor: NeoTheme.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Template',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Image Preview (Clickable Lightbox Carousel) ──
            GestureDetector(
              onTap: () {
                if (_imageUrls.isNotEmpty) {
                  ImageCarouselModal.show(context, _imageUrls);
                }
              },
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2.5),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _previewImageUrl != null && _previewImageUrl!.isNotEmpty
                        ? Image.network(
                            _previewImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  if (_imageUrls.isNotEmpty)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.fullscreen, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _imageUrls.length > 1 ? '${_imageUrls.length} Slide (Klik)' : 'Lihat Gambar',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Category & Title ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeoTheme.accentPink,
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _category.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeoTheme.accentGreen,
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        'VIRAL SCORE $_viralScore%',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              _title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
            ),
            const SizedBox(height: 20),

            // ── Viral Breakdown Section ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔥 Potensi Viral Breakdown', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildScoreBar('Hook Power', _viralBreakdown['hook'] ?? 90, NeoTheme.accentPink),
                  const SizedBox(height: 8),
                  _buildScoreBar('Visual Aesthetics', _viralBreakdown['visual'] ?? 88, NeoTheme.accentYellow),
                  const SizedBox(height: 8),
                  _buildScoreBar('Edukasi / Nilai', _viralBreakdown['education'] ?? 85, NeoTheme.accentBlue),
                  const SizedBox(height: 8),
                  _buildScoreBar('Engagement', _viralBreakdown['engagement'] ?? 92, NeoTheme.accentGreen),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Master Prompt Text ──
            if (_promptText.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('📜 Teks Master Prompt', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        GestureDetector(
                          onTap: () => _copyText(_promptText, '📋 Master Prompt berhasil disalin!'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: NeoTheme.accentBlue,
                              border: Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.copy, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text('Salin Prompt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 180),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _promptText,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── JSON Output Section ──
            if (_payloadJson.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📦 Structure Data JSON', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: NeoSecondaryButton(
                            text: 'SALIN JSON',
                            icon: const Icon(Icons.code, color: Colors.black, size: 16),
                            onPressed: () {
                              final jsonStr = const JsonEncoder.withIndent('  ').convert(_payloadJson);
                              _copyText(jsonStr, '📋 Data JSON berhasil disalin!');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: NeoSecondaryButton(
                            text: 'UNDUH JSON',
                            icon: const Icon(Icons.download, color: Colors.black, size: 16),
                            onPressed: _downloadJson,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Gunakan Template Action ──
            NeoPrimaryButton(
              text: '⚡ GUNAKAN TEMPLATE INI',
              icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.pop(context);
                if (widget.onUseTemplate != null) {
                  widget.onUseTemplate!(_category);
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, dynamic scoreVal, Color barColor) {
    final val = (scoreVal is int) ? scoreVal : (int.tryParse(scoreVal.toString()) ?? 85);
    final clamped = val.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('$clamped%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: clamped / 100.0,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_customize, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('Template Visual', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
