import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/neo_theme.dart';
import '../settings/system_settings_provider.dart';
import '../auth/auth_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemSettings = ref.watch(systemSettingsProvider);
    final authState = ref.watch(authProvider);
    final packages = systemSettings.packages;

    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Neubrutalist Header Card
              Container(
                width: double.infinity,
                decoration: NeoTheme.neoBoxDecoration(
                  color: NeoTheme.accentYellow,
                  borderRadius: 16,
                  hasShadow: true,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💎 KREDIT PROMPT AI STUDIO',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Beli token kredit tambahan sekali bayar. Setiap generasi prompt poster atau pencucian foto menggunakan 1 Token Kredit.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text(
                          'Kredit Tersisa Anda: ',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text(
                            '🪙 ${authState.user?.credits ?? 0} Token',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'PILIH PAKET KREDIT INSTAN',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              
              if (packages.isEmpty)
                Container(
                  width: double.infinity,
                  decoration: NeoTheme.neoBoxDecoration(
                    color: Colors.white,
                    borderRadius: 16,
                    hasShadow: true,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: Text(
                      'Tidak ada paket yang dikonfigurasi oleh admin.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                ...packages.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final pkg = entry.value;
                  
                  Color cardAccentColor = NeoTheme.accentBlue;
                  if (idx == 1) cardAccentColor = NeoTheme.accentPink;
                  if (idx == 2) cardAccentColor = NeoTheme.accentYellow;

                  final isRecommended = pkg.id == 'standard' || idx == 1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: NeoTheme.neoBoxDecoration(
                      color: isRecommended ? const Color(0xFFFFFDF5) : Colors.white,
                      borderRadius: 20,
                      hasShadow: true,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pkg.name.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            if (isRecommended)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: const Text(
                                  'POPULER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: cardAccentColor,
                                border: Border.all(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Icon(Icons.token_outlined, color: Colors.black, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${pkg.credits} Kredit Prompt AI',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sekali Beli (Tidak Ada Kedaluwarsa)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              pkg.priceText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: () async {
                            final url = pkg.checkoutUrl;
                            if (url.isNotEmpty) {
                              try {
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              } catch (_) {}
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: cardAccentColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 2.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(3, 3),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: const Center(
                              child: Text(
                                'BELI SEKARANG',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
