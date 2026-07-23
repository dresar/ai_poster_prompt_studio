import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/neo_theme.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/local_db_service.dart';
import '../dashboard/widgets/external_prompt_screen.dart';
import 'history_detail_page.dart';
import '../../shared/widgets/image_carousel_modal.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCreate;

  const HistoryScreen({super.key, this.onNavigateToCreate});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _activeTab = 0; // 0: Riwayat Hasil Visual, 1: Riwayat Salin Prompting (Draft)
  List<dynamic> _prompts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedMode;
  bool _onlyFavorites = false;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCachedHistory();
  }

  Future<void> _loadCachedHistory() async {
    try {
      final cached = await LocalDbService.instance.getCachedHistoryJson();
      if (cached != null && _activeTab == 0) {
        final list = (jsonDecode(cached) as List)
            .where((item) => item['mode'] != 'external_draft')
            .toList();
        setState(() {
          _prompts = list;
        });
      }
    } catch (e) {
      debugPrint('History cache load error: $e');
    }
    _fetchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    if (_prompts.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final queryParams = {
        'page': 1,
        'limit': 50,
        'type': _activeTab == 0 ? 'result' : 'draft',
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
        if (_selectedMode != null) 'mode': _selectedMode,
        if (_onlyFavorites) 'favorite': 'true',
      };
      final response = await dioClient.get('/history', queryParameters: queryParams);
      if (response.data['success'] == true) {
        final rawList = (response.data['data']['prompts'] as List?) ?? [];
        final list = rawList.where((item) {
          final isDraft = item['mode'] == 'external_draft';
          return _activeTab == 0 ? !isDraft : isDraft;
        }).toList();

        setState(() => _prompts = list);
        if (_activeTab == 0 && _searchQuery.isEmpty && _selectedMode == null && !_onlyFavorites) {
          LocalDbService.instance.cacheHistoryJson(jsonEncode(list));
        }
      }
    } catch (e) {
      debugPrint('History fetch error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePrompt(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 2.5),
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Hapus Prompt', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Apakah Anda yakin ingin menghapus item ini dari riwayat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NeoTheme.accentPink,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await dioClient.delete('/history/$id');
        if (response.data['success'] == true) {
          _fetchHistory();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item berhasil dihapus'), backgroundColor: NeoTheme.accentPink),
            );
          }
        }
      } catch (e) {
        debugPrint('Delete error: $e');
      }
    }
  }

  Future<void> _duplicatePrompt(String id) async {
    try {
      final response = await dioClient.post('/history/$id/duplicate');
      if (response.data['success'] == true) {
        _fetchHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prompt berhasil diduplikasi'), backgroundColor: NeoTheme.accentGreen),
          );
        }
      }
    } catch (e) {
      debugPrint('Duplicate error: $e');
    }
  }

  void _openExternalDraftScreen(dynamic prompt) {
    final payload = prompt['payloadJson'] ?? {};
    final formState = Map<String, dynamic>.from(payload['formState'] ?? {});
    if (formState.isEmpty) {
      formState['topic'] = prompt['topic'] ?? '';
      formState['feature'] = prompt['category'] ?? 'poster';
    }
    final String id = prompt['id']?.toString() ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExternalPromptScreen(
          formState: formState,
          draftId: id,
        ),
      ),
    ).then((result) {
      _fetchHistory();
      if (result != null && mounted) {
        final promptObj = result['prompt'] ?? result;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoryDetailPage(
              promptData: Map<String, dynamic>.from(promptObj),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      appBar: AppBar(
        backgroundColor: NeoTheme.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'RIWAYAT APLIKASI',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          // ── Dual Tab Header Switcher ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 2.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_activeTab != 0) {
                          setState(() {
                            _activeTab = 0;
                            _prompts = [];
                          });
                          _fetchHistory();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _activeTab == 0 ? NeoTheme.accentBlue : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)),
                        ),
                        child: Text(
                          '🎨 Hasil Visual',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: _activeTab == 0 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 2, height: 40, color: Colors.black),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_activeTab != 1) {
                          setState(() {
                            _activeTab = 1;
                            _prompts = [];
                          });
                          _fetchHistory();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _activeTab == 1 ? NeoTheme.accentYellow : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(13)),
                        ),
                        child: Text(
                          '📋 Salin Prompting',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Search + filter header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Container(
                  decoration: NeoTheme.neoBoxDecoration(color: Colors.white, borderRadius: 16, hasShadow: false),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() => _searchQuery = val.trim());
                      _fetchHistory();
                    },
                    decoration: InputDecoration(
                      hintText: _activeTab == 0 ? 'Cari hasil visual...' : 'Cari draf prompt eksternal...',
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NeoTheme.accentPink, width: 2.5)),
                    ),
                  ),
                ),
                if (_activeTab == 0) ...[
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          selected: _selectedMode == 'poster',
                          label: const Text('Poster'),
                          backgroundColor: Colors.white,
                          selectedColor: NeoTheme.accentYellow,
                          onSelected: (val) { setState(() => _selectedMode = val ? 'poster' : null); _fetchHistory(); },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: _selectedMode == 'video',
                          label: const Text('Video'),
                          backgroundColor: Colors.white,
                          selectedColor: NeoTheme.accentYellow,
                          onSelected: (val) { setState(() => _selectedMode = val ? 'video' : null); _fetchHistory(); },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: _selectedMode == 'photo_enhance',
                          label: const Text('Retouch'),
                          backgroundColor: Colors.white,
                          selectedColor: NeoTheme.accentYellow,
                          onSelected: (val) { setState(() => _selectedMode = val ? 'photo_enhance' : null); _fetchHistory(); },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: _onlyFavorites,
                          label: const Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber),
                              SizedBox(width: 4),
                              Text('Favorit'),
                            ],
                          ),
                          backgroundColor: Colors.white,
                          selectedColor: NeoTheme.accentYellow,
                          onSelected: (val) { setState(() => _onlyFavorites = val); _fetchHistory(); },
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: NeoTheme.accentPink))
                : _prompts.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        itemCount: _prompts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final prompt = _prompts[index];
                          return _activeTab == 0
                              ? _buildResultCard(prompt)
                              : _buildDraftCard(prompt);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(dynamic prompt) {
    final id = prompt['id'] ?? '';
    final topic = prompt['topic'] ?? '';
    final mode = prompt['mode'] ?? '';
    final viralScore = prompt['viralScore'] ?? 0;
    final dateStr = prompt['createdAt'] ?? '';
    final isFav = prompt['isFavorite'] ?? false;
    final category = prompt['category'] ?? '';

    String? previewUrl = prompt['referenceImageUrl'] as String?;
    if (previewUrl == null || previewUrl.isEmpty) {
      final payload = prompt['payloadJson'] ?? {};
      previewUrl = payload['input']?['imageUrl'] as String?;
    }

    String dateFormatted = '';
    try {
      dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(dateStr));
    } catch (_) {
      dateFormatted = dateStr;
    }

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async { await _deletePrompt(id); return false; },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HistoryDetailPage(promptData: Map<String, dynamic>.from(prompt)),
            ),
          );
        },
        child: Container(
          decoration: NeoTheme.neoBoxDecoration(color: Colors.white, borderRadius: 20, hasShadow: true),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (previewUrl != null && previewUrl.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    final String nonNullUrl = previewUrl!;
                    final payload = prompt['payloadJson'] ?? {};
                    final List<String> urls = [nonNullUrl];
                    final slides = payload['slidesContent'] ?? payload['output']?['slidesContent'];
                    if (slides is List) {
                      for (final s in slides) {
                        if (s is Map && s['imageUrl'] != null && s['imageUrl'].toString().isNotEmpty) {
                          final u = s['imageUrl'].toString();
                          if (!urls.contains(u)) urls.add(u);
                        }
                      }
                    }
                    ImageCarouselModal.show(context, urls);
                  },
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Image.network(
                      previewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[100],
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: NeoTheme.accentBlue,
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Text(
                            mode.toString().toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: NeoTheme.accentYellow,
                            border: Border.all(color: Colors.black, width: 1.5),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Text('$viralScore', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      topic,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Style: $category', style: const TextStyle(fontSize: 12, color: NeoTheme.textMuted)),
                    ],
                    const SizedBox(height: 10),
                    const Divider(color: Colors.black12, height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateFormatted, style: const TextStyle(fontSize: 11, color: NeoTheme.textMuted)),
                        Row(
                          children: [
                            if (isFav) const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => _duplicatePrompt(id),
                              child: const Icon(Icons.copy, size: 18, color: NeoTheme.textPrimary),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => _deletePrompt(id),
                              child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraftCard(dynamic prompt) {
    final id = prompt['id'] ?? '';
    final topic = prompt['topic'] ?? 'Draf Prompt Eksternal';
    final dateStr = prompt['createdAt'] ?? '';
    final category = prompt['category'] ?? 'poster';
    final instructionsText = prompt['promptFinal'] ?? '';

    final payload = prompt['payloadJson'] ?? {};
    final bool isImported = payload['isImported'] == true || payload['importedPromptId'] != null;
    final importedPromptData = payload['importedPromptData'];

    String dateFormatted = '';
    try {
      dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(dateStr));
    } catch (_) {
      dateFormatted = dateStr;
    }

    return Container(
      decoration: NeoTheme.neoBoxDecoration(
        color: isImported ? const Color(0xFFE8F5E9) : const Color(0xFFFFFDE7),
        borderRadius: 20,
        hasShadow: true,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.psychology, size: 12, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(
                            'AI EKSTERNAL: ${category.toUpperCase()}',
                            style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    if (isImported) ...[
                      const SizedBox(width: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8E6C9),
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        child: const Text(
                          '✅ SUDAH IMPORT',
                          style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(dateFormatted, style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              topic,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black26),
              ),
              child: Text(
                instructionsText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NeoTheme.accentYellow,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(
                      isImported ? 'BUKA DRAF' : 'BUKA & IMPORT',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                    onPressed: () => _openExternalDraftScreen(prompt),
                  ),
                ),
                if (isImported && importedPromptData != null) ...[
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NeoTheme.accentBlue,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    icon: const Icon(Icons.remove_red_eye, size: 16, color: Colors.white),
                    label: const Text(
                      'HASIL',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryDetailPage(promptData: importedPromptData),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.black, size: 20),
                  tooltip: 'Salin Teks Prompt',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: instructionsText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('📋 Teks instruksi prompt berhasil disalin!'), backgroundColor: Colors.black),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  tooltip: 'Hapus Draf',
                  onPressed: () => _deletePrompt(id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDraft = _activeTab == 1;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          decoration: NeoTheme.neoBoxDecoration(color: Colors.white, borderRadius: 24, hasShadow: true),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: minAxis,
            children: [
              Text(isDraft ? '📋' : '📭', style: const TextStyle(fontSize: 50)),
              const SizedBox(height: 16),
              Text(
                isDraft ? 'Belum Ada Riwayat Salin Prompting' : 'Belum Ada Riwayat Hasil',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                isDraft
                    ? 'Draf instruksi prompt yang kamu generat untuk ChatGPT/Claude akan otomatis tersimpan di sini.'
                    : 'Kamu belum membuat prompt poster atau video apapun.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: NeoTheme.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeoTheme.accentPink,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 2.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => widget.onNavigateToCreate?.call(),
                child: Text(
                  isDraft ? 'Buat Prompt Eksternal Baru' : 'Buat Prompt Pertamamu',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
const minAxis = MainAxisSize.min;
