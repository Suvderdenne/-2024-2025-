import 'package:flutter/material.dart';

class MaterialDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;
  final String baseUrl;

  const MaterialDetailPage({
    super.key,
    required this.item,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item['image'] ?? '';
    final name = item['name'] ?? 'Нэргүй';
    final description = item['description'] ?? '';
    final price = item['price'] ?? 0;
    final quantity = item['quantity'] ?? 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFFFFF)], // 🌞 Шаргал → Цагаан
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(name),
          backgroundColor: Colors.orangeAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl.startsWith('http') ? imageUrl : '$baseUrl$imageUrl',
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              const SizedBox(height: 5),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 5),
              Text('Үнэ: $price₮', style: const TextStyle(fontSize: 16)),
              Text('Тоо: $quantity ширхэг', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              Text(description, style: const TextStyle(fontSize: 16)),
              const Spacer(),

              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Сагсанд нэмэгдлээ'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Сагсанд нэмэх'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
