import 'package:flutter/material.dart';
import 'package:snacky/models/article.dart';
import 'package:snacky/screens/article_detail_screen.dart';
import 'package:snacky/services/article_formatter_service.dart';
import 'package:snacky/widgets/confidence_badge.dart';
import 'package:shimmer/shimmer.dart';

const _formatter = ArticleFormatterService();

class NewsCard extends StatefulWidget {
  final Article article;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  const NewsCard({
    super.key,
    required this.article,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _isExpanded = false;

  @override
  void didUpdateWidget(covariant NewsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si l'article affiché par ce widget change (ex: suite à un filtrage),
    // on force la fermeture de la carte.
    if (oldWidget.article.title != widget.article.title) {
      _isExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = const Color(0xFF3F51B5);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? (baseColor.withOpacity(_isExpanded ? 0.20 : 0.08))
            : (baseColor.withOpacity(_isExpanded ? 0.08 : 0.03)),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _isExpanded
              ? baseColor.withOpacity(0.3)
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade100),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image bannière pleine largeur ──────────────────────────
            if (widget.article.image != null &&
                widget.article.image!.isNotEmpty)
              Hero(
                tag: 'article_image_${widget.article.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: Image.network(
                    widget.article.image!,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildBannerShimmer();
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _buildBannerPlaceholder(),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Miniature uniquement si pas d'image bannière
                      if (widget.article.image == null ||
                          widget.article.image!.isEmpty) ...[
                        _buildPlaceholder(),
                        const SizedBox(width: 12),
                      ],

                      // Titre + source + badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.article.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${widget.article.source} • ${widget.article.time} · ${_formatter.readingTimeLabel(widget.article)}",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ConfidenceBadge(
                              confidence: widget.article.confidence,
                            ),
                          ],
                        ),
                      ),
                      // Icône Favoris
                      IconButton(
                        icon: Icon(
                          widget.isFavorite ? Icons.star : Icons.star_border,
                          color: widget.isFavorite ? Colors.amber : Colors.grey,
                        ),
                        onPressed: widget.onFavoriteToggle,
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF3F51B5),
                      ),
                    ],
                  ),

                  // ── Partie dépliable ────────────────────────────────
                  ClipRect(
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      alignment: Alignment.topLeft,
                      heightFactor: _isExpanded ? 1.0 : 0.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Text(widget.article.description),
                          const SizedBox(height: 8),
                          if (widget.article.confidenceReason != null)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  widget.article.confidence.icon,
                                  size: 14,
                                  color: widget.article.confidence.color,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    widget.article.confidenceReason!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.article.confidence.color,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          _ArticleLink(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ArticleDetailScreen(
                                  article: widget.article,
                                  isFavorite: widget.isFavorite,
                                  onFavoriteToggle: widget.onFavoriteToggle,
                                ),
                              ),
                            ),
                          ),
                        ],
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
  }
}

Widget _buildPlaceholder() {
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: const Color(0xFF3F51B5).withOpacity(0.7),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.article, color: Colors.white),
  );
}

Widget _buildBannerPlaceholder() {
  return Container(
    width: double.infinity,
    height: 160,
    decoration: BoxDecoration(
      color: const Color(0xFF3F51B5).withOpacity(0.12),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
    ),
    child: const Icon(Icons.image_rounded, size: 40, color: Color(0xFF3F51B5)),
  );
}

Widget _buildBannerShimmer() {
  return Shimmer.fromColors(
    baseColor: const Color(0xFF3F51B5).withOpacity(0.15),
    highlightColor: const Color(0xFF3F51B5).withOpacity(0.05),
    child: Container(
      width: double.infinity,
      height: 160,
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
    ),
  );
}

/// Lien "Voir l'article" avec underline au survol.
class _ArticleLink extends StatefulWidget {
  final VoidCallback onTap;
  const _ArticleLink({required this.onTap});

  @override
  State<_ArticleLink> createState() => _ArticleLinkState();
}

class _ArticleLinkState extends State<_ArticleLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          "Voir l'article",
          style: TextStyle(
            color: const Color(0xFF3F51B5),
            fontWeight: FontWeight.bold,
            decoration: _hovered
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: const Color(0xFF3F51B5),
          ),
        ),
      ),
    );
  }
}
