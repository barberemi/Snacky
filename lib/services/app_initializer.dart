import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snacky/repositories/article_repository.dart';
import 'package:snacky/repositories/auth_repository.dart';
import 'package:snacky/repositories/favorite_repository.dart';
import 'package:snacky/repositories/tag_repository.dart';
import 'package:snacky/screens/onboarding_screen.dart';
import 'package:snacky/services/local_storage_service.dart';
import 'package:snacky/services/mock_auth_service.dart';
import 'package:snacky/services/mock_article_service.dart';

/// Résultat du bootstrap : toutes les dépendances initialisées + état de démarrage.
class AppBootstrap {
  final ArticleRepository articleRepo;
  final FavoriteRepository favoriteRepo;
  final TagRepository tagRepo;
  final AuthRepository authRepo;
  final bool showOnboarding;

  const AppBootstrap({
    required this.articleRepo,
    required this.favoriteRepo,
    required this.tagRepo,
    required this.authRepo,
    required this.showOnboarding,
  });
}

/// Responsabilité unique : initialiser toutes les dépendances de l'application
/// au démarrage, dans le bon ordre.
///
/// Avantages :
/// - [main.dart] reste minimal et lisible
/// - Facile à tester (mock les services)
/// - Un seul endroit à modifier pour swapper Mock → API
class AppInitializer {
  /// Lance l'initialisation complète et retourne un [AppBootstrap].
  ///
  /// Ordre :
  /// 1. [LocalStorageService] (SharedPreferences)
  /// 2. Repositories en parallèle
  /// 3. Lecture de l'état d'onboarding
  static Future<AppBootstrap> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Stockage bas niveau
    final storage = await LocalStorageService.init();

    // 2. Instanciation des repositories
    //    → Swapper MockArticleService par ApiArticleService ici quand l'API est prête
    final articleRepo = ArticleRepository(
      storage,
      articleService: MockArticleService(),
    );
    final favoriteRepo = FavoriteRepository(storage);
    final tagRepo = TagRepository(
      storage,
      articleService: MockArticleService(),
    );
    final authRepo = AuthRepository(
      service: MockAuthService(),
      storage: storage,
    );

    // 3. Init parallèle des repositories qui lisent le stockage local
    await Future.wait([favoriteRepo.init(), tagRepo.init(), authRepo.init()]);

    // 4. État de l'onboarding
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(kOnboardingDoneKey) ?? false;

    return AppBootstrap(
      articleRepo: articleRepo,
      favoriteRepo: favoriteRepo,
      tagRepo: tagRepo,
      authRepo: authRepo,
      showOnboarding: !onboardingDone,
    );
  }
}
