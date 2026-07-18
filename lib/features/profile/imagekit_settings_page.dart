import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/neo_theme.dart';
import '../../core/network/dio_client.dart';

class ImagekitSettingsPage extends StatefulWidget {
  const ImagekitSettingsPage({super.key});

  @override
  State<ImagekitSettingsPage> createState() => _ImagekitSettingsPageState();
}

class _ImagekitSettingsPageState extends State<ImagekitSettingsPage> {
  final _publicKeyCtrl = TextEditingController();
  final _privateKeyCtrl = TextEditingController();
  final _urlEndpointCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTesting = false;
  bool _isDeleting = false;
  bool _isConfigured = false;
  bool _obscurePrivKey = true;
  String _testResult = '';
  bool _testOk = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _publicKeyCtrl.dispose();
    _privateKeyCtrl.dispose();
    _urlEndpointCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final res = await dioClient.get('/auth/imagekit');
      if (res.data['success'] == true) {
        final d = res.data['data'];
        setState(() {
          _isConfigured = d['isConfigured'] == true;
          _publicKeyCtrl.text = d['publicKey'] ?? '';
          _urlEndpointCtrl.text = d['urlEndpoint'] ?? '';
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    final pub = _publicKeyCtrl.text.trim();
    final priv = _privateKeyCtrl.text.trim();
    final url = _urlEndpointCtrl.text.trim();

    if (pub.isEmpty || priv.isEmpty || url.isEmpty) {
      _showSnack('Semua field wajib diisi', Colors.orange);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final res = await dioClient.put('/auth/imagekit', data: {
        'publicKey': pub,
        'privateKey': priv,
        'urlEndpoint': url,
      });
      if (res.data['success'] == true) {
        setState(() => _isConfigured = true);
        _showSnack(res.data['message'] ?? '✅ Tersimpan!', NeoTheme.accentGreen);
      }
    } catch (e) {
      _showSnack('Gagal menyimpan. Cek koneksi & coba lagi.', Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _test() async {
    final pub = _publicKeyCtrl.text.trim();
    final priv = _privateKeyCtrl.text.trim();
    final url = _urlEndpointCtrl.text.trim();

    if (pub.isEmpty || priv.isEmpty || url.isEmpty) {
      _showSnack('Isi semua field terlebih dahulu', Colors.orange);
      return;
    }
    setState(() { _isTesting = true; _testResult = ''; });
    try {
      final res = await dioClient.post('/auth/imagekit/test', data: {
        'publicKey': pub,
        'privateKey': priv,
        'urlEndpoint': url,
      });
      setState(() {
        _testOk = res.data['success'] == true;
        _testResult = res.data['message'] ?? '';
      });
    } catch (e) {
      setState(() {
        _testOk = false;
        _testResult = '❌ Gagal terhubung ke server';
      });
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 2.5),
        ),
        title: const Text('Hapus Kredensial ImageKit?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
          'Foto yang sudah diupload tetap tersimpan di ImageKit Anda.\n'
          'Hanya pengaturan koneksi yang akan dihapus.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _isDeleting = true);
    try {
      final res = await dioClient.delete('/auth/imagekit');
      if (res.data['success'] == true) {
        setState(() {
          _isConfigured = false;
          _publicKeyCtrl.clear();
          _privateKeyCtrl.clear();
          _urlEndpointCtrl.clear();
          _testResult = '';
        });
        _showSnack('Kredensial dihapus', Colors.orange);
      }
    } catch (_) {
      _showSnack('Gagal menghapus', Colors.red);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      appBar: AppBar(
        backgroundColor: NeoTheme.bgBase,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
        ),
        title: const Text(
          '☁️ IMAGEKIT PRIBADI',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isConfigured ? NeoTheme.accentGreen : const Color(0xFFFFF9C4),
                      border: Border.all(color: Colors.black, width: 2.5),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isConfigured ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                          size: 22, color: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isConfigured ? 'ImageKit Terhubung ✅' : 'Belum Dikonfigurasi',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                              Text(
                                _isConfigured
                                    ? 'Foto Anda tersimpan di akun ImageKit pribadi Anda'
                                    : 'Saat ini foto tersimpan di server lokal/admin',
                                style: const TextStyle(fontSize: 11, color: NeoTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // WHY section
                  Container(
                    decoration: NeoTheme.neoBoxDecoration(color: Colors.white, borderRadius: 16, hasShadow: true),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock_person_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('KENAPA PERLU INI?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _benefitRow('🔒', 'Foto hanya bisa diakses lewat akun ImageKit Anda sendiri — tidak tercampur dengan user lain'),
                        const SizedBox(height: 6),
                        _benefitRow('🚀', 'CDN global — gambar dimuat lebih cepat dari mana saja'),
                        const SizedBox(height: 6),
                        _benefitRow('💾', 'Tidak bergantung pada server admin — data tetap aman jika server maintenance'),
                        const SizedBox(height: 6),
                        _benefitRow('🆓', 'Free tier ImageKit: 20GB bandwidth/bulan — cukup untuk ratusan poster'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TUTORIAL
                  Container(
                    decoration: NeoTheme.neoBoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: 16, hasShadow: true),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.school_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('📖 CARA DAFTAR IMAGEKIT (GRATIS)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _tutorialStep('1', 'Buka imagekit.io dan daftar akun gratis',
                            'Gratis selamanya hingga 20GB bandwidth/bulan',
                            onTap: () => _openUrl('https://imagekit.io/registration')),
                        _tutorialStep('2', 'Masuk ke Dashboard → Settings → API Keys',
                            'Di sidebar kiri: Settings → Developer Options → API Keys'),
                        _tutorialStep('3', 'Copy "Public Key", "Private Key", dan "URL Endpoint"',
                            'URL Endpoint: https://ik.imagekit.io/nama_akun_anda'),
                        _tutorialStep('4', 'Paste ke form di bawah, klik "Tes Koneksi"',
                            'Pastikan tes berhasil ✅ sebelum menyimpan',
                            isLast: true),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _openUrl('https://imagekit.io/registration'),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text('🔗  Daftar di imagekit.io  →',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // FORM
                  Container(
                    decoration: NeoTheme.neoBoxDecoration(color: const Color(0xFFFFF9C4), borderRadius: 16, hasShadow: true),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.key_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('MASUKKAN KREDENSIAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildField(label: 'Public Key', hint: 'public_xxxxxxxxxxxxxxx', ctrl: _publicKeyCtrl, icon: Icons.vpn_key_outlined),
                        const SizedBox(height: 12),
                        _buildField(
                          label: 'Private Key',
                          hint: _isConfigured ? '•••••• (sudah tersimpan, isi ulang jika ingin ubah)' : 'private_xxxxxxxxxxxxxxx',
                          ctrl: _privateKeyCtrl,
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          obscure: _obscurePrivKey,
                          onToggle: () => setState(() => _obscurePrivKey = !_obscurePrivKey),
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          label: 'URL Endpoint',
                          hint: 'https://ik.imagekit.io/nama_akun_anda',
                          ctrl: _urlEndpointCtrl,
                          icon: Icons.link_rounded,
                        ),

                        if (_testResult.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _testOk ? NeoTheme.accentGreen.withOpacity(0.2) : Colors.red.withOpacity(0.1),
                              border: Border.all(color: _testOk ? NeoTheme.accentGreen : Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _testResult,
                              style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12,
                                color: _testOk ? Colors.green[800] : Colors.red[800],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _actionButton(
                                label: 'Tes Koneksi',
                                icon: Icons.wifi_tethering_rounded,
                                loading: _isTesting,
                                loadLabel: 'Mengetes...',
                                dark: false,
                                onTap: _test,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _actionButton(
                                label: 'Simpan',
                                icon: Icons.save_rounded,
                                loading: _isSaving,
                                loadLabel: 'Menyimpan...',
                                dark: true,
                                onTap: _save,
                              ),
                            ),
                          ],
                        ),

                        if (_isConfigured) ...[
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _isDeleting ? null : _delete,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                border: Border.all(color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _isDeleting
                                  ? const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red)))
                                  : const Center(
                                      child: Text('🗑  Hapus Kredensial ImageKit',
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.red))),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          obscureText: isPassword && obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: NeoTheme.textMuted),
            prefixIcon: Icon(icon, size: 16, color: Colors.black54),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 16),
                    onPressed: onToggle,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black, width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required bool loading,
    required String loadLabel,
    required bool dark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: dark ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 2.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
        ),
        child: loading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: dark ? Colors.white : Colors.black)),
                  const SizedBox(width: 6),
                  Text(loadLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: dark ? Colors.white : Colors.black)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: dark ? Colors.white : Colors.black),
                  const SizedBox(width: 6),
                  Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: dark ? Colors.white : Colors.black)),
                ],
              ),
      ),
    );
  }

  Widget _tutorialStep(String num, String title, String desc, {bool isLast = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900))),
              ),
              if (!isLast) Container(width: 2, height: 38, color: Colors.black26),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                      if (onTap != null) const Icon(Icons.open_in_new, size: 12, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(fontSize: 10, color: NeoTheme.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitRow(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 11, color: NeoTheme.textMuted))),
      ],
    );
  }
}
