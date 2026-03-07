import 'package:flutter/material.dart';
import 'package:snacky/repositories/article_repository.dart';
import 'package:snacky/repositories/auth_repository.dart';
import 'package:snacky/repositories/favorite_repository.dart';
import 'package:snacky/repositories/tag_repository.dart';
import 'package:snacky/screens/search_screen.dart';
import 'package:snacky/screens/onboarding_screen.dart';
import 'package:snacky/services/app_initializer.dart';

void main() async {
  final bootstrap = await AppInitializer.init();

  runApp(
    SnackyApp(
      articleRepo: bootstrap.articleRepo,
      favoriteRepo: bootstrap.favoriteRepo,
      tagRepo: bootstrap.tagRepo,
      authRepo: bootstrap.authRepo,
      showOnboarding: bootstrap.showOnboarding,
    ),
  );
}

/// Widget racine avec gestion du thème clair/sombre.
class SnackyApp extends StatefulWidget {
  final ArticleRepository articleRepo;
  final FavoriteRepository favoriteRepo;
  final TagRepository tagRepo;
  final AuthRepository authRepo;
  final bool showOnboarding;

  const SnackyApp({
    super.key,
    required this.articleRepo,
    required this.favoriteRepo,
    required this.tagRepo,
    required this.authRepo,
    this.showOnboarding = false,
  });

  @override
  State<SnackyApp> createState() => _SnackyAppState();

  /// Accès depuis n'importe quel descendant.
  static _SnackyAppState of(BuildContext context) {
    return context.findAncestorStateOfType<_SnackyAppState>()!;
  }
}

class _SnackyAppState extends State<SnackyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF3F51B5);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snacky',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      home: widget.showOnboarding
          ? OnboardingScreen(
              articleRepo: widget.articleRepo,
              favoriteRepo: widget.favoriteRepo,
              tagRepo: widget.tagRepo,
              authRepo: widget.authRepo,
            )
          : SearchScreen(
              articleRepo: widget.articleRepo,
              favoriteRepo: widget.favoriteRepo,
              tagRepo: widget.tagRepo,
              authRepo: widget.authRepo,
            ),
    );
  }
}
