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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFFFFF)], // 🌤️ Улбар шар → Цагаан
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(item['name'] ?? 'Дэлгэрэнгүй'),
          backgroundColor: Colors.orange,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item['image'] != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      '$baseUrl${item['image']}',
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              Text(
                item['name'] ?? 'Нэргүй',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item['description'] ?? 'Тайлбар алга',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text('Үнэ: ${item['price']}₮', style: const TextStyle(fontSize: 16)),
              // const SizedBox(height: 6),
              Text('Тоо ширхэг: ${item['quantity']}ш', style: const TextStyle(fontSize: 16)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Сагсанд нэмэгдлээ')),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Сагсанд нэмэх'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
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
