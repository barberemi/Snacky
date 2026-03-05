import 'package:flutter/material.dart';
import 'package:snacky/repositories/auth_repository.dart';
import 'package:snacky/widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  final AuthRepository authRepo;

  const RegisterScreen({super.key, required this.authRepo});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await widget.authRepo.register(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      displayName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      Navigator.of(context).pop(result.user);
    } else {
      setState(() => _errorMessage = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ── En-tête ───────────────────────────────────────────────
                Text(
                  'Créer un compte',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kBrandColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rejoins la communauté Snacky 🍿',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 36),

                // ── Pseudo (optionnel) ────────────────────────────────────
                SnackyField(
                  controller: _nameCtrl,
                  label: 'Pseudo (optionnel)',
                  hint: 'Comment on t\'appelle ?',
                  icon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // ── Email ─────────────────────────────────────────────────
                SnackyField(
                  controller: _emailCtrl,
                  label: 'Adresse email',
                  hint: 'toi@exemple.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),

                // ── Mot de passe ──────────────────────────────────────────
                SnackyField(
                  controller: _passwordCtrl,
                  label: 'Mot de passe',
                  hint: 'Au moins 8 caractères',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: kBrandColor,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),

                // ── Confirmation ──────────────────────────────────────────
                SnackyField(
                  controller: _confirmCtrl,
                  label: 'Confirmer le mot de passe',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: kBrandColor,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) => v != _passwordCtrl.text
                      ? 'Les mots de passe ne correspondent pas'
                      : null,
                ),
                const SizedBox(height: 24),

                // ── Erreur globale ────────────────────────────────────────
                if (_errorMessage != null)
                  AuthErrorBanner(message: _errorMessage!),

                const SizedBox(height: 24),

                // ── Bouton inscription ────────────────────────────────────
                SnackyButton(
                  label: 'Créer mon compte',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 32),

                // ── Lien retour connexion ─────────────────────────────────
                Center(
                  child: AuthLinkText(
                    prefixText: 'Déjà un compte ? ',
                    linkText: 'Se connecter',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email requis';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Email invalide';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    return null;
  }
}
