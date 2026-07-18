import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/neo_theme.dart';
import '../../shared/widgets/neo_buttons.dart';
import '../saved_codes/saved_codes_screen.dart';
import 'system_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedLang = 'id';

  @override
  void initState() {
    super.initState();
    _loadLangPreference();
  }

  Future<void> _loadLangPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLang = prefs.getString('default_lang') ?? 'id';
    });
  }

  Future<void> _saveLangPreference(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_lang', lang);
    setState(() {
      _selectedLang = lang;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bahasa default diatur ke: ${lang == 'id' ? 'Indonesia' : 'Inggris'}'),
          backgroundColor: NeoTheme.accentGreen,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    final acc = prefs.getString('access_token');
    final refToken = prefs.getString('refresh_token');

    await prefs.clear();

    if (user != null) await prefs.setString('user', user);
    if (acc != null) await prefs.setString('access_token', acc);
    if (refToken != null) await prefs.setString('refresh_token', refToken);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache lokal berhasil dibersihkan!'),
          backgroundColor: NeoTheme.accentGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final systemSettings = ref.watch(systemSettingsProvider);

    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Language preference card
              Container(
                width: double.infinity,
                decoration: NeoTheme.neoBoxDecoration(
                  color: Colors.white,
                  borderRadius: 16,
                  hasShadow: true,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🌐 PENGATURAN BAHASA',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pilih bahasa utama untuk hasil rumusan prompt AI Anda.',
                      style: TextStyle(color: NeoTheme.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    _LangRadioTile(
                      label: 'Bahasa Indonesia',
                      value: 'id',
                      groupValue: _selectedLang,
                      onChanged: (v) => _saveLangPreference(v),
                    ),
                    const SizedBox(height: 10),
                    _LangRadioTile(
                      label: 'English (US)',
                      value: 'en',
                      groupValue: _selectedLang,
                      onChanged: (v) => _saveLangPreference(v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Clear cache card
              Container(
                width: double.infinity,
                decoration: NeoTheme.neoBoxDecoration(
                  color: Colors.white,
                  borderRadius: 16,
                  hasShadow: true,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧹 BERSIHKAN PENYIMPANAN CACHE',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Menghapus cache gambar dan visual template lokal untuk memuat ulang data segar dari server.',
                      style: TextStyle(color: NeoTheme.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: NeoPrimaryButton(
                        text: 'BERSIHKAN CACHE SEKARANG',
                        backgroundColor: NeoTheme.accentYellow,
                        onPressed: _clearLocalCache,
                      ),
                    ),
                  ],
                ),
              ),
              // 3. Saved Codes (File Manager)
              Container(
                width: double.infinity,
                decoration: NeoTheme.neoBoxDecoration(
                  color: Colors.white,
                  borderRadius: 16,
                  hasShadow: true,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📂 FILE & KODE TERSIMPAN',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Kelola file DSL dan JSON yang sudah Anda download untuk dilihat atau diedit kembali.',
                      style: TextStyle(color: NeoTheme.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: NeoPrimaryButton(
                        text: 'BUKA FILE MANAGER',
                        backgroundColor: NeoTheme.accentBlue,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedCodesScreen()));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // System info card removed as requested
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangRadioTile extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _LangRadioTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: isSelected
              ? const [BoxShadow(color: Colors.black, offset: Offset(2, 2))]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? NeoTheme.accentBlue : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
