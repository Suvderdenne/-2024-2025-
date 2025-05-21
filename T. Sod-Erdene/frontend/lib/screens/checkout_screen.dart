import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_confirmation.dart'; // Та энэ файлыг өөрийн project-дээ нэмээрэй
import 'package:http/http.dart' as http;

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onOrderConfirmed;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.onOrderConfirmed,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late List<Map<String, dynamic>> _cart;

  @override
  void initState() {
    super.initState();
    _cart = List<Map<String, dynamic>>.from(widget.cartItems);
  }

  double get subtotal =>
      _cart.fold(0, (sum, item) => sum + item['price'] * item['quantity']);

  double get shipping => subtotal * 0.05;

  double get total => subtotal + shipping;

  Uint8List? _decodeBase64Image(String base64String) {
    try {
      final cleaned = base64String.split(',').last;
      return base64Decode(cleaned);
    } catch (e) {
      return null;
    }
  }

  void _incrementQuantity(int index) {
    setState(() {
      _cart[index]['quantity'] += 1;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_cart[index]['quantity'] > 1) {
        _cart[index]['quantity'] -= 1;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  void _startCheckout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нэвтрэх шаардлагатай байна')),
      );
      return;
    }

    final orderData = {
      "items":
          _cart
              .map(
                (item) => {
                  "id": item['id'],
                  "quantity": item['quantity'],
                  "price": item['price'],
                },
              )
              .toList(),
      "total_price": total,
    };

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/orders/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        widget.onOrderConfirmed();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => OrderConfirmationScreen(
                    cartItems: _cart,
                    totalPrice: total,
                    paymentMethod: 'Qpay',
                    orderData: orderData,
                  ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Захиалга үүсгэхэд алдаа гарлаа')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Алдаа гарлаа: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Захиалга хийх')),
      body:
          _cart.isEmpty
              ? _buildEmptyCart(context)
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Таны сагсанд:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          final imageData = _decodeBase64Image(item['image']);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child:
                                        imageData != null
                                            ? Image.memory(
                                              imageData,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                            : const Icon(
                                              Icons.image_not_supported,
                                              size: 100,
                                              color: Colors.grey,
                                            ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${item['price']}₮ × ${item['quantity']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${(item['price'] * item['quantity']).toStringAsFixed(2)}₮',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                              ),
                                              onPressed:
                                                  () =>
                                                      _decrementQuantity(index),
                                            ),
                                            Text(
                                              '${item['quantity']}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                              ),
                                              onPressed:
                                                  () =>
                                                      _incrementQuantity(index),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _cart.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    _buildPriceRow('Нийт нийлбэр дүны', subtotal),
                    _buildPriceRow('Хүргэлт', shipping),
                    const SizedBox(height: 10),
                    _buildPriceRow('Нийт', total, isTotal: true),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        label: const Text(
                          'Захиалга баталгаажуулах',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          _startCheckout();
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          '${value.toStringAsFixed(2)}₮',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.remove_shopping_cart, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Таны сагс хоосон байна',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Үзэсгэлэн үзэх'),
          ),
        ],
      ),
    );
  }
}
