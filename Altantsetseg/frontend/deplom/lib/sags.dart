import 'package:flutter/material.dart';
import 'order_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [
    {
      'id': 1,
      'name': 'Ширээ',
      'price': 100000,
      'quantity': 1,
      'image': 'https://via.placeholder.com/150'
    },
    {
      'id': 2,
      'name': 'Сандал',
      'price': 50000,
      'quantity': 2,
      'image': 'https://via.placeholder.com/150'
    }
  ];

  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) {
      final quantity = item['quantity'] ?? 1;
      final price = item['price'] ?? 0;
      return sum + (quantity * price);
    });
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Миний сагс'),
        backgroundColor: Colors.deepOrange,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Сагсанд бүтээгдэхүүн алга'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final quantity = item['quantity'] ?? 1;
                final price = item['price'] ?? 0;
                final total = quantity * price;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    leading: item['image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.image),
                    title: Text(item['name'] ?? 'Нэргүй'),
                    subtitle: Text('$quantity ш | ₮$total'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => removeItem(index),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Нийт үнэ: ₮${totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderPage(
                            cartItems: List<Map<String, dynamic>>.from(cartItems),
                            totalPrice: totalPrice,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('Захиалга хийх'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
