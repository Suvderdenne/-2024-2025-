import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class CartService {
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Нэвтрээгүй байна. Нэвтрнэ үү');
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/cart/clear/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Сагс цэвэрлэхэд алдаа гарлаа');
      }
    } catch (e) {
      // Even if there's an error, we'll still proceed with navigation
      // The cart will be cleared on the next login
      print('Cart clearing error: $e');
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Нэвтрээгүй байна. Нэвтрнэ үү');
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cartItem}$itemId/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Бараа устгахад алдаа гарлаа: ${response.body}');
      }
    } catch (e) {
      throw Exception('Бараа устгахад алдаа гарлаа: $e');
    }
  }

  Future<void> updateQuantity(int itemId, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Нэвтрээгүй байна. Нэвтрнэ үү');
      }

      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cartItem}$itemId/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'quantity': quantity}),
      );

      if (response.statusCode != 200) {
        throw Exception('Тоо ширхэг шинэчлэхэд алдаа гарлаа: ${response.body}');
      }
    } catch (e) {
      throw Exception('Тоо ширхэг шинэчлэхэд алдаа гарлаа: $e');
    }
  }
} 