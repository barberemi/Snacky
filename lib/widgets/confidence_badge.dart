import 'package:flutter/material.dart';
import 'package:snacky/models/confidence_level.dart';

/// Badge compact affichant le niveau de confiance d'un article.
/// Utilisé dans [NewsCard] et [ArticleDetailScreen].
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
