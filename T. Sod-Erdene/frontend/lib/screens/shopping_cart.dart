import 'package:flutter/material.dart';
import 'package:frontend/screens/checkout_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int)? onRemoveItem;
  final Function(int, int)? onUpdateQuantity;
  final Function(List<Map<String, dynamic>>)? onUpdateCart;

  const CartScreen({
    super.key,
    required this.cartItems,
    this.onRemoveItem,
    this.onUpdateQuantity,
    this.onUpdateCart,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  Future<void> _fetchCartData() async {
    try {
      setState(() => _isLoading = true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');

      if (token == null) {
        setState(() {
          _error = 'Нэвтрэх шаардлагатай';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/cart/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final cartData = jsonDecode(response.body);
        // Update cart items through parent widget's callback
        widget.onUpdateCart?.call(cartData['items']);
      } else {
        setState(() => _error = 'Сагсны мэдээллийг авахад алдаа гарлаа');
      }
    } catch (e) {
      setState(() => _error = 'Алдаа гарлаа: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');

      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Нэвтрэх шаардлагатай')));
        return;
      }

      final item = widget.cartItems[index];
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/cart/update-quantity/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'item_id': item['id'], 'quantity': newQuantity}),
      );

      if (response.statusCode == 200) {
        widget.onUpdateQuantity?.call(index, newQuantity);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Тоо хэмжээг шинэчлэхэд алдаа гарлаа')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Алдаа гарлаа: $e')));
    }
  }

  Future<void> _removeItem(int index) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');

      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Нэвтрэх шаардлагатай')));
        return;
      }

      final item = widget.cartItems[index];
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/cart/remove/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'item_id': item['id']}),
      );

      if (response.statusCode == 200) {
        widget.onRemoveItem?.call(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Бараа сагснаас хасагдлаа')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Барааг хасахад алдаа гарлаа')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Алдаа гарлаа: $e')));
    }
  }

  double get subtotal => widget.cartItems.fold(
    0,
    (sum, item) => sum + (item['price'] * (item['quantity'] ?? 1)),
  );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCartData,
                child: const Text('Дахин оролдох'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Таны сагс'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                widget.cartItems.isEmpty
                    ? _buildEmptyCart()
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.cartItems.length,
                      itemBuilder:
                          (context, index) =>
                              _buildCartItem(widget.cartItems[index], index),
                    ),
          ),
          if (widget.cartItems.isNotEmpty) _buildCheckoutCard(),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'] ?? 'https://via.placeholder.com/150',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['price']?.toStringAsFixed(2) ?? '0.00'}₮',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          final newQty = (item['quantity'] ?? 1) - 1;
                          if (newQty > 0) {
                            _updateQuantity(index, newQty);
                          }
                        },
                      ),
                      Text(
                        '${item['quantity'] ?? 1}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          _updateQuantity(index, (item['quantity'] ?? 1) + 1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeItem(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Нийт дүн'),
                Text('${subtotal.toStringAsFixed(2)}₮'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Хүргэлт'),
                Text('${(subtotal * 0.05).toStringAsFixed(2)}₮'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Нийт төлөх',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(subtotal * 1.05).toStringAsFixed(2)}₮',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _navigateToCheckout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Захиалах',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CheckoutScreen(
              cartItems: widget.cartItems,
              onOrderConfirmed: () {
                setState(() {
                  widget.onUpdateCart?.call([]);
                });
              },
            ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Таны сагс хоосон байна',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Худалдан авалт хийх'),
          ),
        ],
      ),
    );
  }
}
