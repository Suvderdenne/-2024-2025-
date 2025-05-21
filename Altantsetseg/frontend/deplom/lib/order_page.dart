import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'payment_page.dart';
import 'profile.dart';

class OrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;

  const OrderPage({
    super.key,
    required this.cartItems,
    required this.totalPrice,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String selectedPaymentMethod = "QPay";

  late List<Map<String, dynamic>> localCart;
  bool _isLoading = false;
  bool _isSubmitted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    localCart = List<Map<String, dynamic>>.from(widget.cartItems);
  }

  String get _baseUrl => 'http://127.0.0.1:8000';

  double get totalPrice =>
      localCart.fold(0.0, (sum, item) => sum + (item['price'] ?? 0));

  Future<String?> getValidAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? access = prefs.getString('access');
    String? refresh = prefs.getString('refresh');

    if (access == null || refresh == null) return null;

    final validateResponse = await http.post(
      Uri.parse('$_baseUrl/api/token/verify/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"token": access}),
    );

    if (validateResponse.statusCode == 200) {
      return access;
    } else {
      final refreshResponse = await http.post(
        Uri.parse('$_baseUrl/api/token/refresh/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": refresh}),
      );
      if (refreshResponse.statusCode == 200) {
        final data = jsonDecode(refreshResponse.body);
        String newAccess = data['access'];
        await prefs.setString('access', newAccess);
        return newAccess;
      } else {
        return null;
      }
    }
  }

  void removeItem(int index) {
    setState(() {
      localCart.removeAt(index);
    });
  }

  bool isValidMongolianAddress(String address) {
    final keywords = ['улаанбаатар', 'монгол', 'дүүрэг', 'сум', 'аймаг'];
    address = address.toLowerCase();
    return keywords.any((keyword) => address.contains(keyword));
  }

  Future<void> submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = await getValidAccessToken();
    if (token == null) {
      setState(() {
        _errorMessage = 'Нэвтрэх хугацаа дууссан байна. Дахин нэвтэрнэ үү.';
        _isLoading = false;
      });
      return;
    }

    final orderData = {
      "customer_name": _nameController.text.trim(),
      "phone_number": _phoneController.text.trim(),
      "delivery_address": _addressController.text.trim(),
      "payment_method": selectedPaymentMethod,
      "total_amount": totalPrice,
      "items": localCart.map((item) {
        return {
          "product_id": item['id'],
          "quantity": item['quantity'] ?? 1,
        };
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/order/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        final existingOrders = prefs.getStringList('order_history') ?? [];
        for (var item in localCart) {
          existingOrders.add(jsonEncode(item));
        }
        await prefs.setStringList('order_history', existingOrders);

        setState(() {
          _isSubmitted = true;
        });
      } else {
        setState(() {
          _errorMessage = 'Алдаа: ${utf8.decode(response.bodyBytes)}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Сүлжээний алдаа: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text("Захиалга баталгаажуулах"),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Text('Цэс', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Профайл'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              if (_isSubmitted)
                Column(
                  children: [
                    const Icon(Icons.check_circle, size: 80, color: Colors.green),
                    const SizedBox(height: 10),
                    const Text("Захиалга амжилттай!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentPage(method: selectedPaymentMethod, amount: totalPrice),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Төлбөр төлөх'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7043),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              if (!_isSubmitted) buildOrderForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderForm() {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField(
                controller: _nameController,
                label: "Нэр",
                icon: Icons.person,
                validator: (value) => (value == null || value.isEmpty) ? "Нэр заавал оруулна уу" : null,
              ),
              const SizedBox(height: 12),
              buildTextField(
                controller: _phoneController,
                label: "Утас",
                icon: Icons.phone,
                type: TextInputType.phone,
                validator: (value) => (value == null || value.isEmpty) ? "Утас оруулна уу" : null,
              ),
              const SizedBox(height: 12),
              buildTextField(
                controller: _addressController,
                label: "Хаяг",
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Хаяг оруулна уу";
                  if (!isValidMongolianAddress(value)) return "Монгол улсын хаяг оруулна уу";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPaymentMethod,
                decoration: InputDecoration(
                  labelText: "Төлбөрийн хэлбэр",
                  prefixIcon: const Icon(Icons.payment),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: "QPay", child: Text("QPay")),
                  DropdownMenuItem(value: "Данс", child: Text("Данс")),
                  DropdownMenuItem(value: "Бэлэн", child: Text("Бэлэн")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedPaymentMethod = value);
                  }
                },
                validator: (value) => value == null ? "Төлбөрийн хэлбэр сонгоно уу" : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const Text("Захиалсан бараа", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...localCart.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return ListTile(
            title: Text(item['name']),
            subtitle: Text("₮${item['price']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("x${item['quantity'] ?? 1}"),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => removeItem(index),
                ),
              ],
            ),
          );
        }).toList(),
        const Divider(),
        Text("Нийт дүн: ₮${totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _isLoading || localCart.isEmpty ? null : submitOrder,
          icon: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.send),
          label: Text(_isLoading ? 'Илгээж байна...' : 'Захиалга илгээх'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7043),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
