import 'package:flutter/material.dart';
import '../../core/theme/neo_theme.dart';

class NeoSectionCard extends StatelessWidget {
  final String title;
  final String? emoji;
  final bool isOptional;
  final Color backgroundColor;
  final Widget child;

  const NeoSectionCard({
    super.key,
    required this.title,
    this.emoji,
    this.isOptional = false,
    this.backgroundColor = Colors.white,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeoTheme.neoBoxDecoration(
        color: backgroundColor,
        borderRadius: 24.0,
        hasShadow: true,
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (emoji != null) ...[
                    Text(
                      emoji!,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
              if (isOptional)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: NeoTheme.textMuted.withOpacity(0.5), width: 1.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    'OPSIONAL',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: NeoTheme.textMuted,
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
