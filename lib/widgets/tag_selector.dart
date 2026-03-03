import 'package:flutter/material.dart';

class TagSelector extends StatelessWidget {
  final List<String> tags;
  final String selectedTag;
  final Function(String) onTagSelected;

  const TagSelector({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = selectedTag == tag;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => onTagSelected(tag),
              selectedColor: const Color(0xFF3F51B5).withOpacity(0.2),
              checkmarkColor: const Color(0xFF3F51B5),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF3F51B5) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF3F51B5)
                      : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
