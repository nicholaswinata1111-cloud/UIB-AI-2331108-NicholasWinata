import 'package:flutter/material.dart';

class GenreFilterChip extends StatelessWidget {
  final String genre;
  final bool isSelected;
  final VoidCallback onSelected;

  const GenreFilterChip({
    super.key,
    required this.genre,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(genre),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        selectedColor: Colors.indigo,
        backgroundColor: Colors.grey.shade100,
        side: BorderSide(
          color: isSelected ? Colors.indigo : Colors.grey.shade300,
        ),
      ),
    );
  }
}
