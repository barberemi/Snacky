import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Couche bas niveau autour de shared_preferences.
/// Gère la sérialisation/désérialisation JSON.
/// Les repositories passent par ce service pour lire/écrire.
class LocalStorageService {
  static const String _favoritesKey = 'favorites';
  static const String _articlesKey = 'cached_articles';
  static const String _userTagsKey = 'user_tags';
  static const String _sessionKey = 'auth_session'; // Session utilisateur

  final SharedPreferences _prefs;

  LocalStorageService._(this._prefs);

  /// Factory async — à appeler une seule fois au démarrage (dans main.dart)
  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService._(prefs);
  }

  // ─── FAVORIS ─────────────────────────────────────────────────────────────

  /// Lit la liste brute JSON des favoris
  List<Map<String, dynamic>> readFavorites() {
    final raw = _prefs.getString(_favoritesKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Écrit la liste des favoris en JSON
  Future<void> writeFavorites(List<Map<String, dynamic>> favorites) async {
    await _prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  // ─── CACHE ARTICLES ───────────────────────────────────────────────────────

  /// Lit la liste brute JSON des articles en cache
  List<Map<String, dynamic>> readCachedArticles() {
    final raw = _prefs.getString(_articlesKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Écrit la liste des articles en cache en JSON
  Future<void> writeCachedArticles(List<Map<String, dynamic>> articles) async {
    await _prefs.setString(_articlesKey, jsonEncode(articles));
  }

  // ─── TAGS UTILISATEUR ────────────────────────────────────────────────────

  /// Lit la liste des tags personnalisés de l'utilisateur
  List<String> readUserTags() {
    final raw = _prefs.getStringList(_userTagsKey);
    return raw ?? [];
  }

  /// Écrit la liste des tags personnalisés
  Future<void> writeUserTags(List<String> tags) async {
    await _prefs.setStringList(_userTagsKey, tags);
  }

  // ─── SESSION UTILISATEUR ─────────────────────────────────────────────────

  /// Lit les données de session persistées (utilisateur sérialisé en JSON).
  /// Retourne null si aucune session n'existe.
  Map<String, dynamic>? readSession() {
    final raw = _prefs.getString(_sessionKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Persiste les données de session (ex: objet AuthUser sérialisé).
  Future<void> writeSession(Map<String, dynamic> session) async {
    await _prefs.setString(_sessionKey, jsonEncode(session));
  }

  /// Supprime la session (déconnexion).
  Future<void> clearSession() async {
    await _prefs.remove(_sessionKey);
  }
}
