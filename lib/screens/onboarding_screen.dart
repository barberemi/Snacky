import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snacky/repositories/article_repository.dart';
import 'package:snacky/repositories/auth_repository.dart';
import 'package:snacky/repositories/favorite_repository.dart';
import 'package:snacky/repositories/tag_repository.dart';
import 'package:snacky/screens/search_screen.dart';

/// Clé SharedPreferences pour mémoriser que l'onboarding a été vu.
const String kOnboardingDoneKey = 'onboarding_done';

// ─────────────────────────────────────────────────────────────
// Données des slides
// ─────────────────────────────────────────────────────────────
class _Slide {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _Slide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

const _slides = [
  _Slide(
    icon: Icons.auto_awesome_rounded,
    title: 'Bienvenue sur Snacky 🍿',
    subtitle:
        "L'actu en format snack.\nRapide, clair, sans te noyer dans l'information.",
    color: Color(0xFF3F51B5),
  ),
  _Slide(
    icon: Icons.label_important_rounded,
    title: 'Tes thèmes de veille',
    subtitle:
        'Ajoute des tags comme "IA", "Climat" ou "Sport".\nSnacky te trouve les articles qui t\'intéressent vraiment.',
    color: Color(0xFF7B61FF),
  ),
  _Slide(
    icon: Icons.verified_rounded,
    title: 'La fiabilité, toujours visible',
    subtitle:
        'Chaque article est noté : ✅ Fiable, ⚠️ Moyen ou 🔴 Prudence.\nTu sais toujours à quoi t\'en tenir.',
    color: Color(0xFF2E7D32),
  ),
];

// ─────────────────────────────────────────────────────────────
// Widget principal
// ─────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  final ArticleRepository articleRepo;
  final FavoriteRepository favoriteRepo;
  final TagRepository tagRepo;
  final AuthRepository authRepo;

  const OnboardingScreen({
    super.key,
    required this.articleRepo,
    required this.favoriteRepo,
    required this.tagRepo,
    required this.authRepo,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingDoneKey, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => SearchScreen(
          articleRepo: widget.articleRepo,
          favoriteRepo: widget.favoriteRepo,
          tagRepo: widget.tagRepo,
          authRepo: widget.authRepo,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slide = _slides[_currentPage];
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Bouton "Passer" ──────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: isLast ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 16),
                  child: TextButton(
                    onPressed: isLast ? null : _finish,
                    child: Text(
                      'Passer',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── PageView ─────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) =>
                    _SlidePage(slide: _slides[index], isDark: isDark),
              ),
            ),

            // ── Indicateurs de points ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? slide.color
                        : slide.color.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Bouton Suivant / Commencer ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: slide.color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      isLast ? 'C\'est parti ! 🚀' : 'Suivant',
                      key: ValueKey(isLast),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Un slide individuel
// ─────────────────────────────────────────────────────────────
class _SlidePage extends StatefulWidget {
  final _Slide slide;
  final bool isDark;

  const _SlidePage({required this.slide, required this.isDark});

  @override
  State<_SlidePage> createState() => _SlidePageState();
}

class _SlidePageState extends State<_SlidePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.slide;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône dans un cercle coloré
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: s.color.withOpacity(widget.isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(s.icon, size: 56, color: s.color),
              ),
              const SizedBox(height: 40),

              // Titre
              Text(
                s.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Sous-titre
              Text(
                s.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
