import '../models/article.dart';
import '../services/mock_api_service.dart';
import '../services/local_storage_service.dart';

/// Repository qui gère la récupération et le cache journalier des articles.
///
/// Logique de cache :
/// - Au démarrage, on lit le cache local (shared_preferences).
/// - Si les articles sont périmés (fetchedAt < aujourd'hui), on vide le cache
///   et on refetch depuis l'API.
/// - Si le cache est encore frais (même jour), on l'utilise directement.
/// - Les articles en cache expirent automatiquement le lendemain.
class ArticleRepository {
  final MockApiService _apiService;
  final LocalStorageService _storage;

  List<Article> _cachedArticles = [];

  ArticleRepository(this._storage, {MockApiService? apiService})
    : _apiService = apiService ?? MockApiService();

  /// À appeler au démarrage : charge le cache ou refetch si périmé
  Future<List<Article>> getAllArticles({required String userId}) async {
    // 1. Lire le cache persisté
    final rawList = _storage.readCachedArticles();
    if (rawList.isNotEmpty) {
      final cached = rawList.map(Article.fromJson).toList();

      // 2. Vérifier si le cache est encore valide (tous du jour même)
      final allFresh = cached.every((a) => !a.isExpired);
      if (allFresh) {
        _cachedArticles = cached;
        return _cachedArticles;
      }
      // Cache périmé → on le supprime
      await _storage.writeCachedArticles([]);
    }

    // 3. Fetch depuis l'API et mise en cache
    return _fetchAndCache(userId: userId);
  }

  /// Récupère les articles d'un tag spécifique
  /// Utilise le cache si disponible, sinon fetch l'API
  Future<List<Article>> getArticlesByTag({
    required String userId,
    required String tag,
  }) async {
    // Si on a un cache frais, on filtre dessus sans appel réseau
    if (_cachedArticles.isNotEmpty) {
      final fromCache = _cachedArticles
          .where((a) => a.tags.any((t) => t.toLowerCase() == tag.toLowerCase()))
          .toList();
      if (fromCache.isNotEmpty) return fromCache;
    }

    // Sinon appel API
    final articles = await _apiService.fetchArticlesByTag(
      userId: userId,
      tag: tag,
    );
    return articles;
  }

  /// Retourne le cache en mémoire
  List<Article> getCachedArticles() => _cachedArticles;

  // ─── Privé ────────────────────────────────────────────────────────────────

  Future<List<Article>> _fetchAndCache({required String userId}) async {
    final articles = await _apiService.fetchAllArticles(userId: userId);
    _cachedArticles = articles;
    await _storage.writeCachedArticles(
      articles.map((a) => a.toJson()).toList(),
    );
    return _cachedArticles;
  }
}
