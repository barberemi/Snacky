/// Représente un utilisateur authentifié.
/// Ce modèle est volontairement minimal — il sera enrichi
/// avec les champs retournés par l'API Rust.
class AuthUser {
  final String id;
  final String email;
  final String? displayName;

  const AuthUser({required this.id, required this.email, this.displayName});

  /// Nom affiché : préfère displayName, sinon la partie locale de l'email.
  String get name => displayName ?? email.split('@').first;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['display_name'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
  };
}
