# Conventions & patterns

## Règles absolues

### Pas de doublon de widgets
Les classes privées `_Foo` dans un fichier ne doivent PAS dupliquer un widget public de `lib/widgets/`.  
Widgets publics disponibles : `TagChip`, `TagSelector`, `ConfidenceBadge`, `ConfidenceDetail`, `UserAvatar`, `NewsCard`, `NewsCardSkeleton`, `NewsListSkeleton`, `SnackyField`, `SnackyButton`, `AuthErrorBanner`, `AuthLinkText`.

### Couleur brand
Toujours `Color(0xFF3F51B5)`. Ne pas hardcoder d'autres valeurs hex pour l'indigo.  
Alias existants selon contexte : `_brand` (widgets), `_brandColor` (screens), `kBrandColor` (auth_widgets).

### Services purs
`ArticleSortService` et `ArticleFormatterService` sont sans état et sans import Flutter.  
Ne pas ajouter de dépendances Flutter dans ces fichiers.

### Repositories : pas de logique UI
Les repositories ne doivent pas importer `package:flutter`. Uniquement Dart pur + services.

---

## Patterns récurrents

### Swapper Mock → API
Dans `services/app_initializer.dart`, remplacer :
```dart
articleService: MockArticleService()   →   articleService: ApiArticleService()
service: MockAuthService()             →   service: ApiAuthService()
```
Les contrats abstraits `ArticleService` et `AuthService` définissent l'interface exacte.

### Ajouter un écran
1. Créer `lib/screens/mon_ecran.dart`
2. Injecter les repos nécessaires en constructeur
3. Naviguer depuis l'écran parent avec `Navigator.push(MaterialPageRoute(...))`
4. Pas de route nommée (pas de go_router)

### Ajouter un widget partagé
1. Créer `lib/widgets/mon_widget.dart`
2. Documenter avec un commentaire `///` sur la classe
3. Importer avec `package:snacky/widgets/mon_widget.dart`
4. Mettre à jour `ai/widgets.md`

### Empty state
Utiliser le widget privé `_EmptyState` dans `search_screen.dart` comme modèle.  
Pattern : icône dans cercle → titre → sous-titre → bouton optionnel.

### Loading state
Toujours utiliser `NewsListSkeleton(count: N)` pendant `_isLoading == true`.  
Ne jamais afficher un `CircularProgressIndicator` centré pour les listes d'articles.

### HapticFeedback
Appeler `HapticFeedback.lightImpact()` après toute action utilisateur significative (favoris, ajout tag).  
`HapticFeedback.mediumImpact()` pour les suppressions.

### SnackBar
Pattern standard utilisé dans `SearchScreen` :
```dart
ScaffoldMessenger.of(context).hideCurrentSnackBar();
ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  content: Row(children: [Icon(...), SizedBox(width: 8), Text(...)]),
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  backgroundColor: Color(...),
  duration: Duration(seconds: 2),
));
```

---

## Ce qui n'est pas encore branché (TODO)

| Quoi | Où brancher | Service disponible |
|---|---|---|
| Date relative | `NewsCard` à côté de `article.time` | `ArticleFormatterService.relativeDate()` |
| Tri via service | `SearchScreen._sortOrder` | `ArticleSortService` |
| `_userId` dynamique | `SearchScreen` | `authRepo.currentUser?.id ?? 'user_1'` |

---

## Fichiers à ne pas modifier sans contexte complet

| Fichier | Raison |
|---|---|
| `services/app_initializer.dart` | Ordre d'init critique, Future.wait précis |
| `repositories/article_repository.dart` | Logique de cache journalier fragile |
| `models/confidence_level.dart` | L'ordre des enum values (index) est utilisé pour le tri |
| `main.dart` | Bootstrap + `SnackyApp.of(context)` pattern global |
