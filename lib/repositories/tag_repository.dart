import '../services/article_service.dart';
import '../services/local_storage_service.dart';

/// Repository qui gère les tags de l'utilisateur.
/// Les tags ajoutés manuellement sont persistés via shared_preferences.
class TagRepository {
  final ArticleService _articleService;
  final LocalStorageService _storage;

  List<String> _userTags = [];

  TagRepository(this._storage, {required ArticleService articleService})
    : _articleService = articleService;

  /// À appeler au démarrage pour charger les tags persistés
  Future<void> init() async {
    _userTags = _storage.readUserTags();
  }

  /// Récupère les tags : "Tout" + "Favoris" + tags API + tags ajoutés par l'user
  Future<List<String>> getTags({required String userId}) async {
    final apiTags = await _articleService.fetchTags(userId: userId);
    // Fusion sans doublon : tags API + tags perso
    final merged = {...apiTags, ..._userTags}.toList();
    return ['Tout', 'Favoris', ...merged];
  }

  /// Ajoute un tag personnalisé et le persiste
  /// Retourne false si le tag existe déjà, true sinon
  Future<bool> addTag(String tag) async {
    final normalized = _normalize(tag);
    if (_userTags.any((t) => _normalize(t) == normalized)) return false;
    _userTags.add(tag);
    await _storage.writeUserTags(_userTags);
    return true;
  }

  /// Supprime un tag personnalisé
  Future<void> removeTag(String tag) async {
    _userTags.removeWhere((t) => _normalize(t) == _normalize(tag));
    await _storage.writeUserTags(_userTags);
  }

  List<String> getCachedTags() => ['Tout', 'Favoris', ..._userTags];

  String _normalize(String s) => s.trim().toLowerCase();
}
