import 'package:flutter/material.dart';
import 'package:snacky/models/article.dart';
import 'package:snacky/repositories/article_repository.dart';
import 'package:snacky/repositories/tag_repository.dart';
import 'package:snacky/repositories/favorite_repository.dart';
import '../widgets/tag_selector.dart';
import '../widgets/news_card.dart';

class SearchScreen extends StatefulWidget {
  final ArticleRepository articleRepo;
  final FavoriteRepository favoriteRepo;
  final TagRepository tagRepo;

  const SearchScreen({
    super.key,
    required this.articleRepo,
    required this.favoriteRepo,
    required this.tagRepo,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedTag = "Tout";
  List<String> _tags = ["Tout", "Favoris"];
  List<Article> _articles = [];
  bool _isLoading = true;
  String? _searchError; // Message d'erreur validation du champ

  final String _userId = 'user_1';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Validation en temps réel : max 2 mots
  void _onSearchTextChanged() {
    final wordCount = _searchController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    setState(() {
      if (wordCount > 2) {
        _searchError = 'Maximum 2 mots (ce sera ton tag de veille)';
      } else {
        _searchError = null;
      }
    });
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      widget.tagRepo.getTags(userId: _userId),
      widget.articleRepo.getAllArticles(userId: _userId),
    ]);
    setState(() {
      _tags = results[0] as List<String>;
      _articles = results[1] as List<Article>;
      _isLoading = false;
    });
  }

  Future<void> _onTagChanged(String tag) async {
    setState(() => _selectedTag = tag);
    if (tag == "Tout" || tag == "Favoris") return;

    setState(() => _isLoading = true);
    final articles = await widget.articleRepo.getArticlesByTag(
      userId: _userId,
      tag: tag,
    );
    setState(() {
      _articles = articles;
      _isLoading = false;
    });
  }

  /// Valide et ajoute le tag saisi, puis charge ses articles
  Future<void> _onAddTag() async {
    final input = _searchController.text.trim();
    if (input.isEmpty) return;

    // Validation : max 2 mots
    final wordCount = input
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    if (wordCount > 2) {
      setState(
        () => _searchError = 'Maximum 2 mots (ce sera ton tag de veille)',
      );
      return;
    }

    // Capitalisation du tag (ex: "star wars" → "Star Wars")
    final tag = input
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');

    // Ajout du tag (false = déjà existant)
    final added = await widget.tagRepo.addTag(tag);

    if (!mounted) return;

    if (!added) {
      // Tag déjà existant → juste le sélectionner
      _searchController.clear();
      final updatedTags = await widget.tagRepo.getTags(userId: _userId);
      setState(() => _tags = updatedTags);
      await _onTagChanged(tag);
      return;
    }

    // Nouveau tag ajouté → récupérer la liste à jour et charger les articles
    _searchController.clear();
    final updatedTags = await widget.tagRepo.getTags(userId: _userId);
    setState(() {
      _tags = updatedTags;
      _selectedTag = tag;
      _isLoading = true;
    });

    final articles = await widget.articleRepo.getArticlesByTag(
      userId: _userId,
      tag: tag,
    );
    setState(() {
      _articles = articles;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(Article article) async {
    await widget.favoriteRepo.toggleFavorite(article);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Article> filteredNews;
    if (_selectedTag == "Favoris") {
      filteredNews = widget.favoriteRepo.getFavorites();
    } else if (_selectedTag == "Tout") {
      filteredNews = widget.articleRepo.getCachedArticles();
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
              _buildAddTagButton(),
              const SizedBox(height: 30),

              const Text(
                "Derniers Snacks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

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
                              isFavorite: widget.favoriteRepo.isFavorite(
                                article,
                              ),
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
      textCapitalization: TextCapitalization.words,
      onSubmitted: (_) => _onAddTag(),
      decoration: InputDecoration(
        hintText: "Ajoute un thème de veille (1-2 mots)...",
        prefixIcon: const Icon(
          Icons.add_circle_outline,
          color: Color(0xFF3F51B5),
        ),
        errorText: _searchError,
        filled: true,
        fillColor: const Color(0xFF3F51B5).withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildAddTagButton() {
    final hasError = _searchError != null;
    final isEmpty = _searchController.text.trim().isEmpty;
    return ElevatedButton(
      onPressed: (hasError || isEmpty) ? null : _onAddTag,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3F51B5),
        disabledBackgroundColor: Colors.grey.shade300,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: const Text(
        "Ajouter ce thème",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
