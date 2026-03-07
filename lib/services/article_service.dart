import '../models/article.dart';

/// Contrat abstrait du service d'articles.
///
/// Pour brancher l'API Rust :
///   1. Crée `lib/services/api_article_service.dart` qui `implements ArticleService`
///   2. Remplace `MockArticleService` par `ApiArticleService` dans `main.dart`
///   C'est tout.
abstract class ArticleService {
  /// Récupère tous les articles de l'utilisateur.
  Future<List<Article>> fetchAllArticles({required String userId});

  /// Récupère les articles filtrés par tag.
  Future<List<Article>> fetchArticlesByTag({
    required String userId,
    required String tag,
  });

  /// Récupère les tags disponibles pour l'utilisateur.
  Future<List<String>> fetchTags({required String userId});
}
