import 'package:flutter/material.dart';
import '../../core/theme/neo_theme.dart';
import 'neo_buttons.dart';
import 'neo_text_field.dart';

class WatermarkItem {
  String platform; // 'Instagram', 'TikTok', 'YouTube', 'Website', 'Custom'
  String value;

  WatermarkItem({
    required this.platform,
    required this.value,
  });

  @override
  String toString() {
    if (platform == 'Custom') {
      return value;
    }
    return '$platform: $value';
  }
}

class NeoWatermarkListField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const NeoWatermarkListField({
    super.key,
    this.initialValue = '',
    required this.onChanged,
  });

  @override
  State<NeoWatermarkListField> createState() => _NeoWatermarkListFieldState();
}

class _NeoWatermarkListFieldState extends State<NeoWatermarkListField> {
  final List<WatermarkItem> _items = [];
  final List<String> _platforms = ['Instagram', 'TikTok', 'YouTube', 'Website', 'Custom'];

  @override
  void initState() {
    super.initState();
    _parseInitialValue();
  }

  void _parseInitialValue() {
    if (widget.initialValue.isEmpty) {
      _items.add(WatermarkItem(platform: 'Instagram', value: ''));
      return;
    }

    try {
      final parts = widget.initialValue.split('|');
      for (var part in parts) {
        part = part.trim();
        if (part.isEmpty) continue;

        final colonIndex = part.indexOf(':');
        if (colonIndex != -1) {
          final platform = part.substring(0, colonIndex).trim();
          final val = part.substring(colonIndex + 1).trim();
          if (_platforms.contains(platform)) {
            _items.add(WatermarkItem(platform: platform, value: val));
            continue;
          }
        }
        _items.add(WatermarkItem(platform: 'Custom', value: part));
      }
    } catch (e) {
      _items.add(WatermarkItem(platform: 'Custom', value: widget.initialValue));
    }

    if (_items.isEmpty) {
      _items.add(WatermarkItem(platform: 'Instagram', value: ''));
    }
  }

  void _updateParent() {
    final activeItems = _items.where((i) => i.value.trim().isNotEmpty).toList();
    final combined = activeItems.map((i) => i.toString()).join(' | ');
    widget.onChanged(combined);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Watermark Penerbit / Media Sosial',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _items[index];
            return Row(
              children: [
                // Platform selector
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: item.platform,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      items: _platforms.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            item.platform = val;
                          });
                          _updateParent();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Handle/URL Input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: TextEditingController(text: item.value)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: item.value.length),
                        ),
                      onChanged: (val) {
                        item.value = val;
                        _updateParent();
                      },
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'mis: @username atau link...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                ),
                // Delete button
                if (_items.length > 1) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _items.removeAt(index);
                      });
                      _updateParent();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: NeoTheme.accentPink,
                        border: Border.all(color: Colors.black, width: 2.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        // Add button
        GestureDetector(
          onTap: () {
            setState(() {
              _items.add(WatermarkItem(platform: 'Instagram', value: ''));
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2.5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.black, size: 16),
                SizedBox(width: 6),
                Text(
                  'Tambah Platform',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
