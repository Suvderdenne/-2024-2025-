import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/huudas/order.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  bool isLoading = true;
  final String baseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    if (token == null) {
      setState(() {
        isLoading = false;
        cartItems = [];
      });
      return;
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/cart/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        cartItems = data["items"] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        cartItems = [];
      });
    }
  }

  Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity < 1) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    final response = await http.patch(
      Uri.parse("$baseUrl/api/cart/items/$cartItemId/update/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"quantity": newQuantity}),
    );

    if (kDebugMode) {
      print("PATCH status: ${response.statusCode}");
      print("PATCH body: ${response.body}");
    }

    if (response.statusCode == 200) {
      loadCart();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Тоо шинэчилж чадсангүй: ${response.body}")),
      );
    }
  }

  Future<void> deleteCartItem(int cartItemId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    final response = await http.delete(
      Uri.parse("$baseUrl/api/cart/items/$cartItemId/delete/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 204) {
      loadCart();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Устгаж чадсангүй: ${response.body}")),
      );
    }
  }

  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) {
      final product = item['product'];
      final rawPrice = product?['price'];
      final price = rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice.toString()) ?? 0.0;
      final quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Миний сагс")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Таны сагс хоосон байна", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = cartItems[index];
                            final product = item['product'];

                            if (product == null) return const SizedBox();
                            final rawPrice = product['price'];
                            final price = rawPrice is num
                                ? rawPrice.toDouble()
                                : double.tryParse(rawPrice.toString()) ?? 0.0;
                            final imageUrl = product['image_url'] ?? "";

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl.startsWith("http") ? imageUrl : "$baseUrl$imageUrl",
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                  ),
                                ),
                                title: Text(product['name'] ?? ''),
                                subtitle: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        final int currentQty = item['quantity'] ?? 1;
                                        if (currentQty > 1) {
                                          updateQuantity(item['id'], currentQty - 1);
                                        }
                                      },
                                    ),
                                    Text('Тоо: ${item['quantity'] ?? 0}'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        final int currentQty = item['quantity'] ?? 1;
                                        updateQuantity(item['id'], currentQty + 1);
                                      },
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${price.toStringAsFixed(0)}₮",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deleteCartItem(item['id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: cartItems.length,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Нийт дүн:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text(
                                    "${totalPrice.toStringAsFixed(0)}₮",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () async {
                                  for (var item in cartItems) {
                                    await deleteCartItem(item['id']);
                                  }
                                },
                                icon: const Icon(Icons.delete_forever, color: Colors.red),
                                label: const Text("Сагсыг хоослох", style: TextStyle(color: Colors.red)),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderPage(
                                        cartItems: cartItems,
                                        totalPrice: totalPrice,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text("🛒 Захиалга илгээх", style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
