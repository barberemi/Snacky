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
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snacky',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      home: SearchScreen(
        articleRepo: articleRepo,
        favoriteRepo: favoriteRepo,
        tagRepo: tagRepo,
      ),
    ),
  );
}
