import 'package:flutter/material.dart';
import '../../core/theme/neo_theme.dart';

class NeoTabSwitcher extends StatelessWidget {
  final int selectedIndex;
  final List<String> tabs;
  final ValueChanged<int> onTabChanged;

  const NeoTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.tabs,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: NeoTheme.neoBorder,
      ),
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                onTabChanged(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected ? NeoTheme.badgePro : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isSelected ? Colors.white : NeoTheme.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
