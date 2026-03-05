import 'package:snacky/models/auth_user.dart';
import 'package:snacky/services/auth_service.dart';

/// Implémentation mock de [AuthService].
///
/// Simule un backend en mémoire : les comptes créés persistent
/// uniquement le temps de la session (redémarrage = reset).
///
/// À remplacer par `ApiAuthService` quand l'API Rust sera prête.
class MockAuthService extends AuthService {
  // Stockage en mémoire : email → {password, user}
  final Map<String, _MockAccount> _accounts = {};
  AuthUser? _currentUser;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Simule la latence réseau
    await Future.delayed(const Duration(milliseconds: 600));

    final account = _accounts[email.toLowerCase()];
    if (account == null) {
      return const AuthResult.failure('Aucun compte trouvé pour cet email.');
    }
    if (account.password != password) {
      return const AuthResult.failure('Mot de passe incorrect.');
    }

    _currentUser = account.user;
    return AuthResult.success(_currentUser);
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final key = email.toLowerCase();
    if (_accounts.containsKey(key)) {
      return const AuthResult.failure('Un compte existe déjà pour cet email.');
    }

    final user = AuthUser(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
    );
    _accounts[key] = _MockAccount(password: password, user: user);
    _currentUser = user;
    return AuthResult.success(_currentUser);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<AuthUser?> getCurrentUser() async => _currentUser;
}

class _MockAccount {
  final String password;
  final AuthUser user;
  const _MockAccount({required this.password, required this.user});
}
