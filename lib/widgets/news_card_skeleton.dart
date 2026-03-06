import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Fausse card en shimmer affichée pendant le chargement.
class NewsCardSkeleton extends StatelessWidget {
  const NewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE8E8F0);
    final highlight = isDark
        ? const Color(0xFF3A3A50)
        : const Color(0xFFF5F5FA);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniature image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre ligne 1
                  _Bar(width: double.infinity, height: 13),
                  const SizedBox(height: 6),
                  // Titre ligne 2 (plus courte)
                  _Bar(width: 200, height: 13),
                  const SizedBox(height: 10),
                  // Source + date
                  _Bar(width: 120, height: 11),
                  const SizedBox(height: 8),
                  // Badge confiance
                  _Bar(width: 70, height: 20, radius: 20),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Icône favoris placeholder
            _Bar(width: 24, height: 24, radius: 4),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Bar({required this.width, required this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Liste de skeletons à afficher pendant le chargement.
class NewsListSkeleton extends StatelessWidget {
  final int count;
  const NewsListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (_, __) => const NewsCardSkeleton(),
    );
  }
}
