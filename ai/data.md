# Data — Modèles, Services, Repositories, Stockage

## Modèles (`lib/models/`)

### `Article` — `models/article.dart`
Champs : `id, title, source, time, description, url, image?, tags[], fetchedAt, confidence, confidenceReason?`  
- `isExpired` → true si `fetchedAt` est d'un jour précédent (logique de cache)  
- `fromJson` / `toJson` présents

### `ConfidenceLevel` — `models/confidence_level.dart`
Enum : `high | medium | low | unknown`  
Getters : `.label`, `.color`, `.backgroundColor`, `.icon`  
Ordre index (pour tri croissant fiabilité) : high=0, medium=1, low=2, unknown=3

### `AuthUser` — `models/auth_user.dart`
Champs : `id, email, displayName?`  
Getter : `.name` → `displayName ?? email.split('@').first`

---

## Services (`lib/services/`)

### `ArticleService` (abstract) — `services/article_service.dart`
Contrat à implémenter pour brancher l'API :
```dart
fetchAllArticles({userId}) → Future<List<Article>>
fetchArticlesByTag({userId, tag}) → Future<List<Article>>
fetchTags({userId}) → Future<List<String>>
```
**Swapper** : remplacer `MockArticleService()` par `ApiArticleService()` dans `app_initializer.dart` (2 endroits : `ArticleRepository` et `TagRepository`).

### `MockArticleService` — `services/mock_article_service.dart`
Simule 600ms de latence réseau. Contient des fixtures avec vraies images (picperf.io).  
Génère des articles dynamiques pour les tags sans fixture via `_generateArticlesForTag()`.

### `AuthService` (abstract) — `services/auth_service.dart`
Contrat : `login`, `register`, `logout`, `getCurrentUser`  
`AuthResult` : `.isSuccess`, `.user?`, `.error?`

### `MockAuthService` — `services/mock_auth_service.dart`
Stockage en mémoire uniquement (reset au redémarrage). Simule 600ms.

### `ArticleSortService` — `services/article_sort_service.dart`
Pure Dart, sans Flutter, testable.  
```dart
sortByRecent(articles)      // fetchedAt DESC
sortByConfidence(articles)  // confidence.index ASC (high → unknown)
filterByTag(articles, tag)  // tag == 'Tout' → tous
```
⚠️ **Non encore utilisé dans SearchScreen** — le tri y est fait inline. À brancher si la logique se complexifie.

### `ArticleFormatterService` — `services/article_formatter_service.dart`
Pure Dart, sans Flutter, testable.  
```dart
estimateReadingTimeMinutes(article)  // base 200 mots/min
readingTimeLabel(article)            // "3 min"
relativeDate(article)                // "il y a 2h", "hier"…
truncateTitle(title, maxLength: 60)
```
⚠️ **Non encore utilisé dans les écrans** — à brancher dans `NewsCard` ou `ArticleDetailScreen`.

### `LocalStorageService` — `services/local_storage_service.dart`
Wrapper SharedPreferences. Clés :
- `favorites` → `List<Map>` JSON  
- `cached_articles` → `List<Map>` JSON  
- `user_tags` → `List<String>`  
- `auth_session` → `Map` JSON  
- `onboarding_done` → `bool` (accédé directement via SharedPreferences dans `app_initializer.dart`)

---

## Repositories (`lib/repositories/`)

### `ArticleRepository` — `repositories/article_repository.dart`
Cache journalier : si tous les articles ont `isExpired == false` → cache utilisé, sinon refetch.  
```dart
getAllArticles({userId})          // charge ou rafraîchit le cache
getArticlesByTag({userId, tag})   // cherche dans le cache d'abord
getCachedArticles()               // lecture mémoire synchrone
```

### `TagRepository` — `repositories/tag_repository.dart`
Tags = `['Tout', 'Favoris', ...apiTags, ...userTags]` (sans doublon).  
Tags perso persistés dans SharedPreferences.  
`addTag()` → retourne `false` si doublon (comparison insensible à la casse).

### `FavoriteRepository` — `repositories/favorite_repository.dart`
Deux structures en mémoire : `Set<String>` pour `isFavorite()` O(1) + `List<Article>` ordonnée.  
`toggleFavorite()` → persiste immédiatement.

### `AuthRepository` — `repositories/auth_repository.dart`
Orchestre `AuthService` + session persistée.  
`currentUser` → `AuthUser?` (null = non connecté).  
Session JSON sauvegardée pour survivre au redémarrage.
