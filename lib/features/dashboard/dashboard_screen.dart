import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/theme/neo_theme.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/cache_service.dart';
import '../../shared/widgets/neo_info_banner.dart';
import '../../shared/widgets/neo_dropdown_field.dart';
import '../../shared/widgets/neo_buttons.dart';
import '../../shared/widgets/sync_update_banner.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/local_db_service.dart';
import 'dropdown_provider.dart';
import '../result/result_view.dart';
import '../settings/settings_screen.dart';
import '../history/history_screen.dart';
import '../settings/system_settings_provider.dart';
import '../auth/auth_provider.dart';
import '../templates/templates_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/poster_form.dart';
import 'widgets/banner_form.dart';
import 'widgets/edukasi_form.dart';
import 'widgets/affiliate_form.dart';
import 'widgets/digital_product_form.dart';
import 'widgets/baliho_form.dart';
import 'widgets/logo_form.dart';
import 'widgets/quotes_form.dart';
import 'widgets/enhance_photo_form.dart';
import 'widgets/video_form.dart';
import 'widgets/advanced_video_form.dart';
import '../chat/ai_chat_assistant.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _activeTab = 0; // 0 = Poster, 1 = Banner, 2 = Edukasi, 3 = Affiliate, 4 = Digital Product, 5 = Baliho, 6 = Logo, 7 = Quotes, 8 = Percantik Foto
  int _currentBottomTab = 0; // 0 = Studio, 1 = Riwayat, 2 = Templates, 3 = Profil, 4 = Pengaturan
  bool _studioShowForm = false; // false = Studio Beranda, true = Show active form
  bool _isInitialAuthTransition = true;

  // Visual Styles
  List<NeoDropdownOption> _dynamicVisualStyles = [];
  bool _loadingVisualStyles = false;

  bool _isGenerating = false;
  bool _isAnalyzing = false;
  String _generationStatus = '';
  Timer? _profilePollTimer;
  bool _hasUpdate = false;
  
  Map<String, dynamic>? _lastResultData;
  Map<String, dynamic>? _lastViralBreakdown;

  @override
  void initState() {
    super.initState();
    _checkSyncStatus();
    _fetchVisualStyles();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).fetchUserProfile();
    });
    _startPollingProfile();
  }

  void _startPollingProfile() {
    _profilePollTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        ref.read(authProvider.notifier).fetchUserProfile();
      }
    });
  }

  Future<void> _checkSyncStatus() async {
    final result = await SyncService.instance.checkForUpdates();
    if (result.hasUpdate && mounted) {
      setState(() {
        _hasUpdate = true;
      });
    }
  }

  Future<void> _fetchVisualStyles() async {
    setState(() => _loadingVisualStyles = true);
    try {
      // 1. Coba baca dari SQLite local cache (INSTANT)
      final cachedRows = await LocalDbService.instance.getVisualStyles();
      if (cachedRows.isNotEmpty) {
        final styles = cachedRows.map((item) => NeoDropdownOption(
          id: item['id'],
          label: item['name'],
          value: item['name'],
          helperText: item['promptTemplate'],
          icon: item['localImagePath'] ?? item['previewImageUrl'], // prioritaskan local
        )).toList();
        
        setState(() => _dynamicVisualStyles = styles);
        
        if (mounted) {
          final images = styles
            .where((s) => s.icon != null)
            .map((s) {
              final isHttp = s.icon!.startsWith('http');
              return (url: s.icon!, localPath: isHttp ? null : s.icon);
            })
            .toList();
          await CacheService.instance.precacheVisualStyleImages(
            context: context,
            images: images,
          );
        }
        return; // Selesai jika ada cache lokal
      }

      // 2. Jika tidak ada cache, fetch dari network
      final response = await dioClient.get('/poster/visual-styles');
      if (response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];
        final styles = list.map((item) => NeoDropdownOption(
          id: item['id'],
          label: item['name'],
          value: item['name'],
          helperText: item['promptTemplate'],
          icon: item['previewImageUrl'],
        )).toList();

        // Simpan ke cache lokal
        final rowsToSave = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        await LocalDbService.instance.saveVisualStyles(rowsToSave);

        setState(() => _dynamicVisualStyles = styles);

        if (mounted) {
          final images = styles
            .where((s) => s.icon != null)
            .map((s) => (url: s.icon!, localPath: null as String?))
            .toList();
          await CacheService.instance.precacheVisualStyleImages(
            context: context,
            images: images,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to load visual styles: $e');
    } finally {
      if (mounted) setState(() => _loadingVisualStyles = false);
    }
  }

  @override
  void dispose() {
    _profilePollTimer?.cancel();
    super.dispose();
  }

  void _showUpgradeLockDialog({String? customMessage}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 2.5),
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text('👑 ', style: TextStyle(fontSize: 20)),
            Text(
              'Aktivasi Premium Diperlukan',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          customMessage ?? 'Seluruh fitur AI Studio terkunci untuk akun Anda saat ini. Silakan masukkan kode lisensi premium Anda di tab Pengaturan untuk membuka akses.',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          NeoPrimaryButton(
            text: 'BUKA PENGATURAN',
            backgroundColor: NeoTheme.accentYellow,
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentBottomTab = 2; // Index tab Pengaturan (SettingsScreen)
              });
            },
          ),
        ],
      ),
    );
  }

  void _handleDioError(dynamic e, String defaultMsg) {
    String errorMsg = defaultMsg;
    bool isQuotaExceeded = false;
    
    if (e is DioException) {
      if (e.response?.statusCode == 429) {
        isQuotaExceeded = true;
      }
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        if (data.containsKey('message')) {
          errorMsg = data['message'].toString();
          if (errorMsg.contains('Kuota harian') || errorMsg.contains('habis')) {
            isQuotaExceeded = true;
          }
        }
      }
    } else {
      errorMsg = e.toString();
      if (errorMsg.contains('429') || errorMsg.contains('Quota')) {
        isQuotaExceeded = true;
      }
    }

    if (isQuotaExceeded) {
      _showUpgradeLockDialog(
        customMessage: errorMsg,
      );
    } else {
      // Masking error messages from backend so API secrets/providers don't leak
      final lowerMsg = errorMsg.toLowerCase();
      if (lowerMsg.contains('groq') || 
          lowerMsg.contains('gemini') || 
          lowerMsg.contains('api key') || 
          lowerMsg.contains('failed to fetch') ||
          lowerMsg.contains('network') ||
          lowerMsg.contains('exception')) {
        errorMsg = 'Terjadi error pada sistem AI, silakan hubungi Admin.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg.startsWith('Gagal') ? errorMsg : 'Gagal: $errorMsg'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadLocalImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final response = await dioClient.post('/poster/upload', data: {
        'image': base64Image,
        'fileName': file.name,
      });
      if (response.data['success'] == true) {
        return response.data['url'] as String;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    }
    return null;
  }

  Future<Map<String, String>?> _runAnalyzeCerdas(String topic) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final response = await dioClient.post('/poster/analyze-topic', data: {
        'topic': topic,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        String extra = '';
        if (data['keyPoints'] != null) {
          final points = List<String>.from(data['keyPoints']);
          extra = 'Poin Utama:\n' + points.map((p) => '- $p').join('\n');
        }
        if (data['visualRecommendation'] != null) {
          extra += '\n\nRekomendasi Visual:\n${data['visualRecommendation']}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analisis Cerdas Berhasil!'),
            backgroundColor: NeoTheme.accentGreen,
          ),
        );

        return {
          'description': data['description'] ?? '',
          'extraDetails': extra,
        };
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menjalankan Analisis Cerdas'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
    return null;
  }

  Future<Map<String, dynamic>?> _runAnalyzeStoryboard(String topic, int duration) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final response = await dioClient.post(
        '/poster/analyze-storyboard',
        data: {
          'topic': topic,
          'duration': duration,
        },
      );

      if (response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auto-Generate Storyboard Berhasil!'),
            backgroundColor: NeoTheme.accentGreen,
          ),
        );
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuat Storyboard otomatis'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
    return null;
  }

  Future<void> _generatePosterPrompt(Map<String, dynamic> data) async {
    final authState = ref.read(authProvider);

    final topic = (data['topic'] as String).trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Topik utama tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generationStatus = 'Membaca konfigurasi...';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _generationStatus = 'Mengunggah foto referensi...');
      
      String? imageUrl;
      final XFile? imageFile = data['referenceImage'] as XFile?;
      if (imageFile != null) {
        imageUrl = await _uploadLocalImage(imageFile);
        if (imageUrl == null) {
          throw Exception('Gagal mengunggah foto referensi ke ImageKit');
        }
      }

      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _generationStatus = 'Menjalankan Prompt Compiler Engine...');

      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('default_lang') ?? 'id';

      final feature = data['feature'] as String;

      final rawPayload = {
        'feature': feature,
        'language': lang,
        'slideCount': data['slideCount'] ?? 1,
        'topic': topic,
        'description': data['description'] ?? '',
        'extraDetails': data['extraDetails'] ?? '',
        'watermark': data['watermark'] ?? '',
        if (imageUrl != null) 'referenceImageUrl': imageUrl,
        'colorPalette': data['colorPalette'] ?? 'auto',
        'mood': data['mood'] ?? 'bright_cheerful',
        'textRule': data['textRule'] ?? 'flexible',
        'characterFocus': data['characterFocus'] ?? 'random',
        'style': data['style'] ?? 'auto',
        if (data.containsKey('layout')) 'layout': data['layout'],
        if (data.containsKey('aspectRatio')) 'aspectRatio': data['aspectRatio'],
        if (data.containsKey('cta')) 'cta': data['cta'],
        if (data.containsKey('theme')) 'theme': data['theme'],
        if (feature == 'advanced_video') ...{
          'duration': data['duration'] ?? 30,
          'storyBible': data['storyBible'],
          'characterBible': data['characterBible'],
          'environmentBible': data['environmentBible'],
          'sceneBreakdown': data['sceneBreakdown'],
        }
      };

      final payload = Map<String, dynamic>.fromEntries(
        rawPayload.entries.where((e) => e.value != null),
      );

      final response = await dioClient.post('/poster/generate', data: payload);

      if (response.data['success'] == true) {
        final resData = response.data['data'];
        ref.read(authProvider.notifier).fetchUserProfile();
        if (mounted) {
          setState(() {
            _lastResultData = resData['prompt'] != null ? Map<String, dynamic>.from(resData['prompt'] as Map) : null;
            _lastViralBreakdown = resData['viralBreakdown'] != null ? Map<String, dynamic>.from(resData['viralBreakdown'] as Map) : null;
            _currentBottomTab = 5;
          });
        }
      }
    } catch (e) {
      _handleDioError(e, 'Gagal membuat prompt poster');
    } finally {
      setState(() {
        _isGenerating = false;
        _generationStatus = '';
      });
    }
  }

  Future<void> _generateEnhancePrompt(Map<String, dynamic> data) async {
    final authState = ref.read(authProvider);

    final XFile? imageFile = data['referenceImage'] as XFile?;
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan upload foto terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generationStatus = 'Menganalisis wajah dan pencahayaan...';
    });

    try {
      setState(() => _generationStatus = 'Mengunggah foto ke ImageKit...');
      final imageUrl = await _uploadLocalImage(imageFile);
      if (imageUrl == null) {
        throw Exception('Gagal mengunggah foto ke ImageKit');
      }

      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _generationStatus = 'Menyusun prompt retouch...');

      final payload = {
        'imageUrl': imageUrl,
        'enhanceStyle': data['enhanceStyle'] ?? 'kpop_aesthetic',
        'changeLevel': data['changeLevel'] ?? 'natural',
        'notes': data['notes'] ?? '',
      };

      final response = await dioClient.post('/poster/enhance', data: payload);

      if (response.data['success'] == true) {
        final resData = response.data['data'];
        ref.read(authProvider.notifier).fetchUserProfile();
        if (mounted) {
          setState(() {
            _lastResultData = resData['prompt'] != null ? Map<String, dynamic>.from(resData['prompt'] as Map) : null;
            _lastViralBreakdown = resData['viralBreakdown'] != null ? Map<String, dynamic>.from(resData['viralBreakdown'] as Map) : null;
            _currentBottomTab = 5;
          });
        }
      }
    } catch (e) {
      _handleDioError(e, 'Gagal memproses foto');
    } finally {
      setState(() {
        _isGenerating = false;
        _generationStatus = '';
      });
    }
  }

  Widget _renderActiveForm(DropdownState dropdownState) {
    switch (_activeTab) {
      case 0:
        return PosterForm(
          dropdownState: dropdownState,
          dynamicVisualStyles: _dynamicVisualStyles,
          loadingVisualStyles: _loadingVisualStyles,
          isGenerating: _isGenerating,
          isAnalyzing: _isAnalyzing,
          onGenerate: _generatePosterPrompt,
          onAnalyzeCerdas: _runAnalyzeCerdas,
        );
      case 1:
        return BannerForm(
          dropdownState: dropdownState,
          dynamicVisualStyles: _dynamicVisualStyles,
          loadingVisualStyles: _loadingVisualStyles,
          isGenerating: _isGenerating,
          isAnalyzing: _isAnalyzing,
          onGenerate: _generatePosterPrompt,
          onAnalyzeCerdas: _runAnalyzeCerdas,
        );
      case 2:
        return EdukasiForm(
          dropdownState: dropdownState,
          dynamicVisualStyles: _dynamicVisualStyles,
          loadingVisualStyles: _loadingVisualStyles,
          isGenerating: _isGenerating,
          isAnalyzing: _isAnalyzing,
          onGenerate: _generatePosterPrompt,
          onAnalyzeCerdas: _runAnalyzeCerdas,
        );
      case 3:
        return AffiliateForm(
          dropdownState: dropdownState,
          dynamicVisualStyles: _dynamicVisualStyles,
          loadingVisualStyles: _loadingVisualStyles,
          isGenerating: _isGenerating,
          isAnalyzing: _isAnalyzing,
          onGenerate: _generatePosterPrompt,
          onAnalyzeCerdas: _runAnalyzeCerdas,
        );
      case 4:
        return DigitalProductForm(
          dropdownState: dropdownState,
          dynamicVisualStyles: _dynamicVisualStyles,
          loadingVisualStyles: _loadingVisualStyles,
          isGenerating: _isGenerating,
          isAnalyzing: _isAnalyzing,
          onGenerate: _generatePosterPrompt,
          onAnalyzeCerdas: _runAnalyzeCerdas,
        );
      case 5:
        return BalihoForm(
          dropdownState: dropdownState,
          dynamicVisualStyles: _dynamicVisualStyles,
          loadingVisualStyles: _loadingVisualStyles,
          isGenerating: _isGenerating,
          isAnalyzing: _isAnalyzing,
          onGenerate: _generatePosterPrompt,
          onAnalyzeCerdas: _runAnalyzeCerdas,
        );
      case 6:
        return LogoForm(
          dropdownState: dropdownState,
          dynamicVisualStyles: _dynamicVisualStyles,
          loadingVisualStyles: _loadingVisualStyles,
          isGenerating: _isGenerating,
          isAnalyzing: _isAnalyzing,
          onGenerate: _generatePosterPrompt,
          onAnalyzeCerdas: _runAnalyzeCerdas,
        );
      case 7:
        return QuotesForm(
          dropdownState: dropdownState,
          dynamicVisualStyles: _dynamicVisualStyles,
          loadingVisualStyles: _loadingVisualStyles,
          isGenerating: _isGenerating,
          isAnalyzing: _isAnalyzing,
          onGenerate: _generatePosterPrompt,
          onAnalyzeCerdas: _runAnalyzeCerdas,
        );
      case 8:
        return EnhancePhotoForm(
          dropdownState: dropdownState,
          isGenerating: _isGenerating,
          onGenerate: _generateEnhancePrompt,
        );
      case 9:
        return AdvancedVideoForm(
          dropdownState: dropdownState,
          isGenerating: _isGenerating,
          isAnalyzing: _isAnalyzing,
          onGenerate: _generatePosterPrompt,
          onAnalyzeStoryboard: _runAnalyzeStoryboard,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropdownState = ref.watch(dropdownProvider);
    final systemSettings = ref.watch(systemSettingsProvider);
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous != null && previous.user != null && next.user != null) {
        final prevCredits = previous.user!.credits;
        final nextCredits = next.user!.credits;
        if (nextCredits > prevCredits && prevCredits > 0) {
          if (_isInitialAuthTransition) {
          } else {
            final added = nextCredits - prevCredits;
            _showTokenReceivedDialog(context, added);
          }
        }
      }
      _isInitialAuthTransition = false;
    });

    final List<Map<String, dynamic>> menuItems = [
      {'label': 'Studio', 'icon': Icons.palette_outlined, 'activeIcon': Icons.palette, 'body': null},
      {'label': 'Riwayat', 'icon': Icons.history_outlined, 'activeIcon': Icons.history, 'body': HistoryScreen(onNavigateToCreate: () { setState(() { _currentBottomTab = 0; _studioShowForm = true; _activeTab = 0; }); })},
      {
        'label': 'Templates',
        'icon': Icons.collections_bookmark_outlined,
        'activeIcon': Icons.collections_bookmark,
        'body': TemplatesScreen(
          onUseTemplate: (category) {
            int tabIndex = 0;
            final normalizedCategory = category.toLowerCase().trim();
            if (normalizedCategory == 'poster') tabIndex = 0;
            else if (normalizedCategory == 'banner') tabIndex = 1;
            else if (normalizedCategory == 'edukasi') tabIndex = 2;
            else if (normalizedCategory == 'affiliate' || normalizedCategory == 'afiliasi') tabIndex = 3;
            else if (normalizedCategory == 'digital_product' || normalizedCategory == 'produk digital' || normalizedCategory == 'produk_digital') tabIndex = 4;
            else if (normalizedCategory == 'baliho' || normalizedCategory == 'spanduk/baliho' || normalizedCategory == 'spanduk') tabIndex = 5;
            else if (normalizedCategory == 'logo') tabIndex = 6;
            else if (normalizedCategory == 'quotes' || normalizedCategory == 'kata mutiara' || normalizedCategory == 'kata_mutiara') tabIndex = 7;
            else if (normalizedCategory == 'photo_enhance' || normalizedCategory == 'percantik foto' || normalizedCategory == 'percantik_foto') tabIndex = 8;
            else if (normalizedCategory == 'video' || normalizedCategory == 'video_prompt' || normalizedCategory == 'video prompting') tabIndex = 9;
            
            setState(() {
              _currentBottomTab = 0;
              _activeTab = tabIndex;
              _studioShowForm = true;
            });
          },
        ),
      },
      {'label': 'Profil', 'icon': Icons.person_outline, 'activeIcon': Icons.person, 'body': const ProfileScreen()},
      {'label': 'Pengaturan', 'icon': Icons.settings_outlined, 'activeIcon': Icons.settings, 'body': const SettingsScreen()},
    ];

    final activeMenuIndex = _currentBottomTab >= menuItems.length ? 0 : _currentBottomTab;
    final activeMenu = menuItems[activeMenuIndex];
    final activeBody = activeMenu['body'] as Widget?;

    final appName = systemSettings.appName;
    final footerText = systemSettings.footerText;
    final bannerText = _activeTab == 8
        ? systemSettings.bannerEnhanceInfo
        : systemSettings.bannerPosterInfo;

    final tabs = const [
      'Poster',
      'Banner',
      'Edukasi',
      'Iklan Affiliate',
      'Produk Digital',
      'Spanduk Baliho',
      'Pembuatan Logo',
      'Kata Mutiara',
      'Percantik Foto',
      'Video Prompting'
    ];

    return Scaffold(
      appBar: activeBody == null
          ? AppBar(
              backgroundColor: NeoTheme.bgBase,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: _studioShowForm
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() => _studioShowForm = false),
                    )
                  : null,
              title: Row(
                children: [
                  if (!_studioShowForm) ...[
                    Image.asset('assets/logo.png', height: 48),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    _studioShowForm ? (tabs.isNotEmpty && _activeTab < tabs.length ? tabs[_activeTab] : 'Studio') : 'AI Studio',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.sync, color: Colors.black),
                  tooltip: 'Sinkronisasi Data',
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sinkronisasi data sedang berjalan...')),
                    );
                    try {
                      await ref.read(dropdownProvider.notifier).forceRefresh();
                      await _fetchVisualStyles();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sinkronisasi data selesai!'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sinkronisasi gagal: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    color: NeoTheme.accentYellow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙 ', style: TextStyle(fontSize: 14)),
                      Text(
                        '${authState.user?.credits ?? 0} Token',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
      body: _currentBottomTab == 5 && _lastResultData != null
          ? ResultView(
              promptData: _lastResultData!,
              viralBreakdown: _lastViralBreakdown ?? {},
              onBack: () => setState(() => _currentBottomTab = 0),
            )
          : activeBody != null
              ? activeBody
          : !_studioShowForm
              ? _buildStudioHome(authState)
              : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Column(
              children: [

                if (_hasUpdate)
                  SyncUpdateBanner(
                    onSyncComplete: () {
                      setState(() => _hasUpdate = false);
                      ref.read(dropdownProvider.notifier).reloadFromLocalDb();
                      CacheService.instance.resetPreloadFlag();
                      _fetchVisualStyles();
                    },
                  ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Form Pembuatan ${tabs[_activeTab]}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.black, width: 2.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Row(
                              children: [
                                Image.asset('assets/1.png', width: 24, height: 24),
                                const SizedBox(width: 8),
                                Expanded(child: Text('Info ${tabs[_activeTab]}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                              ],
                            ),
                            content: FutureBuilder(
                              future: dioClient.get('/form-infos'),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(color: NeoTheme.accentPink)));
                                }
                                
                                String dbDescription = bannerText;
                                if (snapshot.hasData && snapshot.data?.data['success'] == true) {
                                  final list = snapshot.data!.data['data'] as List;
                                  final match = list.firstWhere(
                                    (item) => item['featureKey']?.toLowerCase() == tabs[_activeTab].toLowerCase(),
                                    orElse: () => null,
                                  );
                                  if (match != null && match['description'] != null) {
                                    dbDescription = match['description'];
                                  }
                                }

                                return Text(dbDescription, style: const TextStyle(fontSize: 14));
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Tutup', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Image.asset('assets/1.png', width: 28, height: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _renderActiveForm(dropdownState),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Text(
                        appName,
                        style: const TextStyle(
                          color: NeoTheme.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        footerText,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isGenerating)
            Container(
              color: Colors.black.withOpacity(0.6),
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: NeoTheme.neoBoxDecoration(
                  color: Colors.white,
                  borderRadius: 24,
                  hasShadow: true,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: NeoTheme.accentPink,
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'COMPILING DSL...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _generationStatus,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: NeoTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.5),
            builder: (context) => const Center(
              child: Material(
                color: Colors.transparent,
                child: AiChatAssistant(),
              ),
            ),
          );
        },
        backgroundColor: NeoTheme.accentPink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        elevation: 0,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.black),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: NeoTheme.borderStrong, width: 2.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: activeMenuIndex,
          onTap: (index) {
            setState(() {
              _currentBottomTab = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: NeoTheme.accentPink,
          unselectedItemColor: NeoTheme.textMuted,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: menuItems.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item['icon'] as IconData),
              activeIcon: Icon(item['activeIcon'] as IconData),
              label: item['label'] as String,
            );
          }).toList(),
        ),
      ),
    );
  }

  // Studio home beranda — dashboard dengan grid menu fitur
  Widget _buildStudioHome(dynamic authState) {
    final List<Map<String, dynamic>> studioFeatures = [
      {
        'icon': Icons.image_outlined,
        'label': 'Poster',
        'subtitle': 'Buat desain poster profesional & viral',
        'color': const Color(0xFFFF6B9D),
        'iconColor': const Color(0xFFFF4081),
        'bgColor': const Color(0xFFFFF0F5),
        'tab': 0
      },
      {
        'icon': Icons.campaign_outlined,
        'label': 'Banner',
        'subtitle': 'Banner promosi dan iklan digital',
        'color': const Color(0xFF6C63FF),
        'iconColor': const Color(0xFF536DFE),
        'bgColor': const Color(0xFFEEECFF),
        'tab': 1
      },
      {
        'icon': Icons.school_outlined,
        'label': 'Edukasi',
        'subtitle': 'Konten edukatif yang informatif',
        'color': const Color(0xFF4ECDC4),
        'iconColor': const Color(0xFF00BFA5),
        'bgColor': const Color(0xFFE0F7F4),
        'tab': 2
      },
      {
        'icon': Icons.volume_up_outlined,
        'label': 'Afiliasi',
        'subtitle': 'Prompt iklan afiliasi terbaik',
        'color': const Color(0xFFFFBE0B),
        'iconColor': const Color(0xFFFF9100),
        'bgColor': const Color(0xFFFFF8E1),
        'tab': 3
      },
      {
        'icon': Icons.shopping_cart_outlined,
        'label': 'Produk Digital',
        'subtitle': 'Jual produk digitalmu',
        'color': const Color(0xFF43AA8B),
        'iconColor': const Color(0xFF00C853),
        'bgColor': const Color(0xFFE8F5E9),
        'tab': 4
      },
      {
        'icon': Icons.co_present_outlined,
        'label': 'Spanduk/Baliho',
        'subtitle': 'Banner besar outdoor & indoor',
        'color': const Color(0xFFFF9F1C),
        'iconColor': const Color(0xFFFF6D00),
        'bgColor': const Color(0xFFFFF3E0),
        'tab': 5
      },
      {
        'icon': Icons.history_edu_outlined,
        'label': 'Logo',
        'subtitle': 'Desain logo brand terbaik',
        'color': const Color(0xFFE63946),
        'iconColor': const Color(0xFFFF1744),
        'bgColor': const Color(0xFFFFEBEE),
        'tab': 6
      },
      {
        'icon': Icons.format_quote_outlined,
        'label': 'Kata Mutiara',
        'subtitle': 'Quotes viral buat medsos',
        'color': const Color(0xFF7209B7),
        'iconColor': const Color(0xFFD500F9),
        'bgColor': const Color(0xFFF3E5F5),
        'tab': 7
      },
      {
        'icon': Icons.auto_awesome_outlined,
        'label': 'Percantik Foto',
        'subtitle': 'Retouch & enhance foto profesional',
        'color': const Color(0xFF2196F3),
        'iconColor': const Color(0xFF2979FF),
        'bgColor': const Color(0xFFE3F2FD),
        'tab': 8
      },
      {
        'icon': Icons.video_library_outlined,
        'label': 'Video Prompt',
        'subtitle': 'Prompt video berdurasi dinamis',
        'color': const Color(0xFFE91E63),
        'iconColor': const Color(0xFFC2185B),
        'bgColor': const Color(0xFFFCE4EC),
        'tab': 9
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Card
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 20, right: 120, top: 20, bottom: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFF6C63FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 2.5),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✨ Selamat Datang,', style: TextStyle(color: Colors.white, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      '${authState?.user?.email.split('@')[0] ?? 'Kreator'}!',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mari ciptakan desain keren\nbersama AI Studio 🚀',
                      style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -5,
                bottom: -5,
                child: Image.asset(
                  'assets/robot.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            '🚀 PILIH JENIS KONTEN',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
          ),
          const SizedBox(height: 12),

          // Feature grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
            children: studioFeatures.map((feature) {
              final iconColor = feature['iconColor'] as Color;
              final bgColor = feature['bgColor'] as Color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeTab = feature['tab'] as int;
                    _studioShowForm = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
                        ),
                        child: Center(
                          child: Icon(
                            feature['icon'] as IconData,
                            color: iconColor,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature['label'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature['subtitle'] as String,
                        style: const TextStyle(fontSize: 9, color: NeoTheme.textMuted, height: 1.2),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Quick action: recent history shortcut
          GestureDetector(
            onTap: () => setState(() => _currentBottomTab = 1),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFBE0B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 2.5),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
              ),
              child: Row(
                children: [
                  const Text('📋', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Riwayat Terakhir', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        Text('Lihat semua prompt yang sudah dibuat', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTokenReceivedDialog(BuildContext context, int addedCredits) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _TokenReceivedDialog(addedCredits: addedCredits);
      },
    );
  }
}

class _TokenReceivedDialog extends StatefulWidget {
  final int addedCredits;
  const _TokenReceivedDialog({required this.addedCredits});

  @override
  State<_TokenReceivedDialog> createState() => _TokenReceivedDialogState();
}

class _TokenReceivedDialogState extends State<_TokenReceivedDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: NeoTheme.neoBoxDecoration(
              color: NeoTheme.accentYellow,
              borderRadius: 24,
              hasShadow: true,
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spinning Coin Icon
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 3.14159 * 2,
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(3, 3),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      '🪙',
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'KREDIT BERTAMBAH!',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hore! Admin baru saja menambahkan +${widget.addedCredits} Token Kredit ke akun Anda.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // OK Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(3, 3),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: const Center(
                      child: Text(
                        'MANTAP!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
