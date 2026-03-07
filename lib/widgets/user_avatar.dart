import 'package:flutter/material.dart';
import 'package:snacky/models/auth_user.dart';

/// Avatar cliquable affiché dans le header quand l'utilisateur est connecté.
/// Affiche l'initiale du nom, ouvre un menu de déconnexion au tap.
class UserAvatar extends StatelessWidget {
  final AuthUser user;
  final VoidCallback onLogout;

  const UserAvatar({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Tooltip(
        message: user.name,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF3F51B5),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromLTRB(
      box.localToGlobal(Offset.zero).dx,
      box.localToGlobal(Offset.zero).dy + box.size.height,
      box.localToGlobal(Offset.zero).dx + box.size.width,
      0,
    );
    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          value: 'name',
          enabled: false,
          child: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Se déconnecter', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'logout') onLogout();
    });
  }
}
