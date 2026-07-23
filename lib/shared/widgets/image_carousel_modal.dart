import 'package:flutter/material.dart';
import '../../core/theme/neo_theme.dart';

class ImageCarouselModal extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageCarouselModal({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  static void show(BuildContext context, List<String> urls, {int initialIndex = 0}) {
    if (urls.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => ImageCarouselModal(
        imageUrls: urls,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  State<ImageCarouselModal> createState() => _ImageCarouselModalState();
}

class _ImageCarouselModalState extends State<ImageCarouselModal> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.imageUrls.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Swipeable PageView ──
          PageView.builder(
            controller: _pageController,
            itemCount: total,
            onPageChanged: (idx) => setState(() => _currentIndex = idx),
            itemBuilder: (context, index) {
              final url = widget.imageUrls[index];
              return Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 3.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: Colors.white70),
                          SizedBox(height: 8),
                          Text('Gambar gagal dimuat', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: NeoTheme.accentPink),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Top Header Controls ──
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Slide Counter Badge (e.g. 1/5)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / $total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),

                // Close Button (X)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // ── Navigation Arrows (if > 1 image) ──
          if (total > 1) ...[
            if (_currentIndex > 0)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    iconSize: 36,
                    onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            if (_currentIndex < total - 1)
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    iconSize: 36,
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 1),
                      ),
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
