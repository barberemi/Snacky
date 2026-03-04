import 'package:flutter/material.dart';
import 'package:snacky/models/article.dart';
import 'package:snacky/repositories/article_repository.dart';
import 'package:snacky/repositories/tag_repository.dart';
import 'package:snacky/repositories/favorite_repository.dart';
import '../widgets/tag_selector.dart';
import '../widgets/news_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // --- REPOSITORIES ---
  final ArticleRepository _articleRepo = ArticleRepository();
  final TagRepository _tagRepo = TagRepository();
  final FavoriteRepository _favoriteRepo = FavoriteRepository();

  // --- ÉTAT ---
  String _selectedTag = "Tout";
  List<String> _tags = ["Tout", "Favoris"];
  List<Article> _articles = [];
  bool _isLoading = true;

  // Identifiant utilisateur simulé (sera remplacé par un vrai auth plus tard)
  final String _userId = 'user_1';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Chargement initial : tags + tous les articles
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // Charge tags et articles en parallèle
    final results = await Future.wait([
      _tagRepo.getTags(userId: _userId),
      _articleRepo.getAllArticles(userId: _userId),
    ]);

    setState(() {
      _tags = results[0] as List<String>;
      _articles = results[1] as List<Article>;
      _isLoading = false;
    });
  }

  /// Appelé quand l'utilisateur change de tag
  Future<void> _onTagChanged(String tag) async {
    setState(() {
      _selectedTag = tag;
    });

    // Pour "Tout" et "Favoris", pas besoin de fetch l'API
    if (tag == "Tout" || tag == "Favoris") return;

    // Sinon, on charge les articles de ce tag depuis l'API
    setState(() => _isLoading = true);
    final articles = await _articleRepo.getArticlesByTag(
      userId: _userId,
      tag: tag,
    );
    setState(() {
      _articles = articles;
      _isLoading = false;
    });
  }

  void _toggleFavorite(Article article) {
    setState(() {
      _favoriteRepo.toggleFavorite(article);
    });
  }

  void _onSearch() => print("Recherche pour : ${_searchController.text}");

  @override
  Widget build(BuildContext context) {
    // --- LOGIQUE DE FILTRAGE ---
    List<Article> filteredNews;
    if (_selectedTag == "Favoris") {
      filteredNews = _favoriteRepo.getFavorites();
    } else if (_selectedTag == "Tout") {
      // En mode "Tout", on recharge tous les articles en cache
      filteredNews = _articleRepo.getCachedArticles();
    } else {
      filteredNews = _articles;
    }

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
                  color: Color(0xFF3F51B5),
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
                onTagSelected: _onTagChanged,
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
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3F51B5),
                        ),
                      )
                    : filteredNews.isEmpty
                    ? const Center(
                        child: Text("Aucun snack trouvé pour ce thème 🍪"),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: ListView.builder(
                          key: ValueKey(_selectedTag),
                          itemCount: filteredNews.length,
                          padding: const EdgeInsets.only(bottom: 20),
                          itemBuilder: (context, index) {
                            final article = filteredNews[index];
                            return NewsCard(
                              key: ValueKey(article.id),
                              article: article,
                              isFavorite: _favoriteRepo.isFavorite(article),
                              onFavoriteToggle: () => _toggleFavorite(article),
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
