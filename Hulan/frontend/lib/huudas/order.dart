import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrderPage extends StatefulWidget {
  final List<dynamic> cartItems;
  final double totalPrice;

  const OrderPage({super.key, required this.cartItems, required this.totalPrice});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isSubmitting = false;
  final String baseUrl = "http://127.0.0.1:8000";

  Future<void> submitOrder() async {
    setState(() => isSubmitting = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Нэвтэрсэн хэрэглэгчийн токен олдсонгүй.")),
      );
      setState(() => isSubmitting = false);
      return;
    }

    try {
      final items = widget.cartItems.map((item) {
        final product = item['product'];
        return {
          "product_id": product['id'],
          "quantity": item['quantity'],
        };
      }).toList();

      final body = jsonEncode({
        "phone_number": phoneController.text,
        "shipping_address": addressController.text,
        "total_amount": widget.totalPrice,
        "items": items,
        "payment_method": "qpay",  // Хэрэглэгчийн сонгосон төлбөрийн арга
      });

      final response = await http.post(
        Uri.parse("$baseUrl/api/orders/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        // Энэ хэсэгт "Захиалга амжилттай!" гэсэн мэдэгдэл гаргаж, дэлгэцээ хаахгүй.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Захиалга амжилттай!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Алдаа: ${response.statusCode} - ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Сервертэй холбогдож чадсангүй: $e")),
      );
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Захиалгын мэдээлэл")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Нэр"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Утасны дугаар"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Хүргэх хаяг"),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Нийт дүн:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${widget.totalPrice.toStringAsFixed(2)}₮",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: isSubmitting ? null : submitOrder,
              icon: const Icon(Icons.check_circle),
              label: isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text("Захиалга илгээх", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
