import 'package:flutter/material.dart';
import 'package:snacky/models/article.dart';
import '../widgets/tag_selector.dart';
import '../widgets/news_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTag = "Tout";

  final List<String> _tags = [
    "Tout",
    "PHP",
    "Batman",
    "Flutter",
    "IA",
    "Figurines",
  ];

  final List<Article> _allNews = [
    Article(
      title: "PHP 8.4 : Les nouveautés arrivent",
      source: "PHP.net",
      time: "2h",
      description:
          "Cette version apporte les 'Property Hooks' et une meilleure gestion de la mémoire pour les applications haute performance.",
      url: "https://www.php.net",
      image:
          "https://picperf.io/https://laravelnews.s3.amazonaws.com/featured-images/php-8.5-coming-soon-featured.jpg",
    ),
    Article(
      title: "Batman: Arkham Shadow annoncé !",
      source: "DC Comics",
      time: "5h",
      description:
          "Le Chevalier Noir revient dans une aventure inédite en VR. Préparez-vous à explorer Gotham comme jamais auparavant.",
      url: "https://www.php.net",
      image:
          "https://picperf.io/https://cdn.gamekult.com/optim/images/news/30/3050866091/12-ans-apres-batman-arkham-origins-est-toujours-le-meilleur-episode-de-la-franchise-86354726__930_300__0-69-1920-688.jpg",
    ),
    Article(
      title: "Apprendre Flutter en 2026",
      source: "Medium",
      time: "1j",
      description: "Lorem ipsum ipsum nobel bla",
      url: "https://www.php.net",
      image:
          "https://picperf.io/https://cdn.zonebourse.com/static/resize/768/432//images/reuters/2025-08/2025-08-07T202136Z_1_LYNXMPEL76145_RTROPTP_4_FLUTTER-RESULTS.JPG",
    ),
    Article(
      title: "Les meilleures figurines Hot Toys",
      source: "Collector",
      time: "3h",
      description: "Lorem ipsum ipsum nobel bla.",
      url: "https://www.php.net",
      image:
          "https://picperf.io/https://www.journaldugeek.com/app/uploads/2025/09/HP-1-2025-09-25T123515.174.jpeg",
    ),
    Article(
      title: "Laravel vs Symfony en 2026",
      source: "Dev.to",
      time: "6h",
      description: "Lorem ipsum ipsum nobel bla",
      url: "https://www.php.net",
      image:
          "https://picperf.io/https://www.presse-citron.net/app/uploads/2024/06/Meilleur-hebergement-web-Laravel-880x587.jpg",
    ),
  ];

  void _onSearch() => print("Recherche pour : ${_searchController.text}");

  @override
  Widget build(BuildContext context) {
    // --- LOGIQUE DE FILTRAGE ---
    // On filtre la liste ici : si "Tout" on prend tout, sinon on cherche le tag dans le titre
    final filteredNews = _allNews.where((article) {
      if (_selectedTag == "Tout") return true;
      return article.title!.toLowerCase().contains(_selectedTag.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Snacky 🍿",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F51B5), // Votre couleur fétiche
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Tes thèmes favoris",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),

              TagSelector(
                tags: _tags,
                selectedTag: _selectedTag,
                onTagSelected: (tag) {
                  setState(() {
                    _selectedTag = tag;
                    // On ne met pas forcément à jour le contrôleur de recherche
                    // si on veut que la barre reste libre
                  });
                },
              ),

              const SizedBox(height: 30),
              _buildSearchField(),
              const SizedBox(height: 20),
              _buildSearchButton(),
              const SizedBox(height: 30),

              const Text(
                "Derniers Snacks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Liste filtrée
              Expanded(
                child: filteredNews.isEmpty
                    ? const Center(
                        child: Text("Aucun snack trouvé pour ce thème 🍪"),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: ListView.builder(
                          // <--- PLUS D'EXPANDED ICI
                          key: ValueKey(
                            _selectedTag,
                          ), // Recrée toute la liste lors d'un changement de tag
                          itemCount: filteredNews.length,
                          padding: const EdgeInsets.only(bottom: 20),
                          itemBuilder: (context, index) {
                            final article = filteredNews[index];
                            return NewsCard(
                              // La Key force Flutter à remettre l'état à zéro si la news change
                              key: ValueKey(article.title),
                              article: article,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Petites méthodes privées pour garder le build() propre
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Ton sujet de veille...",
        prefixIcon: const Icon(Icons.search, color: Color(0xFF3F51B5)),
        filled: true,
        fillColor: const Color(0xFF3F51B5).withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _onSearch,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3F51B5),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: const Text(
        "Chercher",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
