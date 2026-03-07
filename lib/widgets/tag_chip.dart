import 'package:flutter/material.dart';

/// Chip de tag animé, utilisé dans [TagSelector].
/// Gère l'état sélectionné/non sélectionné et l'icône de suppression optionnelle.
class TagChip extends StatelessWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  static const _brand = Color(0xFF3F51B5);

  const TagChip({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedBorder = Theme.of(context).colorScheme.outlineVariant;
    final labelColor = Theme.of(context).colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? _brand : Colors.transparent,
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
            padding: EdgeInsets.fromLTRB(12, 16, onDelete != null ? 4 : 12, 16),
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
