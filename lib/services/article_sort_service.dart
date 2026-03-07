import '../models/article.dart';
import '../models/confidence_level.dart';

/// Responsabilité unique : trier et filtrer une liste d'articles.
///
/// Aucune dépendance vers Flutter, aucun état — pure logique métier testable.
class ArticleSortService {
  const ArticleSortService();

  /// Trie du plus récent au plus ancien via [Article.fetchedAt].
  List<Article> sortByRecent(List<Article> articles) {
    final copy = List<Article>.from(articles);
    copy.sort((a, b) => b.fetchedAt.compareTo(a.fetchedAt));
    return copy;
  }

  /// Trie par niveau de fiabilité décroissant :
  /// high → medium → low → unknown
  List<Article> sortByConfidence(List<Article> articles) {
    final copy = List<Article>.from(articles);
    copy.sort((a, b) => a.confidence.index.compareTo(b.confidence.index));
    return copy;
  }

  /// Filtre les articles contenant au moins un des [tags] donnés.
  List<Article> filterByTag(List<Article> articles, String tag) {
    if (tag == 'Tout') return articles;
    return articles
        .where((a) => a.tags.any((t) => t.toLowerCase() == tag.toLowerCase()))
        .toList();
  }

  /// Retourne le label lisible du niveau de confiance.
  String confidenceLabel(ConfidenceLevel level) => level.label;
}
