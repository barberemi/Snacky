import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:snacky/models/article.dart';
import 'package:snacky/widgets/confidence_badge.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  static const _brandColor = Color(0xFF3F51B5);

  Future<void> _launchURL() async {
    final uri = Uri.parse(widget.article.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d\'ouvrir ${widget.article.url}');
    }
  }

  Future<void> _share() async {
    final text =
        '${widget.article.title}\n\n${widget.article.description}\n\n🔗 ${widget.article.url}';
    await Share.share(text, subject: widget.article.title);
  }

  void _toggleFavorite() {
    widget.onFavoriteToggle();
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── AppBar avec image en hero ──────────────────────────────────
          SliverAppBar(
            expandedHeight: widget.article.image != null ? 240 : 120,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // Favori
              IconButton(
                tooltip: _isFavorite
                    ? 'Retirer des favoris'
                    : 'Ajouter aux favoris',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: _isFavorite
                        ? Colors.amber
                        : theme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
                onPressed: _toggleFavorite,
              ),
              // Partage
              IconButton(
                tooltip: 'Partager',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.share_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
                onPressed: _share,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background:
                  widget.article.image != null &&
                      widget.article.image!.isNotEmpty
                  ? Hero(
                      tag: 'article_image_${widget.article.id}',
                      child: Image.network(
                        widget.article.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildImageFallback(isDark),
                      ),
                    )
                  : _buildImageFallback(isDark),
            ),
          ),

          // ── Contenu ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source + temps
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _brandColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.article.source,
                          style: const TextStyle(
                            color: _brandColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.article.time,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Titre
                  Text(
                    widget.article.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Badge de confiance
                  ConfidenceDetail(
                    confidence: widget.article.confidence,
                    reason: widget.article.confidenceReason,
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.article.description,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 28),

                  // Tags
                  if (widget.article.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: widget.article.tags
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _brandColor.withOpacity(
                                isDark ? 0.15 : 0.08,
                              ),
                              side: BorderSide(
                                color: _brandColor.withOpacity(0.3),
                              ),
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Bouton "Lire l'article complet"
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _launchURL,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text(
                        'Lire l\'article complet',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bouton partage secondaire
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text(
                        'Partager',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _brandColor,
                        side: const BorderSide(color: _brandColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
    );
  }

  Widget _buildImageFallback(bool isDark) {
    return Container(
      color: _brandColor.withOpacity(isDark ? 0.2 : 0.08),
      child: Center(
        child: Icon(
          Icons.article_rounded,
          size: 64,
          color: _brandColor.withOpacity(0.3),
        ),
      ),
    );
  }
}
