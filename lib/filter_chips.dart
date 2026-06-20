import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  final String? selectedPriority;
  final String? selectedCategory;
  final ValueChanged<String?> onPriorityChanged;
  final ValueChanged<String?> onCategoryChanged;

  const FilterChips({
    super.key,
    required this.selectedPriority,
    required this.selectedCategory,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Priority chips
          ...['low', 'medium', 'high'].map((p) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(p),
              selected: selectedPriority == p,
              onSelected: (sel) => onPriorityChanged(sel? p : null),
            ),
          )),
          const SizedBox(width: 8),
          // Category chips
          ...['work', 'personal', 'study', 'custom'].map((c) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(c),
              selected: selectedCategory == c,
              onSelected: (sel) => onCategoryChanged(sel? c : null),
            ),
          )),
        ],
      ),
    );
  }
}