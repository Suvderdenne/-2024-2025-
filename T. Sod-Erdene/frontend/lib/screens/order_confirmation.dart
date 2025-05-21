import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;
  final String paymentMethod;

  const OrderConfirmationScreen({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.paymentMethod,
    required Map orderData,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _isSubmitting = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _submitOrder();
  }

  Future<void> _submitOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    if (token == null) {
      setState(() {
        _errorMessage = 'Нэвтрэх шаардлагатай байна.';
        _isSubmitting = false;
      });
      return;
    }

    final orderData = {
      "total_price": widget.totalPrice,
      "items":
          widget.cartItems.map((item) {
            return {
              "id": item['id'], // furniture_id
              "quantity": item['quantity'] ?? 1,
              "price": item['price'],
            };
          }).toList(),
      "payment_method": widget.paymentMethod,
    };

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/order/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        setState(() => _isSubmitting = false);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/order-success');
        }
      } else {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Захиалга илгээхэд алдаа гарлаа.';
        });
        print('Error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Алдаа гарлаа: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Захиалга баталгаажсан'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child:
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 100,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Таны захиалга амжилттай илгээгдлээ!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Тун удахгүй бид таны захиалгыг баталгаажуулж, хүргэх болно.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[200],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'QPay төлбөрийн QR',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Image.network(
                            'https://qpay.mn/images/sample-qr.png',
                            height: 150,
                            width: 150,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Text('QR код ачаалагдсангүй'),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Та энэ QR кодыг уншуулан төлбөрөө хийж болно.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.popUntil(
                            context,
                            (route) => route.isFirst,
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                      ),
                      child: const Text(
                        'Нүүр хуудас руу буцах',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
