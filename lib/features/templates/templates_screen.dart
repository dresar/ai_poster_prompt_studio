import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/neo_theme.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/local_db_service.dart';
import '../../shared/widgets/neo_buttons.dart';
import '../../core/utils/file_directory_helper.dart';
import '../saved_codes/saved_codes_screen.dart';


class TemplatesScreen extends StatefulWidget {
  final Function(String category)? onUseTemplate;

  const TemplatesScreen({super.key, this.onUseTemplate});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  List<dynamic> _templates = [];
  List<String> _categories = ['Semua'];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _isLoading = false;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCachedTemplates();
  }

  Future<void> _loadCachedTemplates() async {
    try {
      final cached = await LocalDbService.instance.getCachedTemplatesJson();
      if (cached != null) {
        final list = jsonDecode(cached) as List;
        setState(() {
          _templates = list;
        });
      }
    } catch (e) {
      debugPrint('Templates cache load error: $e');
    }
    _fetchCategories();
    _fetchTemplates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await dioClient.get('/templates/categories');
      if (response.data['success'] == true) {
        final cats = List<String>.from(response.data['data'] ?? []);
        setState(() => _categories = ['Semua', ...cats]);
      }
    } catch (e) {
      debugPrint('Categories fetch error: $e');
    }
  }

  Future<void> _fetchTemplates() async {
    if (_templates.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final params = <String, dynamic>{};
      if (_selectedCategory != 'Semua') params['category'] = _selectedCategory;
      if (_searchQuery.isNotEmpty) params['search'] = _searchQuery;

      final response = await dioClient.get('/templates', queryParameters: params);
      if (response.data['success'] == true) {
        final list = response.data['data'] ?? [];
        setState(() => _templates = list);
        if (_selectedCategory == 'Semua' && _searchQuery.isEmpty) {
          LocalDbService.instance.cacheTemplatesJson(jsonEncode(list));
        }
      }
    } catch (e) {
      debugPrint('Templates fetch error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openTemplate(Map<String, dynamic> template, String displayTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NeoTheme.bgBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: NeoTheme.borderStrong, width: 2.5),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.85,
        maxChildSize: 0.98,
        expand: false,
        builder: (context, scrollController) => _TemplateDetailSheet(
          template: template,
          displayTitle: displayTitle,
          scrollController: scrollController,
          onUseTemplate: widget.onUseTemplate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      appBar: AppBar(
        backgroundColor: NeoTheme.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 48),
            const SizedBox(width: 12),
            Text(
              'Templates',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 24),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
                _fetchTemplates();
              },
              decoration: InputDecoration(
                hintText: 'Cari template...',
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: Colors.black, width: 2.5)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: Colors.black, width: 2.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: NeoTheme.accentPink, width: 2.5)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Category chips
          if (_categories.length > 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      _fetchTemplates();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? NeoTheme.accentPink : Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.zero,
                        boxShadow: isSelected ? null : const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),

          // Templates grid / list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: NeoTheme.accentPink))
                : _templates.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: _templates.length,
                        itemBuilder: (context, index) {
                          final tpl = _templates[index] as Map<String, dynamic>;
                          return _buildTemplateCard(tpl);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> tpl) {
    final category = tpl['category'] ?? '';
    final previewImageUrl = tpl['previewImageUrl'] as String?;

    // Build display title: e.g. "Template Poster #1"
    final categoryTemplates = _templates.where((t) => t['category'] == category).toList();
    final indexInCategory = categoryTemplates.indexOf(tpl);
    final catLabel = category.isNotEmpty
        ? '${category.substring(0, 1).toUpperCase()}${category.substring(1)}'
        : 'Template';
    final displayTitle = 'Template $catLabel #${indexInCategory != -1 ? indexInCategory + 1 : 1}';

    return GestureDetector(
      onTap: () => _openTemplate(tpl, displayTitle),
      child: Container(
        decoration: NeoTheme.neoBoxDecoration(color: Colors.white, borderRadius: 0, hasShadow: true),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image (clean, no overlay text) ──
            Expanded(
              child: previewImageUrl != null && previewImageUrl.isNotEmpty
                  ? Image.network(
                      previewImageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(catLabel),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: const Color(0xFFF3F3F3),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: NeoTheme.accentPink),
                            ),
                          ),
                        );
                      },
                    )
                  : _buildImagePlaceholder(catLabel),
            ),

            // ── Title ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Text(
                displayTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, height: 1.3),
              ),
            ),

            const SizedBox(height: 6),

            // ── Use button ──
            GestureDetector(
              onTap: () => _openTemplate(tpl, displayTitle),
              child: Container(
                width: double.infinity,
                color: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Center(
                  child: Text(
                    'GUNAKAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(String catLabel) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F0F0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 36, color: Color(0xFFBBBBBB)),
          const SizedBox(height: 6),
          Text(
            catLabel,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFFAAAAAA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
              ),
              child: Column(
                children: [
                  const Text('📋', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'Belum Ada Template',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Admin belum menambahkan template apapun. Coba lagi nanti.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: NeoTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateDetailSheet extends StatefulWidget {
  final Map<String, dynamic> template;
  final String displayTitle;
  final ScrollController scrollController;
  final Function(String category)? onUseTemplate;

  const _TemplateDetailSheet({
    required this.template,
    required this.displayTitle,
    required this.scrollController,
    this.onUseTemplate,
  });

  @override
  State<_TemplateDetailSheet> createState() => _TemplateDetailSheetState();
}

class _TemplateDetailSheetState extends State<_TemplateDetailSheet> {
  int _viewTab = 0; // 0 = DSL Code, 1 = Analisis & Hooks, 2 = Payload JSON
  late String _templateText;
  late String _category;
  late String _payloadJsonString;
  late String _analysisText;
  late List<String> _hooks;
  late int _viralScore;

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: NeoTheme.accentBlue),
    );
  }

  Future<void> _downloadActiveFile() async {
    try {
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String content = '';
      String ext = 'txt';
      String prefix = 'Template';

      if (_viewTab == 1) {
        final allHooks = _hooks.join('\n');
        content = 'ANALISIS TEMPLATE:\n$_analysisText\n\nHOOKS:\n$allHooks';
        prefix = 'Hooks';
      } else if (_viewTab == 2) {
        content = _payloadJsonString;
        ext = 'json';
        prefix = 'Payload';
      } else {
        content = _templateText;
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
  void initState() {
    super.initState();
    _category = widget.template['category'] ?? '';
    _templateText = widget.template['template'] ?? '';
    
    // Stable but unique viral score based on category
    _viralScore = 85 + (_category.hashCode % 11);

    final categoryLabel = _category.toUpperCase();
    _hooks = [
      "Mengapa desain $categoryLabel Anda sepi penonton? Gunakan template ini untuk melipatgandakan konversi!",
      "3 Aturan emas membuat konten visual $categoryLabel yang disukai audiens & algoritma.",
      "Rahasia tersembunyi di balik layout $categoryLabel viral yang jarang dibagikan oleh kreator pro."
    ];

    _analysisText = "Template ini menggunakan struktur visual optimal yang disesuaikan khusus untuk kategori $_category. "
        "Memadukan pembagian whitespace seimbang dan tata letak kontras untuk memperkuat daya tarik audiens dalam 3 detik pertama.";

    final mockPayload = _buildMockPayload(_templateText, _category);
    _payloadJsonString = const JsonEncoder.withIndent('  ').convert(mockPayload);
  }

  Map<String, dynamic> _buildMockPayload(String templateText, String category) {
    final Map<String, dynamic> payload = {
      'feature': category,
    };
    final regExp = RegExp(r'\{\{([^}]+)\}\}');
    final matches = regExp.allMatches(templateText);
    for (final m in matches) {
      final key = m.group(1)!.trim();
      if (key == 'topic') {
        payload['topic'] = '[Topik Utama / Judul]';
      } else if (key == 'description') {
        payload['description'] = '[Deskripsi Pendukung]';
      } else if (key == 'keyPoints') {
        payload['keyPoints'] = ['[Poin 1]', '[Poin 2]', '[Poin 3]'];
      } else if (key == 'style') {
        payload['style'] = '[Gaya Desain / Visual Style]';
      } else if (key == 'layout') {
        payload['layout'] = '[Tata Letak / Posisi]';
      } else if (key == 'aspectRatio') {
        payload['aspectRatio'] = '[Rasio Aspek Gambar]';
      } else if (key == 'colorPalette') {
        payload['colorPalette'] = '[Tema Warna / Palet]';
      } else if (key == 'mood') {
        payload['mood'] = '[Nuansa / Mood]';
      } else if (key == 'cta') {
        payload['cta'] = '[Call to Action]';
      } else if (key == 'watermark') {
        payload['watermark'] = '[Teks Watermark]';
      } else if (key == 'negativePrompt') {
        payload['negativePrompt'] = '[Elemen yang Dihindari]';
      } else {
        payload[key] = '[${key.toUpperCase()}]';
      }
    }
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'label': 'DSL CODE', 'index': 0},
      {'label': 'ANALISIS & HOOKS', 'index': 1},
      {'label': 'PAYLOAD JSON', 'index': 2},
    ];

    final viralBreakdown = {
      'hook': 80 + (_category.hashCode % 15),
      'visual': 85 + (_category.hashCode % 11),
      'education': 75 + (_category.hashCode % 19),
      'engagement': 82 + (_category.hashCode % 13),
    };

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        controller: widget.scrollController,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: NeoTheme.borderStrong,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: NeoTheme.accentYellow,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Text(
                        _category.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.displayTitle,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: NeoTheme.accentPink,
                    border: Border.all(color: Colors.black, width: 2.5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Viral Score Card
          Container(
            decoration: NeoTheme.neoBoxDecoration(
              color: Colors.white,
              borderRadius: 20,
              hasShadow: true,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Score Circle
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
                    '$_viralScore',
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
                      _buildBreakdownBar('Hook', viralBreakdown['hook'] ?? 0, NeoTheme.accentPink),
                      const SizedBox(height: 4),
                      _buildBreakdownBar('Visual', viralBreakdown['visual'] ?? 0, NeoTheme.accentGreen),
                      const SizedBox(height: 4),
                      _buildBreakdownBar('Edukasi', viralBreakdown['education'] ?? 0, NeoTheme.accentBlue),
                      const SizedBox(height: 4),
                      _buildBreakdownBar('Engagement', viralBreakdown['engagement'] ?? 0, Colors.purpleAccent),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tab Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: tabs.map((tab) {
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
                        boxShadow: isSelected ? null : const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
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
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Viewport Card
          Container(
            height: 300,
            decoration: NeoTheme.neoBoxDecoration(
              color: Colors.white,
              borderRadius: 20,
              hasShadow: true,
            ),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: _buildViewportContent(),
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: NeoSecondaryButton(
                  text: _viewTab == 1 ? 'Salin Hooks' : _viewTab == 2 ? 'Salin JSON' : 'Salin DSL',
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    if (_viewTab == 1) {
                      final allHooks = _hooks.join('\n');
                      _copyToClipboard('ANALISIS TEMPLATE:\n$_analysisText\n\nHOOKS:\n$allHooks', 'Analisis & Hooks disalin!');
                    } else if (_viewTab == 2) {
                      _copyToClipboard(_payloadJsonString, 'JSON disalin!');
                    } else {
                      _copyToClipboard(_templateText, 'DSL disalin!');
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

          // Primary Use Button
          if (widget.onUseTemplate != null) ...[
            NeoPrimaryButton(
              text: 'GUNAKAN TEMPLATE',
              backgroundColor: NeoTheme.accentPink,
              onPressed: () {
                Navigator.pop(context);
                widget.onUseTemplate!(_category);
              },
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildViewportContent() {
    if (_viewTab == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: NeoTheme.accentPink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: NeoTheme.borderStrong, width: 1.5),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('💡 ', style: TextStyle(fontSize: 16)),
                    Text(
                      'ANALISIS STRUKTUR TEMPLATE:',
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
                  _analysisText,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '🔥 PILIHAN HOOK COPYWRITING TEMPLATE:',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),
          ..._hooks.map((hook) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: NeoTheme.accentYellow.withOpacity(0.1),
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
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      );
    } else if (_viewTab == 2) {
      return Text(
        _payloadJsonString,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      );
    } else {
      return Text(
        _templateText,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      );
    }
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
}
