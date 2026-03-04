import '../models/article.dart';

/// Service qui simule les appels à l'API Rust.
/// Quand l'API sera prête, il suffira de remplacer ce fichier
/// par un vrai client HTTP (dio, http, etc.).
class MockApiService {
  /// Simule un délai réseau
  Future<T> _simulateNetwork<T>(T data) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return data;
  }

  /// GET /tags?user_id=USER_ID
  /// Retourne les tags de l'utilisateur
  Future<List<String>> fetchTags({required String userId}) async {
    // Données mockées par utilisateur
    final mockTags = {
      'user_1': ['PHP', 'Batman', 'Flutter', 'IA', 'Figurines'],
      'user_2': ['Python', 'Marvel', 'React'],
    };
    return _simulateNetwork(mockTags[userId] ?? ['Flutter', 'IA']);
  }

  /// GET /articles?user_id=USER_ID&tag=TAG
  /// Retourne les articles pour un tag donné
  Future<List<Article>> fetchArticlesByTag({
    required String userId,
    required String tag,
  }) async {
    // Base d'articles mockés
    final allArticles = _getMockArticles();

    // Filtrage par tag (insensible à la casse)
    final filtered = allArticles
        .where((a) => a.tags.any((t) => t.toLowerCase() == tag.toLowerCase()))
        .toList();

    return _simulateNetwork(filtered);
  }

  /// GET /articles?user_id=USER_ID
  /// Retourne tous les articles de l'utilisateur
  Future<List<Article>> fetchAllArticles({required String userId}) async {
    return _simulateNetwork(_getMockArticles());
  }

  /// Données mockées — à remplacer par les vrais appels API
  List<Article> _getMockArticles() {
    return [
      Article(
        id: '1',
        title: 'PHP 8.4 : Les nouveautés arrivent',
        source: 'PHP.net',
        time: '3h',
        description:
            "Cette version apporte les 'Property Hooks' et une meilleure gestion de la mémoire pour les applications haute performance.",
        url: 'https://www.php.net',
        image:
            'https://picperf.io/https://laravelnews.s3.amazonaws.com/featured-images/php-8.5-coming-soon-featured.jpg',
        tags: ['PHP'],
      ),
      Article(
        id: '2',
        title: 'Batman: Arkham Shadow annoncé !',
        source: 'DC Comics',
        time: '5h',
        description:
            'Le Chevalier Noir revient dans une aventure inédite en VR. Préparez-vous à explorer Gotham comme jamais auparavant.',
        url: 'https://www.dccomics.com',
        image:
            'https://picperf.io/https://cdn.gamekult.com/optim/images/news/30/3050866091/12-ans-apres-batman-arkham-origins-est-toujours-le-meilleur-episode-de-la-franchise-86354726__930_300__0-69-1920-688.jpg',
        tags: ['Batman'],
      ),
      Article(
        id: '3',
        title: 'Apprendre Flutter en 2026',
        source: 'Medium',
        time: '1j',
        description:
            'Un guide complet pour débuter avec Flutter et créer des applications multiplateforme modernes.',
        url: 'https://medium.com',
        image:
            'https://picperf.io/https://cdn.zonebourse.com/static/resize/768/432//images/reuters/2025-08/2025-08-07T202136Z_1_LYNXMPEL76145_RTROPTP_4_FLUTTER-RESULTS.JPG',
        tags: ['Flutter'],
      ),
      Article(
        id: '4',
        title: 'Les meilleures figurines Hot Toys',
        source: 'Collector',
        time: '3h',
        description:
            'Notre sélection des figurines Hot Toys les plus impressionnantes de l\'année.',
        url: 'https://www.collector.com',
        image:
            'https://picperf.io/https://www.journaldugeek.com/app/uploads/2025/09/HP-1-2025-09-25T123515.174.jpeg',
        tags: ['Figurines'],
      ),
      Article(
        id: '5',
        title: 'Laravel vs Symfony en 2026',
        source: 'Dev.to',
        time: '6h',
        description:
            'Comparatif détaillé des deux frameworks PHP les plus populaires en 2026.',
        url: 'https://dev.to',
        image:
            'https://picperf.io/https://www.presse-citron.net/app/uploads/2024/06/Meilleur-hebergement-web-Laravel-880x587.jpg',
        tags: ['PHP'],
      ),
      Article(
        id: '6',
        title: "L'IA générative transforme le développement",
        source: 'TechCrunch',
        time: '2h',
        description:
            'Comment les outils d\'IA changent la façon dont les développeurs écrivent du code au quotidien.',
        url: 'https://techcrunch.com',
        image: null,
        tags: ['IA'],
      ),
      Article(
        id: '7',
        title: 'Batman : le nouveau film de Matt Reeves',
        source: 'Allociné',
        time: '12h',
        description:
            'Matt Reeves confirme la suite de The Batman avec Robert Pattinson pour 2027.',
        url: 'https://www.allocine.fr',
        image: null,
        tags: ['Batman'],
      ),
      Article(
        id: '8',
        title: 'Flutter 4.0 : les nouveautés majeures',
        source: 'Flutter.dev',
        time: '4h',
        description:
            'Tour d\'horizon des nouvelles fonctionnalités de Flutter 4.0 et de Dart 4.',
        url: 'https://flutter.dev',
        image: null,
        tags: ['Flutter'],
      ),
    ];
  }
}
