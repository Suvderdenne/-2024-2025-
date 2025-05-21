import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/huudas/category_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late Future<List<dynamic>> _products;
  List<dynamic> allProducts = [];
  String _searchQuery = '';
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final String baseUrl = 'http://127.0.0.1:8000';

  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/api/products/'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      allProducts = data;
      return data;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<String?> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
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

        if (!mounted) return;
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Сагсанд нэмэгдлээ")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Алдаа гарлаа. Дахин оролдоно уу.")),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Сүлжээний алдаа: $e")),
        );
      }
    } else {
      // Зочин хэрэглэгчийн сагс (offline)
      final cartString = prefs.getString('guest_cart');
      List<int> cart = [];

      if (cartString != null) {
        cart = List<int>.from(jsonDecode(cartString));
      }

      cart.add(productId);
      await prefs.setString('guest_cart', jsonEncode(cart));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Сагсанд нэмэгдлээ (offline)")),
      );
    }
  }

  void _showProductDetailsModal(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 48,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item['image_url'],
                  height: MediaQuery.of(context).size.height * 0.3,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                item['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "₮${item['price']}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  double rating = item['rating']?.toDouble() ?? 0.0;
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(
                item['description'] ?? "No description available",
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    addToCart(item['id']);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Сагслах",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF6A1B9A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      AppBar(
                        title: const Text(
                          "Гоёл чимэглэлийн апп",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        centerTitle: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                            onPressed: () => Navigator.pushNamed(context, '/cart'),
                          ),
                          FutureBuilder<String?>(
                            future: _getAccessToken(),
                            builder: (context, snapshot) {
                              final isLoggedIn = snapshot.hasData && snapshot.data != null;
                              return Row(
                                children: [
                                  if (isLoggedIn)
                                    IconButton(
                                      icon: const Icon(Icons.person, color: Colors.white),
                                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                                    )
                                  else ...[
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(context, '/login'),
                                      child: const Text("Нэвтрэх", style: TextStyle(color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(context, '/register'),
                                      child: const Text("Бүртгүүлэх", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Хайх...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _products,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Алдаа гарлаа", style: TextStyle(color: Colors.grey[600])),
                    );
                  } else {
                    final filteredProducts = allProducts.where((item) {
                      final name = item['name'].toString().toLowerCase();
                      return name.contains(_searchQuery);
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Text("Бараа олдсонгүй", style: TextStyle(color: Colors.grey[600])),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isPortrait ? 2 : 3,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final item = filteredProducts[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () => _showProductDetailsModal(item),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            item['image_url'],
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                "₮${item['price']}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Row(
                                            children: [
                                              ...List.generate(5, (i) {
                                                double rating = item['rating']?.toDouble() ?? 0.0;
                                                return Icon(
                                                  i < rating ? Icons.star : Icons.star_border,
                                                  size: 14,
                                                  color: Colors.amber,
                                                );
                                              }),
                                            ],
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () => addToCart(item['id']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF6A1B9A),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: const Text(
                                                "Сагслах",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryPage()),
              );
            }
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF6A1B9A),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Нүүр',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_rounded),
              label: 'Төрөл',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.discount_rounded),
              label: 'Хөнгөлөлт',
            ),
          ],
        ),
      ),
    );
  }
}
