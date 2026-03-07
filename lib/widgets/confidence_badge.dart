/// Barrel des widgets de confiance.
library;

import 'package:flutter/material.dart';
import 'package:snacky/models/confidence_level.dart';

export 'confidence_detail.dart';

/// Badge compact (icône + label) — utilisé dans [NewsCard].
class ConfidenceBadge extends StatelessWidget {
  final ConfidenceLevel confidence;

  const ConfidenceBadge({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? confidence.color.withOpacity(0.15)
        : confidence.backgroundColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: confidence.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(confidence.icon, size: 11, color: confidence.color),
          const SizedBox(width: 4),
          Text(
            confidence.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: confidence.color,
            ),
          ),
        ],
      ),
    );
  }
}
