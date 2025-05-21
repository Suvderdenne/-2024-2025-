import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/huudas/review_dialog.dart'; 
import 'package:frontend/huudas/review_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _products;
  List<dynamic> allProducts = [];
  String _searchQuery = '';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          final error = jsonDecode(utf8.decode(response.bodyBytes));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Алдаа: ${error["detail"] ?? "Оролт буруу"}")),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Сүлжээний алдаа: $e")),
        );
      }
    } else {
      final cartString = prefs.getString('guest_cart');
      List<int> cart = cartString != null ? List<int>.from(jsonDecode(cartString)) : [];
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
              if (item['description'] != null) ...[
                Text(
                  item['description'],
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
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
              FutureBuilder<List<dynamic>>(
                future: ReviewService().fetchReviews(item['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text("Сэтгэгдэл ачааллаж чадсангүй");
                  } else {
                    final reviews = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Сэтгэгдэлүүд", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        for (var review in reviews)
                          ListTile(
                            title: Text(review['user']['username'] ?? 'Хэрэглэгч'),
                            subtitle: Text(review['comment']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < review['rating'] ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                          ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => ReviewDialog(productId: item['id']),
                            );
                          },
                          child: const Text("Сэтгэгдэл үлдээх"),
                        )
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
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
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                "Гоёл чимэглэлийн апп",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Color.fromARGB(116, 0, 0, 0)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                ),
                FutureBuilder<String?>(future: _getAccessToken(), builder: (context, snapshot) {
                  final isLoggedIn = snapshot.hasData && snapshot.data != null;
                  return Row(
                    children: [
                      if (isLoggedIn)
                        IconButton(
                          icon: const Icon(Icons.person),
                          onPressed: () => Navigator.pushNamed(context, '/profile'),
                        )
                      else ...[
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          child: const Text("Нэвтрэх"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Text("Бүртгүүлэх"),
                        ),
                      ],
                    ],
                  );
                }),
                const SizedBox(width: 8),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Бараа хайх...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isPortrait ? 2 : 3,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final item = filteredProducts[index];
                        return GestureDetector(
                          onTap: () => _showProductDetailsModal(item),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      item['image_url'],
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "₮${item['price']}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(196, 22, 22, 22),
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(5, (i) {
                                          double rating = item['rating']?.toDouble() ?? 0.0;
                                          return Icon(
                                            i < rating ? Icons.star : Icons.star_border,
                                            size: 14,
                                            color: Colors.amber,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 36,
                                    child: ElevatedButton(
                                      onPressed: () => addToCart(item['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(155, 0, 0, 0),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        "Сагслах",
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }
}
