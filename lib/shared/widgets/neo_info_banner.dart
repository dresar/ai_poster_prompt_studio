import 'package:flutter/material.dart';
import '../../core/theme/neo_theme.dart';

class NeoInfoBanner extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;

  const NeoInfoBanner({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor = NeoTheme.accentBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeoTheme.neoBoxDecoration(
        color: backgroundColor,
        borderRadius: 20.0,
        hasShadow: true,
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? Icons.auto_awesome,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
