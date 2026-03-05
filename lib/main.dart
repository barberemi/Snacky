import 'package:flutter/material.dart';
import 'package:snacky/services/local_storage_service.dart';
import 'package:snacky/repositories/article_repository.dart';
import 'package:snacky/repositories/favorite_repository.dart';
import 'package:snacky/repositories/tag_repository.dart';
import 'package:snacky/screens/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation du stockage persistant
  final storage = await LocalStorageService.init();
  final articleRepo = ArticleRepository(storage);
  final favoriteRepo = FavoriteRepository(storage);
  final tagRepo = TagRepository(storage);

  // Charger les favoris et les tags persistés avant le démarrage de l'UI
  await Future.wait([favoriteRepo.init(), tagRepo.init()]);

  runApp(
    SnackyApp(
      articleRepo: articleRepo,
      favoriteRepo: favoriteRepo,
      tagRepo: tagRepo,
    ),
  );
}

/// Widget racine avec gestion du thème clair/sombre.
class SnackyApp extends StatefulWidget {
  final ArticleRepository articleRepo;
  final FavoriteRepository favoriteRepo;
  final TagRepository tagRepo;

  const SnackyApp({
    super.key,
    required this.articleRepo,
    required this.favoriteRepo,
    required this.tagRepo,
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
      home: SearchScreen(
        articleRepo: widget.articleRepo,
        favoriteRepo: widget.favoriteRepo,
        tagRepo: widget.tagRepo,
      ),
    );
  }
}
