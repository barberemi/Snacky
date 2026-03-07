import 'package:flutter/material.dart';
import 'package:snacky/models/confidence_level.dart';

/// Bloc détaillé confiance avec raison — utilisé dans [ArticleDetailScreen].
class ConfidenceDetail extends StatelessWidget {
  final ConfidenceLevel confidence;
  final String? reason;

  const ConfidenceDetail({super.key, required this.confidence, this.reason});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = confidence;
    final bg = isDark ? c.color.withOpacity(0.15) : c.backgroundColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(c.icon, size: 18, color: c.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fiabilité : ${c.label}',
                  style: TextStyle(
                    color: c.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (reason != null)
                  Text(
                    reason!,
                    style: TextStyle(
                      color: c.color.withOpacity(0.85),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
