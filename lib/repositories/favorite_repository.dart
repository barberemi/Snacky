import '../models/article.dart';
import '../services/local_storage_service.dart';

/// Repository qui gère les favoris de l'utilisateur.
/// Les favoris sont persistés via shared_preferences et survivent
/// aux redémarrages et mises à jour de l'application.
class FavoriteRepository {
  final LocalStorageService _storage;

  /// Set d'ids pour les vérifications rapides
  final Set<String> _favoriteIds = {};

  /// Liste ordonnée des articles favoris
  final List<Article> _favorites = [];

  FavoriteRepository(this._storage);

  /// À appeler une fois au démarrage pour charger les favoris persistés
  Future<void> init() async {
    final rawList = _storage.readFavorites();
    final articles = rawList.map(Article.fromJson).toList();
    _favorites.clear();
    _favoriteIds.clear();
    for (final article in articles) {
      _favorites.add(article);
      _favoriteIds.add(article.id);
    }
  }

  /// Ajoute ou retire un article des favoris, puis persiste
  Future<void> toggleFavorite(Article article) async {
    if (_favoriteIds.contains(article.id)) {
      _favoriteIds.remove(article.id);
      _favorites.removeWhere((a) => a.id == article.id);
    } else {
      _favoriteIds.add(article.id);
      _favorites.add(article);
    }
    await _persist();
  }

  /// Vérifie si un article est en favori
  bool isFavorite(Article article) => _favoriteIds.contains(article.id);

  /// Retourne la liste des articles favoris (immuable)
  List<Article> getFavorites() => List.unmodifiable(_favorites);

  Future<void> _persist() async {
    await _storage.writeFavorites(_favorites.map((a) => a.toJson()).toList());
  }
}
