import 'package:flutter/material.dart';
import 'package:snacky/main.dart';
import 'package:snacky/models/article.dart';
import 'package:snacky/models/auth_user.dart';
import 'package:snacky/repositories/article_repository.dart';
import 'package:snacky/repositories/auth_repository.dart';
import 'package:snacky/repositories/tag_repository.dart';
import 'package:snacky/repositories/favorite_repository.dart';
import 'package:snacky/screens/login_screen.dart';
import '../widgets/tag_selector.dart';
import '../widgets/news_card.dart';

class SearchScreen extends StatefulWidget {
  final ArticleRepository articleRepo;
  final FavoriteRepository favoriteRepo;
  final TagRepository tagRepo;
  final AuthRepository authRepo;

  const SearchScreen({
    super.key,
    required this.articleRepo,
    required this.favoriteRepo,
    required this.tagRepo,
    required this.authRepo,
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
  String? _searchError;

  // Utilisateur courant (null = non connecté)
  AuthUser? get _currentUser => widget.authRepo.currentUser;

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

  /// Validation en temps réel : max 3 mots
  void _onSearchTextChanged() {
    final wordCount = _searchController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    setState(() {
      if (wordCount > 3) {
        _searchError = 'Maximum 3 mots (ce sera ton tag de veille)';
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

    // Validation : max 3 mots
    final wordCount = input
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    if (wordCount > 3) {
      setState(
        () => _searchError = 'Maximum 3 mots (ce sera ton tag de veille)',
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

  /// Supprime un tag personnalisé et revient sur "Tout"
  Future<void> _onTagRemoved(String tag) async {
    await widget.tagRepo.removeTag(tag);
    final updatedTags = await widget.tagRepo.getTags(userId: _userId);
    setState(() {
      _tags = updatedTags;
      if (_selectedTag == tag) _selectedTag = "Tout";
    });
  }

  /// Ouvre la page de connexion et met à jour l'état si l'utilisateur
  /// s'est connecté ou inscrit.
  Future<void> _openLogin() async {
    await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (_) => LoginScreen(authRepo: widget.authRepo)),
    );
    // Rafraîchit le header quel que soit le résultat
    setState(() {});
  }

  Future<void> _logout() async {
    await widget.authRepo.logout();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    List<Article> filteredNews;
    if (_selectedTag == "Favoris") {
      filteredNews = widget.favoriteRepo.getFavorites();
    } else if (_selectedTag == "Tout") {
      filteredNews = widget.articleRepo.getCachedArticles();
    } else {
      filteredNews = _articles;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Snacky 🍿",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5),
                    ),
                  ),
                  Row(
                    children: [
                      // ── Bouton dark/light ───────────────────────────────
                      IconButton(
                        tooltip: SnackyApp.of(context).isDark
                            ? 'Passer en mode clair'
                            : 'Passer en mode sombre',
                        icon: Icon(
                          SnackyApp.of(context).isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: const Color(0xFF3F51B5),
                          size: 26,
                        ),
                        onPressed: () => SnackyApp.of(context).toggleTheme(),
                      ),
                      // ── Bouton profil / connexion ───────────────────────
                      if (user == null)
                        IconButton(
                          tooltip: 'Se connecter',
                          icon: const Icon(
                            Icons.account_circle_outlined,
                            color: Color(0xFF3F51B5),
                            size: 26,
                          ),
                          onPressed: _openLogin,
                        )
                      else
                        _UserAvatar(user: user, onLogout: _logout),
                    ],
                  ),
                ],
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
                onTagRemoved: _onTagRemoved,
                favoritesCount: widget.favoriteRepo.getFavorites().length,
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
                            return _AnimatedCard(
                              index: index,
                              child: NewsCard(
                                key: ValueKey(article.id),
                                article: article,
                                isFavorite: widget.favoriteRepo.isFavorite(
                                  article,
                                ),
                                onFavoriteToggle: () =>
                                    _toggleFavorite(article),
                              ),
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
        hintText: "Ajoute un thème de veille...",
        prefixIcon: const Icon(
          Icons.add_circle_outline,
          color: Color(0xFF3F51B5),
        ),
        errorText: _searchError,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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

/// Avatar cliquable affiché quand l'utilisateur est connecté.
/// Un appui long (ou un tap) ouvre un menu avec l'option de déconnexion.
class _UserAvatar extends StatelessWidget {
  final AuthUser user;
  final VoidCallback onLogout;

  const _UserAvatar({required this.user, required this.onLogout});

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
    // ...existing code...
  }
}

/// Widget qui anime l'entrée d'une card avec un fade + slide en cascade.
class _AnimatedCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedCard({required this.index, required this.child});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Délai en cascade : chaque card attend 50ms × son index (max 400ms)
    final delay = Duration(milliseconds: (widget.index * 50).clamp(0, 400));
    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
