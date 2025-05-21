import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final String baseUrl = 'http://127.0.0.1:8000'; // Backend URL
  List<String> categories = ['Бүгд'];
  String selectedCategory = 'Бүгд';
  List<dynamic> allProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/categories/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final categoryNames = List<String>.from(data);
        setState(() {
          categories = ['Бүгд', ...categoryNames];
        });
      }
    } catch (e) {
      debugPrint('Категори татах алдаа: $e');
    }
  }

  Future<void> fetchProducts({String? category}) async {
    setState(() => isLoading = true);
    try {
      final uri = category == null || category == 'Бүгд'
          ? Uri.parse('$baseUrl/api/products/')
          : Uri.parse('$baseUrl/api/products/?category=$category');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          allProducts = data;
          isLoading = false;
        });
      } else {
        debugPrint('Бүтээгдэхүүн татахад алдаа: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Сүлжээний алдаа: $e');
    }
  }

  Future<void> addToCart(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/cart/add/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'product_id': productId, 'quantity': 1}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Сагсанд нэмэгдлээ")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Сүлжээний алдаа: $e")),
        );
      }
    }
  }

  void _showProductDetailsModal(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Image.network(item['image_url'], height: 200),
              const SizedBox(height: 10),
              Text("₮${item['price']}"),
              const SizedBox(height: 10),
              Text(item['description'] ?? ''),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  addToCart(item['id']);
                  Navigator.pop(context);
                },
                child: const Text("Сагслах"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Төрлөөр харах', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // 🔽 Dropdown категори сонголт
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedCategory = value ?? 'Бүгд');
                fetchProducts(category: value == 'Бүгд' ? null : value);
              },
            ),
          ),
          // 🛒 Бүтээгдэхүүн жагсаалт
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: allProducts.length,
                    itemBuilder: (context, index) {
                      final item = allProducts[index];
                      return GestureDetector(
                        onTap: () => _showProductDetailsModal(item),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item['image_url'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(item['name'], maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text("₮${item['price']}", style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
