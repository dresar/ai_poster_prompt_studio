import 'package:flutter/material.dart';
import '../network/dio_client.dart';
import '../theme/neo_theme.dart';

class IdeasHelper {
  static Future<void> showIdeasDialog({
    required BuildContext context,
    required String defaultCategory,
    required Function(String) onIdeaSelected,
  }) async {
    final themeController = TextEditingController(text: defaultCategory);
    
    // 1. Prompt custom theme
    final theme = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 2.5),
          ),
          backgroundColor: NeoTheme.bgBase,
          title: const Text('💡 Tanya Ide AI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          content: Column(
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: () {
                final themeVal = themeController.text.trim();
                Navigator.pop(context, themeVal.isEmpty ? defaultCategory : themeVal);
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

    if (theme == null || theme.isEmpty) return;

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

      final res = await dioClient.get('/poster/ideas?category=${Uri.encodeComponent(theme)}');
      
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
                                onIdeaSelected(idea);
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
