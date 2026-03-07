import '../models/article.dart';

/// Responsabilité unique : formater les données d'un article pour l'affichage.
///
/// Aucune dépendance vers Flutter, aucun état — pure logique métier testable.
class ArticleFormatterService {
  const ArticleFormatterService();

  /// Estime le temps de lecture en minutes.
  /// Base : 200 mots/minute (lecture confortable sur mobile).
  int estimateReadingTimeMinutes(Article article) {
    final text = '${article.title} ${article.description}';
    final wordCount = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    final minutes = (wordCount / 200).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  /// Retourne le label formaté : "1 min" ou "3 min".
  String readingTimeLabel(Article article) {
    final minutes = estimateReadingTimeMinutes(article);
    return '$minutes min';
  }

  /// Retourne une date relative lisible à partir de [Article.fetchedAt].
  /// Ex: "À l'instant", "il y a 3h", "hier", "il y a 5 jours"
  String relativeDate(Article article) {
    final now = DateTime.now();
    final diff = now.difference(article.fetchedAt);

    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'hier';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} jours';
    return 'il y a ${(diff.inDays / 7).floor()} sem.';
  }

  /// Tronque un titre s'il dépasse [maxLength] caractères.
  String truncateTitle(String title, {int maxLength = 60}) {
    if (title.length <= maxLength) return title;
    return '${title.substring(0, maxLength)}…';
  }
}
