# Architecture

## Principe des couches

```
UI (screens/)
    ↓ lit/écrit via
Repositories (repositories/)
    ↓ délèguent à
Services (services/)
    ↓ persiste via
LocalStorageService
```

Règle : les screens ne touchent jamais les services directement. Tout passe par les repositories.

## Bootstrap — `services/app_initializer.dart`
`AppInitializer.init()` est appelé une seule fois dans `main()`.  
Retourne `AppBootstrap` (struct avec les 4 repos + `showOnboarding`).  
**C'est ici qu'on swappera Mock → API** : remplacer `MockArticleService` / `MockAuthService`.

```
main() → AppInitializer.init() → AppBootstrap → SnackyApp (injecte les repos)
```

## Injection de dépendances
Pas de provider/Riverpod. Injection manuelle par constructeur, descendante depuis `main.dart`.  
`SearchScreen` reçoit les 4 repos en paramètre. Idem `OnboardingScreen`.

## `SnackyApp` (`main.dart`)
- Widget racine `StatefulWidget`
- Gère `ThemeMode` (clair/sombre) via `toggleTheme()`
- Accessible depuis n'importe quel descendant : `SnackyApp.of(context)`
- Route initiale : `OnboardingScreen` si premier lancement, sinon `SearchScreen`

## Routing
Navigation impérative (`Navigator.push/pop`). Pas de go_router.  
- Onboarding → SearchScreen : `pushReplacement` avec `FadeTransition`  
- SearchScreen → ArticleDetailScreen : `MaterialPageRoute` standard  
- SearchScreen → LoginScreen : `push` (retour via `pop`)

## Thème
Material 3. Seed color = `0xFF3F51B5`.  
Dark mode géré par `ThemeMode` dans `_SnackyAppState`.

## Diagramme des dépendances repos/services

```
ArticleRepository  ←── ArticleService (abstract)
                             ↑
                      MockArticleService   (actuel)
                      ApiArticleService    (à créer)

TagRepository      ←── ArticleService (même contrat, fetchTags)

FavoriteRepository ←── LocalStorageService uniquement

AuthRepository     ←── AuthService (abstract)
                             ↑
                      MockAuthService      (actuel)
                      ApiAuthService       (à créer)

tous les repos     ←── LocalStorageService
```
