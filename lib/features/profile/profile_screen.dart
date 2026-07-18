import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/neo_theme.dart';
import '../../shared/widgets/neo_buttons.dart';
import '../../shared/widgets/neo_text_field.dart';
import '../auth/auth_provider.dart';
import '../../core/network/dio_client.dart';
import 'imagekit_settings_page.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseKeyController = TextEditingController();
  bool _isUpdating = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _licenseKeyController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfirmasi password baru tidak cocok'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isUpdating = true);

      try {
        final response = await dioClient.post('/auth/change-password', data: {
          'oldPassword': _oldPasswordController.text,
          'newPassword': _newPasswordController.text,
        });

        if (response.data['success'] == true) {
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password berhasil diperbarui!'),
                backgroundColor: NeoTheme.accentGreen,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengganti password. Cek password lama Anda.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _activateLicenseKey() async {
    final key = _licenseKeyController.text.trim();
    if (key.isEmpty) return;

    setState(() => _isUpdating = true);

    try {
      final response = await dioClient.post('/poster/activate-license', data: {
        'key': key,
      });

      if (response.data['success'] == true) {
        // Fetch new profile details to reload credits balance and status!
        await ref.read(authProvider.notifier).fetchUserProfile();
        _licenseKeyController.clear();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengaktifkan lisensi. Periksa kembali kode Anda.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info card
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: NeoTheme.accentPink,
                          child: const Icon(Icons.person, color: Colors.black, size: 32),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authState.user?.email ?? 'Unknown User',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Role: ${authState.user?.role ?? "USER"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30, color: Colors.black, thickness: 1.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kredit Tersisa:',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        Container(
                          decoration: NeoTheme.neoBoxDecoration(
                            color: NeoTheme.accentYellow,
                            borderRadius: 8,
                            hasShadow: false,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text(
                            '🪙 ${authState.user?.credits ?? 0} Token',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ImageKit settings shortcut
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ImagekitSettingsPage()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: NeoTheme.neoBoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: 14,
                    hasShadow: true,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_outlined, size: 22, color: Colors.black),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('☁️ Penyimpanan ImageKit Pribadi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                            Text('Simpan foto hasil ke akun ImageKit Anda sendiri (opsional)', style: TextStyle(fontSize: 10, color: NeoTheme.textMuted)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 20, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Change Password Card
              Container(
                width: double.infinity,
                decoration: NeoTheme.neoBoxDecoration(
                  color: Colors.white,
                  borderRadius: 16,
                  hasShadow: true,
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🔑 GANTI PASSWORD',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 14),
                      NeoTextField(
                        label: 'PASSWORD LAMA',
                        placeholder: 'Password Lama',
                        controller: _oldPasswordController,
                        isObscure: true,
                        validator: (v) => v == null || v.isEmpty ? 'Password lama wajib diisi' : null,
                      ),
                      const SizedBox(height: 10),
                      NeoTextField(
                        label: 'PASSWORD BARU',
                        placeholder: 'Password Baru',
                        controller: _newPasswordController,
                        isObscure: true,
                        validator: (v) => v == null || v.length < 6 ? 'Password baru minimal 6 karakter' : null,
                      ),
                      const SizedBox(height: 10),
                      NeoTextField(
                        label: 'KONFIRMASI PASSWORD BARU',
                        placeholder: 'Konfirmasi Password Baru',
                        controller: _confirmPasswordController,
                        isObscure: true,
                        validator: (v) => v == null || v.isEmpty ? 'Konfirmasi password wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: NeoPrimaryButton(
                          text: _isUpdating ? 'MENYIMPAN...' : 'PERBARUI PASSWORD',
                          backgroundColor: NeoTheme.accentBlue,
                          onPressed: _isUpdating ? null : _changePassword,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: NeoPrimaryButton(
                  text: 'LOGOUT AKUN',
                  backgroundColor: NeoTheme.accentPink,
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
