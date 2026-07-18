import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/neo_theme.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/local_db_service.dart';
import 'history_detail_page.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCreate;

  const HistoryScreen({super.key, this.onNavigateToCreate});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
      if (cached != null) {
        final list = jsonDecode(cached) as List;
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
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
        if (_selectedMode != null) 'mode': _selectedMode,
        if (_onlyFavorites) 'favorite': 'true',
      };
      final response = await dioClient.get('/history', queryParameters: queryParams);
      if (response.data['success'] == true) {
        final list = response.data['data']['prompts'] ?? [];
        setState(() => _prompts = list);
        if (_searchQuery.isEmpty && _selectedMode == null && !_onlyFavorites) {
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
        content: const Text('Apakah Anda yakin ingin menghapus prompt ini dari riwayat?'),
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
              const SnackBar(content: Text('Prompt berhasil dihapus'), backgroundColor: NeoTheme.accentPink),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      appBar: AppBar(
        backgroundColor: NeoTheme.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'RIWAYAT EKSEKUSI',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          // Search + filter sticky header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                      hintText: 'Cari topik atau kata kunci...',
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NeoTheme.accentPink, width: 2.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        selected: _selectedMode == 'poster',
                        label: const Text('Buat Poster'),
                        backgroundColor: Colors.white,
                        selectedColor: NeoTheme.accentYellow,
                        onSelected: (val) { setState(() => _selectedMode = val ? 'poster' : null); _fetchHistory(); },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: _selectedMode == 'video',
                        label: const Text('Video Prompt'),
                        backgroundColor: Colors.white,
                        selectedColor: NeoTheme.accentYellow,
                        onSelected: (val) { setState(() => _selectedMode = val ? 'video' : null); _fetchHistory(); },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: _selectedMode == 'photo_enhance',
                        label: const Text('Percantik Foto'),
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
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final prompt = _prompts[index];
                          final id = prompt['id'] ?? '';
                          final topic = prompt['topic'] ?? '';
                          final mode = prompt['mode'] ?? '';
                          final viralScore = prompt['viralScore'] ?? 0;
                          final dateStr = prompt['createdAt'] ?? '';
                          final isFav = prompt['isFavorite'] ?? false;
                          final category = prompt['category'] ?? '';

                          // Image preview: check referenceImageUrl or payloadJson.input.imageUrl
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
                                    // ── Preview Image (top) ──
                                    if (previewUrl != null && previewUrl.isNotEmpty)
                                      SizedBox(
                                        height: 140,
                                        width: double.infinity,
                                        child: Image.network(
                                          previewUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: Colors.grey[100],
                                            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
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
                                              (() {
                                                final normalized = mode.toLowerCase();
                                                String label = 'POSTER';
                                                Color bg = NeoTheme.accentBlue;
                                                Color fg = Colors.white;

                                                if (normalized == 'poster') {
                                                  label = 'POSTER';
                                                  bg = NeoTheme.accentBlue;
                                                } else if (normalized == 'banner') {
                                                  label = 'BANNER';
                                                  bg = NeoTheme.accentBlue;
                                                } else if (normalized == 'edukasi') {
                                                  label = 'EDUKASI';
                                                  bg = NeoTheme.accentGreen;
                                                } else if (normalized == 'affiliate') {
                                                  label = 'AFFILIATE';
                                                  bg = NeoTheme.accentPink;
                                                } else if (normalized == 'digital_product') {
                                                  label = 'PRODUK DIGITAL';
                                                  bg = NeoTheme.accentPink;
                                                } else if (normalized == 'baliho') {
                                                  label = 'BALIHO';
                                                  bg = NeoTheme.accentBlue;
                                                } else if (normalized == 'logo') {
                                                  label = 'LOGO';
                                                  bg = NeoTheme.accentGreen;
                                                } else if (normalized == 'quotes') {
                                                  label = 'QUOTES';
                                                  bg = NeoTheme.accentYellow;
                                                  fg = Colors.black;
                                                } else if (normalized == 'photo_enhance') {
                                                  label = 'RETOUCH';
                                                  bg = NeoTheme.accentPink;
                                                } else if (normalized == 'video') {
                                                   label = 'VIDEO PROMPT';
                                                   bg = Colors.deepPurpleAccent;
                                                 } else {
                                                  label = mode.toUpperCase();
                                                  bg = NeoTheme.accentPink;
                                                }

                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: bg,
                                                    border: Border.all(color: Colors.black, width: 1.5),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  child: Text(
                                                    label,
                                                    style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.w900),
                                                  ),
                                                );
                                              })(),
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
                        },
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
        child: Container(
          decoration: NeoTheme.neoBoxDecoration(color: Colors.white, borderRadius: 24, hasShadow: true),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📭', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 16),
              Text('Belum Ada Riwayat', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Kamu belum membuat prompt apapun.', textAlign: TextAlign.center, style: TextStyle(color: NeoTheme.textMuted)),
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
                child: const Text('Buat Prompt Pertamamu', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
