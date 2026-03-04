import '../services/mock_api_service.dart';

/// Repository qui gère les tags de l'utilisateur.
/// Les tags sont toujours rechargés depuis l'API à chaque démarrage
/// (légers, pas besoin de cache journalier).
class TagRepository {
  final MockApiService _apiService;

  TagRepository({MockApiService? apiService})
    : _apiService = apiService ?? MockApiService();

  List<String> _cachedTags = [];

  /// Récupère les tags de l'utilisateur depuis l'API.
  /// Ajoute automatiquement "Tout" et "Favoris" en tête.
  Future<List<String>> getTags({required String userId}) async {
    final userTags = await _apiService.fetchTags(userId: userId);
    _cachedTags = ['Tout', 'Favoris', ...userTags];
    return _cachedTags;
  }

  List<String> getCachedTags() =>
      _cachedTags.isEmpty ? ['Tout', 'Favoris'] : _cachedTags;
}
