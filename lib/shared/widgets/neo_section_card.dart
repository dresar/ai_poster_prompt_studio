import 'package:flutter/material.dart';
import '../../core/theme/neo_theme.dart';

class NeoSectionCard extends StatelessWidget {
  final String title;
  final String? emoji;
  final bool isOptional;
  final Color backgroundColor;
  final Widget child;
  final Widget? trailing;

  const NeoSectionCard({
    super.key,
    required this.title,
    this.emoji,
    this.isOptional = false,
    this.backgroundColor = Colors.white,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeoTheme.neoBoxDecoration(
        color: backgroundColor,
        borderRadius: 24.0,
        hasShadow: true,
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (emoji != null) ...[
                      Text(
                        emoji!,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOptional) ...[
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
                    if (trailing != null) const SizedBox(width: 8),
                  ],
                  if (trailing != null) trailing!,
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class NeoFullscreenButton extends StatelessWidget {
  final VoidCallback onTap;
  const NeoFullscreenButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fullscreen, size: 14, color: Colors.black),
            SizedBox(width: 4),
            Text(
              'Perbesar',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
