import '../models/article.dart';
import '../services/mock_api_service.dart';

/// Repository qui gère la récupération des articles.
/// C'est la couche entre l'UI et le service API.
/// Plus tard, il pourra aussi lire/écrire dans Isar (cache local).
class ArticleRepository {
  final MockApiService _apiService;

  ArticleRepository({MockApiService? apiService})
    : _apiService = apiService ?? MockApiService();

  /// Cache local en mémoire (sera remplacé par Isar plus tard)
  List<Article> _cachedArticles = [];

  /// Récupère tous les articles de l'utilisateur (via API, puis cache)
  Future<List<Article>> getAllArticles({required String userId}) async {
    final articles = await _apiService.fetchAllArticles(userId: userId);
    _cachedArticles = articles;
    return articles;
  }

  /// Récupère les articles d'un tag spécifique
  Future<List<Article>> getArticlesByTag({
    required String userId,
    required String tag,
  }) async {
    final articles = await _apiService.fetchArticlesByTag(
      userId: userId,
      tag: tag,
    );
    return articles;
  }

  /// Retourne le cache local (utile pour l'offline plus tard)
  List<Article> getCachedArticles() => _cachedArticles;
}
