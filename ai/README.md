# Snacky — Documentation IA

> **Point d'entrée unique.** Lis ce fichier en premier. Ne charge les autres fichiers que si la tâche le justifie.

## Qu'est-ce que Snacky ?
Application Flutter de veille d'actualité mobile-first. L'utilisateur abonne des thèmes ("IA", "Flutter"…), Snacky affiche les articles correspondants avec un badge de fiabilité. Stack : Flutter 3 / Dart / SharedPreferences / pas de backend réel (mock).

## Fichiers de cette doc

| Fichier | Quand le lire |
|---|---|
| `architecture.md` | Comprendre la structure globale, les couches, les dépendances |
| `widgets.md` | Modifier ou ajouter un widget UI |
| `data.md` | Toucher aux modèles, services, repositories, stockage |
| `screens.md` | Modifier le comportement d'un écran |
| `conventions.md` | Règles de code, patterns à respecter |

## Arbre src (résumé)
```
lib/
  main.dart           ← bootstrap + SnackyApp (thème, routing)
  models/             ← entités pures (Article, AuthUser, ConfidenceLevel)
  services/           ← logique métier + contrats abstraits
  repositories/       ← cache mémoire + persistence via LocalStorageService
  screens/            ← 5 écrans (SearchScreen, ArticleDetail, Onboarding, Login, Register)
  widgets/            ← composants réutilisables
```

## Couleur brand
`Color(0xFF3F51B5)` — Indigo. Utilisée partout. Alias : `_brand`, `_brandColor`, `kBrandColor`.

## Dépendances pub
`shimmer`, `shared_preferences`, `url_launcher`, `share_plus`, `cupertino_icons`
