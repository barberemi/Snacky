import '../models/article.dart';

/// Repository qui gère les favoris de l'utilisateur.
/// Stockage en mémoire pour l'instant, sera remplacé par Isar.
class FavoriteRepository {
  /// Stockage local des favoris (Set d'ids pour la perf)
  final Set<String> _favoriteIds = {};

  /// Liste complète des articles favoris
  final List<Article> _favorites = [];

  /// Ajoute ou retire un article des favoris
  void toggleFavorite(Article article) {
    if (_favoriteIds.contains(article.id)) {
      _favoriteIds.remove(article.id);
      _favorites.removeWhere((a) => a.id == article.id);
    } else {
      _favoriteIds.add(article.id);
      _favorites.add(article);
    }
  }

  /// Vérifie si un article est en favori
  bool isFavorite(Article article) => _favoriteIds.contains(article.id);

  /// Retourne la liste des articles favoris
  List<Article> getFavorites() => List.unmodifiable(_favorites);
}
