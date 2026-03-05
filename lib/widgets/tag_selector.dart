import 'package:flutter/material.dart';

class TagSelector extends StatelessWidget {
  final List<String> tags;
  final String selectedTag;
  final Function(String) onTagSelected;
  // Appelé avec le nom du tag quand l'utilisateur veut le supprimer (appui long).
  // Null = désactivé (tags système non supprimables).
  final Function(String)? onTagRemoved;
  // Nombre de favoris affiché comme badge sur le tag "Favoris"
  final int favoritesCount;

  const TagSelector({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
    this.onTagRemoved,
    this.favoritesCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Séparation des tags principaux et secondaires
    final mainTags = tags.where((t) => t == "Tout" || t == "Favoris").toList();
    final otherTags = tags.where((t) => t != "Tout" && t != "Favoris").toList();
    final labelColor = Theme.of(context).colorScheme.onSurface;
    final unselectedBorder = Theme.of(context).colorScheme.outlineVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mainTags.length,
            itemBuilder: (context, index) {
              final tag = mainTags[index];
              final isSelected = selectedTag == tag;
              final showBadge = tag == "Favoris" && favoritesCount > 0;
              final chip = FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (_) => onTagSelected(tag),
                selectedColor: const Color(0xFF3F51B5).withOpacity(0.2),
                checkmarkColor: const Color(0xFF3F51B5),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF3F51B5) : labelColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF3F51B5)
                        : unselectedBorder,
                  ),
                ),
              );
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                // Stack pour superposer la pastille SANS affecter la hauteur du chip
                child: showBadge
                    ? Stack(
                        clipBehavior: Clip.none,
                        children: [
                          chip,
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              constraints: const BoxConstraints(minWidth: 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3F51B5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$favoritesCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      )
                    : chip,
              );
            },
          ),
        ),
        if (otherTags.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: otherTags.length,
              itemBuilder: (context, index) {
                final tag = otherTags[index];
                final isSelected = selectedTag == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: GestureDetector(
                    // Appui long → confirmation de suppression
                    onLongPress: onTagRemoved != null
                        ? () => _confirmRemove(context, tag)
                        : null,
                    child: FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (_) => onTagSelected(tag),
                      selectedColor: const Color(0xFF3F51B5).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF3F51B5),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF3F51B5)
                            : labelColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      // Petite icône ✕ pour indiquer la suppressibilité
                      deleteIcon: onTagRemoved != null
                          ? const Icon(Icons.close, size: 14)
                          : null,
                      onDeleted: onTagRemoved != null
                          ? () => _confirmRemove(context, tag)
                          : null,
                      deleteIconColor: const Color(0xFF3F51B5).withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF3F51B5)
                              : unselectedBorder,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _confirmRemove(BuildContext context, String tag) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce thème ?'),
        content: Text('Le thème "$tag" et ses articles seront retirés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) onTagRemoved!(tag);
    });
  }
}
