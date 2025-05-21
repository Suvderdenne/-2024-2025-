import 'package:flutter/material.dart';
import '../constants.dart';

class SearchBarComponent extends StatelessWidget {
  final Function(String)? onTextChanged;
  final VoidCallback? onPhotoSearch;

  const SearchBarComponent({super.key, this.onTextChanged, this.onPhotoSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: white,
                border: Border.all(color: green),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: green.withOpacity(0.15), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: onTextChanged,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search plant name...',
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/icons/search.png',
                    height: 22,
                    errorBuilder: (_, __, ___) => const Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onPhotoSearch,
            child: Container(
              height: 48,
              width: 48,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: green.withOpacity(0.5), blurRadius: 10),
                ],
              ),
              child: Image.asset(
                'assets/icons/camera.png', // use your photo search icon here
                color: white,
                errorBuilder:
                    (_, __, ___) =>
                        const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
