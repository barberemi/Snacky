import 'package:flutter/material.dart';

class TagSelector extends StatefulWidget {
  final List<String> tags;
  final String selectedTag;
  final Function(String) onTagSelected;
  final Function(String)? onTagRemoved;
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
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  void _onTap(String tag) {
    widget.onTagSelected(tag);
  }

  @override
  Widget build(BuildContext context) {
    final mainTags = widget.tags
        .where((t) => t == "Tout" || t == "Favoris")
        .toList();
    final otherTags = widget.tags
        .where((t) => t != "Tout" && t != "Favoris")
        .toList();

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
              final showBadge = tag == "Favoris" && widget.favoritesCount > 0;
              final chip = _TagChip(
                tag: tag,
                isSelected: widget.selectedTag == tag,
                onTap: () => _onTap(tag),
              );
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
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
                                '${widget.favoritesCount}',
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
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: GestureDetector(
                    onLongPress: widget.onTagRemoved != null
                        ? () => _confirmRemove(context, tag)
                        : null,
                    child: _TagChip(
                      tag: tag,
                      isSelected: widget.selectedTag == tag,
                      onTap: () => _onTap(tag),
                      onDelete: widget.onTagRemoved != null
                          ? () => _confirmRemove(context, tag)
                          : null,
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
      if (confirmed == true) widget.onTagRemoved!(tag);
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Chip individuel animé
// ─────────────────────────────────────────────────────────────
class _TagChip extends StatelessWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  static const _brand = Color(0xFF3F51B5);

  const _TagChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBorder = Theme.of(context).colorScheme.outlineVariant;
    final labelColor = Theme.of(context).colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? _brand // fond plein quand actif
            : (isDark ? Colors.transparent : Colors.transparent),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? _brand : unselectedBorder,
          width: isSelected ? 0 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 6, onDelete != null ? 4 : 12, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : labelColor,
                  ),
                  child: Text(tag),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : _brand.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
