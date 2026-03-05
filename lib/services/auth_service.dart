import 'package:snacky/models/auth_user.dart';

/// Résultat d'une opération d'authentification.
/// Encapsule soit un utilisateur, soit un message d'erreur lisible.
class AuthResult {
  final AuthUser? user;
  final String? error;

  const AuthResult.success(this.user) : error = null;
  const AuthResult.failure(this.error) : user = null;

  bool get isSuccess => user != null;
}

/// Contrat abstrait du service d'authentification.
///
/// Pour brancher l'API Rust :
///   1. Crée `lib/services/api_auth_service.dart` qui `extends AuthService`
///   2. Remplace `MockAuthService` par `ApiAuthService` dans `main.dart`
///   C'est tout.
abstract class AuthService {
  /// Connecte un utilisateur existant.
  Future<AuthResult> login({required String email, required String password});

  /// Crée un nouveau compte.
  Future<AuthResult> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// Déconnecte l'utilisateur courant.
  Future<void> logout();

  /// Retourne l'utilisateur actuellement connecté (null si aucun).
  Future<AuthUser?> getCurrentUser();
}
