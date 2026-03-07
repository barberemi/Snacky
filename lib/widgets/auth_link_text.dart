import 'package:flutter/material.dart';
import 'package:snacky/widgets/auth_widgets.dart';

/// Ligne de texte avec un lien cliquable et soulignement au survol.
/// Ex : "Pas encore de compte ? S'inscrire"
/// Utilisé dans [LoginScreen] et [RegisterScreen].
class AuthLinkText extends StatefulWidget {
  final String prefixText;
  final String linkText;
  final VoidCallback onTap;

  const AuthLinkText({
    super.key,
    required this.prefixText,
    required this.linkText,
    required this.onTap,
  });

  @override
  State<AuthLinkText> createState() => _AuthLinkTextState();
}

class _AuthLinkTextState extends State<AuthLinkText> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.prefixText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Text(
              widget.linkText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: kBrandColor,
                fontWeight: FontWeight.bold,
                decoration: _hovered
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: kBrandColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
