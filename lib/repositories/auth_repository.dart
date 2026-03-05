import 'package:snacky/models/auth_user.dart';
import 'package:snacky/services/auth_service.dart';
import 'package:snacky/services/local_storage_service.dart';

/// Orchestre [AuthService] et la persistance locale de la session.
///
/// La session est sauvegardée dans [LocalStorageService] pour survivre
/// aux redémarrages de l'app (token ou données utilisateur sérialisées).
/// Quand l'API Rust sera disponible, le token JWT sera stocké ici.
class AuthRepository {
  final AuthService _service;
  final LocalStorageService _storage;

  AuthUser? _cachedUser;

  AuthRepository({
    required AuthService service,
    required LocalStorageService storage,
  }) : _service = service,
       _storage = storage;

  AuthUser? get currentUser => _cachedUser;
  bool get isLoggedIn => _cachedUser != null;

  /// Restaure la session persistée au démarrage de l'app.
  Future<void> init() async {
    final saved = _storage.readSession();
    if (saved != null) {
      _cachedUser = AuthUser.fromJson(saved);
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _service.login(email: email, password: password);
    if (result.isSuccess) {
      _cachedUser = result.user;
      await _storage.writeSession(result.user!.toJson());
    }
    return result;
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final result = await _service.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    if (result.isSuccess) {
      _cachedUser = result.user;
      await _storage.writeSession(result.user!.toJson());
    }
    return result;
  }

  Future<void> logout() async {
    await _service.logout();
    _cachedUser = null;
    await _storage.clearSession();
  }
}
