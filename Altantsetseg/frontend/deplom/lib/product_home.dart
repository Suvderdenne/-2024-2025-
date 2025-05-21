import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'material_detail_page.dart';
import 'order_page.dart';
import 'material_card.dart';
import 'payment_page.dart';
import 'profile.dart'; // ✅ Профайл хуудас

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Материалын дэлгүүр',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const ProductHomePage(),
      routes: {
        '/profile': (context) => const ProfilePage(),
        // '/login': (context) => const LoginPage(), // login байвал энд нэм
      },
    );
  }
}

class ProductHomePage extends StatefulWidget {
  const ProductHomePage({super.key});

  @override
  State<ProductHomePage> createState() => _ProductHomePageState();
}

class _ProductHomePageState extends State<ProductHomePage> {
  List<dynamic> materials = [];
  List<String> categories = ['Бүгд'];
  String selectedCategory = 'Бүгд';
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;
  String? errorMessage;
  bool showFavorites = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String getBaseUrl() {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  @override
  void initState() {
    super.initState();
    fetchMaterials();
    loadCartFromStorage();
    loadFavoritesFromStorage();
  }

  Future<void> fetchMaterials() async {
    final url = Uri.parse('${getBaseUrl()}/api/materials/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        final Set<String> fetchedCategories = decodedData.map<String>((item) => item['category_name'] ?? '').toSet();
        setState(() {
          materials = decodedData;
          categories = ['Бүгд', ...fetchedCategories.where((c) => c.isNotEmpty)];
          isLoading = false;
        });
      } else {
        throw Exception('Алдаа: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Материал татах үед алдаа гарлаа.';
      });
    }
  }

  Future<void> loadCartFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart_items');
    if (cartData != null) {
      final List decoded = jsonDecode(cartData);
      setState(() {
        cart = decoded.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  Future<void> loadFavoritesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final favData = prefs.getString('favorite_items');
    if (favData != null) {
      final List decoded = jsonDecode(favData);
      setState(() {
        favorites = decoded.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void addToCart(Map<String, dynamic> item) {
    setState(() {
      final index = cart.indexWhere((element) => element['id'] == item['id']);
      if (index != -1) {
        cart[index]['quantity'] = (cart[index]['quantity'] ?? 1) + 1;
      } else {
        cart.add({...item, 'quantity': 1});
      }
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('cart_items', jsonEncode(cart));
    });
  }

  void toggleFavorite(Map<String, dynamic> item) {
    setState(() {
      final exists = favorites.any((fav) => fav['id'] == item['id']);
      if (exists) {
        favorites.removeWhere((fav) => fav['id'] == item['id']);
      } else {
        favorites.add(item);
      }
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('favorite_items', jsonEncode(favorites));
    });
  }

  double get totalPrice => cart.fold(0.0, (sum, item) => sum + (item['price'] * (item['quantity'] ?? 1)));

  List<dynamic> get filteredMaterials {
    final source = showFavorites ? favorites : materials;
    final filteredByCategory = selectedCategory == 'Бүгд'
        ? source
        : source.where((item) => item['category_name'] == selectedCategory).toList();

    if (_searchQuery.isEmpty) return filteredByCategory;
    return filteredByCategory.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      final price = item['price']?.toString() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || price.contains(query);
    }).toList();
  }

  void goToPayment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart_items', jsonEncode(cart));
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(method: 'QPay', amount: totalPrice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFCC80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.orange),
                child: Text('Цэс', style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Профайл'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Хадгалсан бараа'),
                onTap: () => setState(() {
                  Navigator.pop(context);
                  showFavorites = true;
                }),
              ),
              ExpansionTile(
                leading: const Icon(Icons.category),
                title: const Text('Ангилал'),
                children: categories.map((category) {
                  return ListTile(
                    title: Text(category),
                    selected: selectedCategory == category,
                    onTap: () => setState(() {
                      selectedCategory = category;
                      showFavorites = false;
                      Navigator.pop(context);
                    }),
                  );
                }).toList(),
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Сагс'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderPage(cartItems: cart, totalPrice: totalPrice),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Гарах'),
                onTap: logout,
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.orange.shade700,
          title: Text(showFavorites ? 'Хадгалсан бараа' : 'Материалын дэлгүүр'),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Бараа нэр эсвэл үнэ хайх...',
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.search, color: Colors.orange),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredMaterials.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, index) {
                              final item = filteredMaterials[index];
                              final imageUrl = item['image'] ?? '';
                              return Stack(
                                children: [
                                  MaterialCard(
                                    item: item,
                                    imageUrl: imageUrl.startsWith('http')
                                        ? imageUrl
                                        : '${getBaseUrl()}$imageUrl',
                                    onTap: () => addToCart(item),
                                    onDetails: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MaterialDetailPage(item: item, baseUrl: getBaseUrl()),
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: Icon(
                                        favorites.any((fav) => fav['id'] == item['id'])
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: favorites.any((fav) => fav['id'] == item['id'])
                                            ? Colors.red
                                            : Colors.grey.shade400,
                                      ),
                                      onPressed: () => toggleFavorite(item),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.shopping_cart_checkout),
                            label: Text('Нийт ₮${totalPrice.toStringAsFixed(0)} төлөх'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: cart.isEmpty ? null : goToPayment,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
