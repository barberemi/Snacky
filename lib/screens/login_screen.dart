import 'package:flutter/material.dart';
import 'package:snacky/repositories/auth_repository.dart';
import 'package:snacky/screens/register_screen.dart';
import 'package:snacky/widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  final AuthRepository authRepo;

  const LoginScreen({super.key, required this.authRepo});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await widget.authRepo.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
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
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
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
                  'Connexion',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: kBrandColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bon retour sur Snacky 🍿',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 36),

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
                  hint: '••••••••',
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
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
                ),
                const SizedBox(height: 24),

                // ── Erreur globale ────────────────────────────────────────
                if (_errorMessage != null)
                  AuthErrorBanner(message: _errorMessage!),

                const SizedBox(height: 24),

                // ── Bouton connexion ──────────────────────────────────────
                SnackyButton(
                  label: 'Se connecter',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 32),

                // ── Lien vers inscription ─────────────────────────────────
                Center(
                  child: AuthLinkText(
                    prefixText: 'Pas encore de compte ? ',
                    linkText: 'Créer un compte',
                    onTap: () async {
                      final user = await Navigator.of(context).push<dynamic>(
                        MaterialPageRoute(
                          builder: (_) =>
                              RegisterScreen(authRepo: widget.authRepo),
                        ),
                      );
                      if (user != null && mounted) {
                        Navigator.of(context).pop(user);
                      }
                    },
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
}
