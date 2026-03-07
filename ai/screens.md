# Screens

## `SearchScreen` — `screens/search_screen.dart` (~740 lignes)
Écran principal. Reçoit les 4 repositories en constructeur.

**State principal :**
| Variable | Rôle |
|---|---|
| `_selectedTag` | Tag actif ("Tout", "Favoris", ou un tag perso) |
| `_tags` | Liste complète des tags (chargée depuis `TagRepository`) |
| `_articles` | Articles du tag actif (chargés depuis `ArticleRepository`) |
| `_isLoading` | Affiche `NewsListSkeleton` si true |
| `_sortOrder` | `_SortOrder.recent` ou `_SortOrder.confidence` |
| `_isScrolled` | Header compact si scroll > 10px |
| `_userId` | Hardcodé `'user_1'` (à remplacer par `authRepo.currentUser?.id`) |

**Flux de données :**
1. `initState` → `_loadInitialData` → charge tags + articles en parallèle
2. Tap sur un tag → `_onTagChanged` → refetch articles si tag perso
3. Champ de recherche → `_onAddTag` → ajoute tag + charge ses articles
4. Tap étoile → `_toggleFavorite` → `FavoriteRepository.toggleFavorite`

**Widgets locaux privés (légitimes) :**
- `_SortOrder` : enum tri récent/confiance
- `_EmptyState` : empty state illustré (tag sans articles ou favoris vides)
- `_AnimatedCard` : fade + slide en cascade à l'entrée (délai = `index * 50ms`, max 400ms)
- `_SortButton` : bouton bascule récent ↔ fiabilité

**Widgets partagés utilisés :**
`TagSelector`, `NewsCard`, `NewsListSkeleton`, `UserAvatar`

---

## `ArticleDetailScreen` — `screens/article_detail_screen.dart` (~315 lignes)
Page détail avec `SliverAppBar` + image Hero.

**Props :** `article, isFavorite, onFavoriteToggle`  
**Hero tag :** `'article_image_${article.id}'` (synchronisé avec `NewsCard`)  
**Actions AppBar :** favoris + partage (`share_plus`)  
**Widgets partagés utilisés :** `ConfidenceDetail` (confidence + reason)  
**⚠️ Temps de lecture** : calculé par `ArticleFormatterService.readingTimeLabel()` mais **pas encore affiché** — à ajouter après le titre ou dans le row source/time.

---

## `OnboardingScreen` — `screens/onboarding_screen.dart` (~315 lignes)
3 slides (`PageView`). Affiché uniquement au premier lancement.  
Persistance : `SharedPreferences.setBool('onboarding_done', true)` à la fin.  
Navigates vers `SearchScreen` via `pushReplacement` + `FadeTransition`.  
Données des slides dans la constante `_slides` (liste de `_Slide`).

---

## `LoginScreen` — `screens/login_screen.dart`
Formulaire email/password avec `Form` + `GlobalKey`.  
Utilise `SnackyField`, `SnackyButton`, `AuthErrorBanner`, `AuthLinkText`.  
Succès → `Navigator.pop(result.user)` (SearchScreen rafraîchit son header).

---

## `RegisterScreen` — `screens/register_screen.dart`
Même structure que `LoginScreen`. Champ displayName optionnel.  
Naviguée depuis `LoginScreen` via `AuthLinkText`.
