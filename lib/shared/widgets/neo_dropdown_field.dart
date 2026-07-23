import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/neo_theme.dart';
import '../../core/services/cache_service.dart';

class NeoDropdownOption {
  final String id;
  final String label;
  final String value;
  final String? helperText;
  final String? icon;

  NeoDropdownOption({
    required this.id,
    required this.label,
    required this.value,
    this.helperText,
    this.icon,
  });
}

class NeoDropdownField extends StatelessWidget {
  final String label;
  final String? leadingEmoji;
  final NeoDropdownOption? selectedOption;
  final List<NeoDropdownOption> options;
  final bool isLoading;
  final ValueChanged<NeoDropdownOption> onSelected;
  final bool isVisualGrid;
  final bool isVisualHorizontal;

  const NeoDropdownField({
    super.key,
    required this.label,
    this.leadingEmoji,
    required this.selectedOption,
    required this.options,
    this.isLoading = false,
    required this.onSelected,
    this.isVisualGrid = false,
    this.isVisualHorizontal = false,
  });

  static Widget buildImageWidget(String path, {BoxFit fit = BoxFit.cover, double? errorSize = 24}) {
    if (path.startsWith('http')) {
      final localCachedPath = CacheService.instance.getLocalCachePathFor(path);
      if (localCachedPath != null) {
        return Image.file(
          File(localCachedPath),
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: errorSize, color: NeoTheme.textMuted),
        );
      }
      return CachedNetworkImage(
        imageUrl: path,
        fit: fit,
        placeholder: (context, url) => Container(
          color: NeoTheme.bgBase,
          child: const Center(
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Icon(Icons.broken_image, size: errorSize, color: NeoTheme.textMuted),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: errorSize, color: NeoTheme.textMuted),
      );
    } else {
      return Image.file(
        File(path.replaceFirst('file://', '')),
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: errorSize, color: NeoTheme.textMuted),
      );
    }
  }

  static void showImageModal(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: buildImageWidget(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorSize: 80,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5D9E), // NeoTheme.accentPink
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectionSheet(BuildContext context) {
    if (isLoading || options.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: NeoTheme.bgBase,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        side: BorderSide(color: NeoTheme.borderStrong, width: 2.5),
      ),
      builder: (context) {
        String searchQuery = '';

        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: 20,
                  right: 20,
                  top: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: NeoTheme.borderStrong,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilih $label',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Search bar
                    TextField(
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari $label...',
                        prefixIcon: const Icon(Icons.search, color: NeoTheme.borderStrong),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: NeoTheme.borderStrong, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: NeoTheme.borderStrong, width: 2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Options list
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.55,
                      ),
                      child: Builder(
                        builder: (context) {
                          final currentOptions = options.where((o) => o.label.toLowerCase().contains(searchQuery)).toList();
                          if (currentOptions.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text('Tidak ditemukan.'),
                              ),
                            );
                          }
                          
                          if (isVisualHorizontal) {
                            return ListView.separated(
                              shrinkWrap: true,
                              itemCount: currentOptions.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final option = currentOptions[index];
                                final isSelected = selectedOption?.value == option.value;

                                return GestureDetector(
                                  onTap: () {
                                    onSelected(option);
                                    Navigator.pop(context);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    decoration: NeoTheme.neoBoxDecoration(
                                      color: isSelected ? NeoTheme.accentYellow : Colors.white,
                                      borderRadius: 16.0,
                                      hasShadow: !isSelected,
                                    ),
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.label,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(fontWeight: FontWeight.w900, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: option.icon != null && option.icon!.isNotEmpty
                                                      ? buildImageWidget(option.icon!)
                                                      : const Center(child: Icon(Icons.image, size: 36, color: NeoTheme.textMuted)),
                                                ),
                                              ),
                                              if (option.icon != null && option.icon!.isNotEmpty)
                                                Positioned(
                                                  top: 6,
                                                  right: 6,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showImageModal(context, option.icon!, option.label);
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.9),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color: Colors.black, width: 1.5),
                                                      ),
                                                      padding: const EdgeInsets.all(4),
                                                      child: const Icon(Icons.zoom_in, size: 16, color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          if (isVisualGrid) {
                            return GridView.builder(
                              shrinkWrap: true,
                              itemCount: currentOptions.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.85,
                              ),
                              itemBuilder: (context, index) {
                                final option = currentOptions[index];
                                final isSelected = selectedOption?.value == option.value;

                                return GestureDetector(
                                  onTap: () {
                                    onSelected(option);
                                    Navigator.pop(context);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    decoration: NeoTheme.neoBoxDecoration(
                                      color: isSelected ? NeoTheme.accentYellow : Colors.white,
                                      borderRadius: 16.0,
                                      hasShadow: !isSelected,
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Rectangle Image
                                        if (option.icon != null && option.icon!.isNotEmpty)
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: buildImageWidget(option.icon!),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 6,
                                                  right: 6,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showImageModal(context, option.icon!, option.label);
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.9),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color: Colors.black, width: 1.5),
                                                      ),
                                                      padding: const EdgeInsets.all(4),
                                                      child: const Icon(Icons.zoom_in, size: 16, color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          const Expanded(
                                            child: Center(
                                              child: Icon(Icons.image, size: 36, color: NeoTheme.textMuted),
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          option.label,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(fontWeight: FontWeight.w900),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (option.helperText != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            option.helperText!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: NeoTheme.textMuted,
                                                  fontSize: 10,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: currentOptions.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final option = currentOptions[index];
                              final isSelected = selectedOption?.value == option.value;

                              return GestureDetector(
                                onTap: () {
                                  onSelected(option);
                                  Navigator.pop(context);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  decoration: NeoTheme.neoBoxDecoration(
                                    color: isSelected ? NeoTheme.accentYellow : Colors.white,
                                    borderRadius: 16.0,
                                    hasShadow: !isSelected,
                                  ),
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Image or emoji avatar 1:1
                                      if (option.icon != null) ...[
                                        GestureDetector(
                                          onTap: () {
                                            showImageModal(context, option.icon!, option.label);
                                          },
                                          child: Stack(
                                            children: [
                                              if (option.icon!.startsWith('http') ||
                                                  option.icon!.startsWith('assets/') ||
                                                  option.icon!.startsWith('/') ||
                                                  option.icon!.contains(':\\') ||
                                                  option.icon!.startsWith('file://'))
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: SizedBox(
                                                    height: 50,
                                                    width: 50,
                                                    child: buildImageWidget(option.icon!, fit: BoxFit.cover, errorSize: 20),
                                                  ),
                                                )
                                              else
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: NeoTheme.bgBase,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: NeoTheme.borderStrong, width: 1.5),
                                                  ),
                                                  child: Text(
                                                    option.icon!,
                                                    style: const TextStyle(fontSize: 24),
                                                  ),
                                                ),
                                              if (option.icon!.startsWith('http') || option.icon!.startsWith('assets/') || option.icon!.startsWith('/') || option.icon!.contains(':\\') || option.icon!.startsWith('file://'))
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.8),
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(4),
                                                        bottomRight: Radius.circular(8),
                                                      ),
                                                    ),
                                                    child: const Icon(Icons.zoom_in, size: 12, color: Colors.black),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              option.label,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(fontWeight: FontWeight.w900),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (option.helperText != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                option.helperText!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: NeoTheme.textMuted,
                                                      fontSize: 11,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: NeoTheme.borderStrong,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const Spacer(),
            if (selectedOption?.helperText != null && !isLoading)
              Tooltip(
                message: selectedOption!.helperText!,
                triggerMode: TooltipTriggerMode.tap,
                child: Image.asset(
                  'assets/1.png',
                  height: 20,
                  width: 20,
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: NeoTheme.textMuted,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showSelectionSheet(context),
          child: Container(
            decoration: NeoTheme.neoBoxDecoration(
              color: Colors.white,
              borderRadius: 16.0,
              hasShadow: true,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (leadingEmoji != null) ...[
                  Text(
                    leadingEmoji!,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: isLoading
                      ? const Text(
                          'Memuat pilihan...',
                          style: TextStyle(color: NeoTheme.textMuted),
                        )
                      : Text(
                          selectedOption?.label ?? 'Pilih $label',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: selectedOption == null
                                    ? NeoTheme.textMuted
                                    : NeoTheme.textPrimary,
                               ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: NeoTheme.borderStrong,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NeoSelectedPreview extends StatelessWidget {
  final NeoDropdownOption? option;
  final double height;

  const NeoSelectedPreview({
    super.key,
    required this.option,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    if (option?.icon == null || option!.icon!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final icon = option!.icon!;
    final isUrl = icon.startsWith('http');
    final isAsset = icon.startsWith('assets/');
    final isPath = icon.startsWith('/') || icon.contains(':\\') || icon.startsWith('file://');
    
    if (!isUrl && !isAsset && !isPath) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GestureDetector(
        onTap: () => NeoDropdownField.showImageModal(context, icon, option!.label),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(2, 2)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: NeoDropdownField.buildImageWidget(
              icon,
              fit: BoxFit.cover,
              errorSize: 40,
            ),
          ),
        ),
      ),
    );
  }
}
