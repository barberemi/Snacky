# Widgets

> Tous les widgets partagés sont dans `lib/widgets/`. Ne jamais créer de classe privée `_Foo` qui duplique un widget déjà existant dans ce dossier.

## Catalogue

### `TagChip` — `widgets/tag_chip.dart`
Chip animé sélectionnable avec icône de suppression optionnelle.  
```dart
TagChip(tag: 'IA', isSelected: true, onTap: () {}, onDelete: () {})
```
- `onDelete: null` → pas d'icône ×  
- Couleur brand quand sélectionné, transparent + border sinon  
- Padding vertical 16px pour que le chip ait une hauteur suffisante (≥ 48px)

### `TagSelector` — `widgets/tag_selector.dart`
Liste horizontale de chips. Deux rangées : "Tout"/"Favoris" (row 1) + tags perso (row 2).  
```dart
TagSelector(
  tags: _tags,
  selectedTag: _selectedTag,
  onTagSelected: _onTagChanged,
  onTagRemoved: _onTagRemoved,   // null = pas de suppression
  favoritesCount: 3,             // 0 = pas de pastille rouge
)
```
- Pastille rouge sur "Favoris" si `favoritesCount > 0` (Stack + Positioned, `clipBehavior: Clip.none`)  
- Long press + bouton × sur tags perso → dialog de confirmation interne  
- Utilise `TagChip`

### `ConfidenceBadge` — `widgets/confidence_badge.dart`
Badge compact (icon + label) pour les cards. Ce fichier est aussi un **barrel** — importer `confidence_badge.dart` donne accès à `ConfidenceDetail` aussi.
```dart
ConfidenceBadge(confidence: article.confidence)
```

### `ConfidenceDetail` — `widgets/confidence_detail.dart`
Bloc élargi avec raison, pour la page détail.
```dart
ConfidenceDetail(confidence: article.confidence, reason: article.confidenceReason)
```

### `UserAvatar` — `widgets/user_avatar.dart`
Avatar circulaire (initiale) cliquable. Ouvre un `PopupMenu` avec déconnexion.  
```dart
UserAvatar(user: authUser, onLogout: _logout)
```

### `NewsCard` — `widgets/news_card.dart`
Card article expandable. Affiche image bannière si `article.image != null`.  
Hero tag : `'article_image_${article.id}'`  
Dépend de : `ConfidenceBadge`, `ArticleDetailScreen`

### `NewsCardSkeleton` / `NewsListSkeleton` — `widgets/news_card_skeleton.dart`
Shimmer de chargement.  
```dart
NewsListSkeleton(count: 5)   // utilisé dans SearchScreen pendant _isLoading
```

### `auth_widgets.dart` — `widgets/auth_widgets.dart`
**Barrel** — importer ce fichier unique suffit pour tout avoir. Expose aussi `kBrandColor`.  
Widgets dans leurs propres fichiers :
- `SnackyField` → `widgets/snacky_field.dart` : champ de formulaire stylé  
- `SnackyButton` → `widgets/snacky_button.dart` : bouton principal avec état loading  
- `AuthErrorBanner` → `widgets/auth_error_banner.dart` : bandeau d'erreur rouge  
- `AuthLinkText` → `widgets/auth_link_text.dart` : lien "Tu n'as pas de compte ? S'inscrire"  
- Constante : `kBrandColor = Color(0xFF3F51B5)` (définie dans le barrel)

## Widgets internes à ne pas extraire
Ces classes privées `_` sont légitimement locales (trop spécifiques, pas réutilisées) :
- `_Bar` dans `news_card_skeleton.dart` — barre shimmer générique interne
- `_SortButton`, `_EmptyState`, `_AnimatedCard` dans `search_screen.dart` — UI locale à l'écran
- `_SlidePage` dans `onboarding_screen.dart` — slide unique à l'onboarding
- `_ArticleLink` dans `news_card.dart` — lien "Voir l'article" avec hover
