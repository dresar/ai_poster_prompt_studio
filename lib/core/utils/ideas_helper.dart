import 'package:flutter/material.dart';
import '../network/dio_client.dart';
import '../theme/neo_theme.dart';

class IdeasHelper {
  static Future<void> showIdeasDialog({
    required BuildContext context,
    required String defaultCategory,
    required Function(String idea, {int? slideCount, bool autoHook, bool autoCta}) onIdeaSelected,
  }) async {
    final themeController = TextEditingController(text: defaultCategory);

    int localSlideCount = 5; // Default 5 slides for ideas
    const showSlides = true;
    bool autoSlideCount = true;
    bool autoHook = false;
    bool autoCta = false;

    const supportsHook = true;
    const supportsCta = true;

    // 1. Prompt custom theme and optional slide count (stateful dialog)
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black, width: 2.5),
              ),
              backgroundColor: NeoTheme.bgBase,
              title: const Text('💡 Tanya Ide AI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mau ide konten tentang apa hari ini?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: themeController,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: 'mis: Teknologi, Kuliner, Finansial...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Otomatis Isi Field dengan AI:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    if (showSlides) ...[
                      CheckboxListTile(
                        title: const Text('Tentukan Jumlah Slide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        value: autoSlideCount,
                        dense: true,
                        activeColor: Colors.black,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setState(() {
                            autoSlideCount = val ?? false;
                          });
                        },
                      ),
                      if (autoSlideCount) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Jumlah Slide:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: Text(
                                localSlideCount == 1 ? '1 Slide (Poster)' : '$localSlideCount Slide',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Slider(
                          value: localSlideCount.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: Colors.black,
                          inactiveColor: Colors.grey[300],
                          onChanged: (val) {
                            setState(() {
                              localSlideCount = val.round();
                            });
                          },
                        ),
                      ],
                    ],
                    if (supportsHook)
                      CheckboxListTile(
                        title: const Text('Otomatis Isi Hook / Pemikat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        value: autoHook,
                        dense: true,
                        activeColor: Colors.black,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setState(() {
                            autoHook = val ?? false;
                          });
                        },
                      ),
                    if (supportsCta)
                      CheckboxListTile(
                        title: const Text('Otomatis Isi CTA / Ajakan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        value: autoCta,
                        dense: true,
                        activeColor: Colors.black,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setState(() {
                            autoCta = val ?? false;
                          });
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                GestureDetector(
                  onTap: () {
                    final themeVal = themeController.text.trim();
                    Navigator.pop(context, {
                      'theme': themeVal.isEmpty ? defaultCategory : themeVal,
                      'slideCount': (showSlides && autoSlideCount) ? localSlideCount : null,
                      'autoHook': autoHook,
                      'autoCta': autoCta,
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: NeoTheme.accentPink,
                      border: Border.all(color: Colors.black, width: 2.5),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const Text(
                      'Hasilkan Ide (AI)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;
    final theme = result['theme'] as String;
    final selectedSlideCount = result['slideCount'] as int?;
    autoHook = result['autoHook'] as bool? ?? false;
    autoCta = result['autoCta'] as bool? ?? false;

    if (theme.isEmpty) return;

    // 2. Fetch ideas
    try {
      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: NeoTheme.accentPink),
        ),
      );

      String url = '/poster/ideas?category=${Uri.encodeComponent(theme)}';
      if (selectedSlideCount != null) {
        url += '&slideCount=$selectedSlideCount';
      }
      final res = await dioClient.get(url);
      
      // Pop loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (res.data['success'] == true) {
        final List<String> ideas = List<String>.from(res.data['data']);
        
        // Show picker
        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            backgroundColor: NeoTheme.bgBase,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              side: BorderSide(color: Colors.black, width: 2.5),
            ),
            builder: (context) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 Pilih Ide Rekomendasi AI',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: ideas.length,
                          separatorBuilder: (context, index) => const Divider(color: Colors.black, height: 1),
                          itemBuilder: (context, index) {
                            final idea = ideas[index];
                            return ListTile(
                              title: Text(
                                idea,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
                              onTap: () {
                                onIdeaSelected(
                                  idea,
                                  slideCount: selectedSlideCount,
                                  autoHook: autoHook,
                                  autoCta: autoCta,
                                );
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      debugPrint('Ideas helper error: $e');
    }
  }
}
