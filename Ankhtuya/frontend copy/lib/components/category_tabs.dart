import 'package:flutter/material.dart';
import '../constants.dart';

class CategoryTabs extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selectedCategoryId;
  final Function(int) onCategorySelected;

  const CategoryTabs({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final category = categories[index];
          final bool isSelected = category['id'] == selectedCategoryId;
          return GestureDetector(
            onTap: () => onCategorySelected(category['id']),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Text(
                    category['name'],
                    style: TextStyle(
                      color: isSelected ? green : black.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  if (isSelected)
                    const CircleAvatar(radius: 3, backgroundColor: green),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
