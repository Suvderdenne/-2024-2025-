import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final Map<String, dynamic>? newItem;

  const CartPage({super.key, this.newItem});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.newItem != null) {
      addItemToCart(widget.newItem!);
    }
  }

  void addItemToCart(Map<String, dynamic> item) {
    final index = cartItems.indexWhere((element) => element['name'] == item['name']);
    if (index != -1) {
      cartItems[index]['quantity'] += 1;
    } else {
      cartItems.add({
        'name': item['name'],
        'price': item['price'],
        'quantity': 1,
      });
    }
    setState(() {});
  }

  double getTotalPrice() {
    return cartItems.fold(0, (sum, item) => sum + item['price'] * item['quantity']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Миний сагс'),
        backgroundColor: Colors.teal,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Сагс хоосон байна'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('${item['quantity']}ш × ${item['price']}₮'),
                  trailing: Text('${item['price'] * item['quantity']}₮'),
                );
              },
            ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Нийт: ${getTotalPrice().toStringAsFixed(0)}₮',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Худалдан авалт амжилттай хийгдлээ!')),
                      );
                      setState(() {
                        cartItems.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text('Худалдан авах'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

