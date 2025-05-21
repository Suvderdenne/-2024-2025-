import 'package:car_parts/screens/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  bool isLoading = true;
  String? errorMessage;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void calculateTotal() {
    double sum = 0.0;
    for (var item in cartItems) {
      // Parse the price and multiply by quantity if available
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      int quantity = item['quantity'] ?? 1;
      sum += price * quantity;
    }
    setState(() {
      total = sum;
    });
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String? token = await getToken();

      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Сагсаа үзэхийн тулд нэвтэрнэ үү';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/cart/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cartItems = data['cart_items'] ?? [];
          isLoading = false;
        });
        calculateTotal();
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Сагсны зүйлсийг ачаалж чадсангүй. Status: ${response.statusCode}\nResponse: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> removeFromCart(int itemId) async {
    try {
      String? token = await getToken();

      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
            SnackBar(content: Text('Зүйлүүдийг устгахын тулд нэвтэрнэ үү')));
        return;
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/cart/item/$itemId/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove item from local list
        setState(() {
          cartItems.removeWhere((item) => item['id'] == itemId);
        });
        calculateTotal();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Зүйлийг сагсаас хассан')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Зүйлийг устгаж чадсангүй')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> updateQuantity(int itemId, int newQuantity) async {
    if (newQuantity < 1) return;

    try {
      String? token = await getToken();
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
            SnackBar(content: Text('Сагсаа шинэчлэхийн тулд нэвтэрнэ үү')));
        return;
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/cart/item/$itemId/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'quantity': newQuantity}),
      );

      if (response.statusCode == 200) {
        setState(() {
          for (int i = 0; i < cartItems.length; i++) {
            if (cartItems[i]['id'] == itemId) {
              cartItems[i]['quantity'] = newQuantity;
              break;
            }
          }
        });
        calculateTotal();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cart updated')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Сагсыг шинэчилж чадсангүй')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(
          'Миний Сагс',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchCartItems,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorView()
              : cartItems.isEmpty
                  ? _buildEmptyCartView()
                  : _buildCartView(),
      bottomNavigationBar:
          cartItems.isEmpty || errorMessage != null || isLoading
              ? null
              : _buildTotalSection(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          SizedBox(height: 16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[300]),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: fetchCartItems,
            icon: Icon(Icons.refresh),
            label: Text('Дахин оролдоно уу'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Color(0xFF7B1FA2), // Purple accent
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16),
          Text(
            'Таны тэрэг хоосон байна',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/products');
            },
            icon: Icon(Icons.shopping_bag_outlined),
            label: Text('Дэлгүүрээ үргэлжлүүлэх'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Color(0xFF7B1FA2), // Purple accent
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartView() {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 4,
          color: Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item['image'] != null
                      ? Image.network(
                          item['image'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Color(0xFF2C2C2C),
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[500],
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Color(0xFF2C2C2C),
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[500],
                          ),
                        ),
                ),
                SizedBox(width: 16),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item['name'] ?? 'Нэргүй зүйл',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => removeFromCart(item['id']),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '₮${item['price'] ?? '0'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF252525),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    int currentQty = item['quantity'] ?? 1;
                                    if (currentQty > 1) {
                                      updateQuantity(
                                        item['id'],
                                        currentQty - 1,
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.grey[400],
                                      size: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '${item['quantity'] ?? 1}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    int currentQty = item['quantity'] ?? 1;
                                    updateQuantity(item['id'], currentQty + 1);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.grey[400],
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Нийт зүйлс:',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                Text(
                  '${cartItems.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Нийт дүн:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '₮${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAB47BC), // Light purple
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(
                        total: total,
                        itemCount: cartItems.length,
                      ),
                    ),
                  );
                },
                child: Text(
                  'ГҮЙЛГЭЭ ХИЙХ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9C27B0), // Purple
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
