import 'package:flutter/material.dart';
import 'package:snacky/models/article.dart';
import 'package:snacky/models/confidence_level.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class NewsCard extends StatefulWidget {
  final Article article;
  final bool isFavorite; // Ajouté
  final VoidCallback onFavoriteToggle; // Ajouté
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

  // Fonction pour ouvrir le navigateur
  Future<void> _launchURL() async {
    final String? urlString = widget.article.url;
    if (urlString != null) {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Impossible d\'ouvrir $urlString');
      }
    }
  }

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
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LOGIQUE D'IMAGE AVEC FALLBACK ---
                  widget.article.image != null &&
                          widget.article.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.article.image!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            // --- EFFET SHIMMER PENDANT LE CHARGEMENT ---
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null)
                                return child; // Image chargée
                              return _buildShimmerPlaceholder(); // En cours de chargement
                            },
                            // Si l'URL est là mais que l'image ne charge pas (404, etc.)
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(),
                          ),
                        )
                      : _buildPlaceholder(), // Si l'URL est null ou vide

                  const SizedBox(width: 12),

                  // Le reste de tes infos (Titre, Source, etc.)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.article.title, // Correction finale
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "${widget.article.source} • ${widget.article.time}",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _ConfidenceBadge(confidence: widget.article.confidence),
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

              // LA PARTIE QUI SE DÉPLIE
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
                      // Raison du score de confiance
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

                      // LE BOUTON CLIQUABLE
                      _ArticleLink(onTap: _launchURL),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge coloré affichant le niveau de confiance d'un article
class _ConfidenceBadge extends StatelessWidget {
  final ConfidenceLevel confidence;
  const _ConfidenceBadge({required this.confidence});

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

Widget _buildShimmerPlaceholder() {
  return Shimmer.fromColors(
    baseColor: const Color(0xFF3F51B5).withOpacity(0.15),
    highlightColor: const Color(0xFF3F51B5).withOpacity(0.05),
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF3F51B5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
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
