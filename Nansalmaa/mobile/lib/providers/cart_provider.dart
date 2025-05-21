import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  // Add total getter
  double get total {
    return _cartItems.fold<double>(
      0,
      (sum, item) {
        final clothes = item['clothes'] as Map<String, dynamic>?;
        if (clothes == null) return sum;
        
        final price = (clothes['price'] is String)
            ? double.tryParse(clothes['price']) ?? 0.0
            : (clothes['price'] as num?)?.toDouble() ?? 0.0;
            
        final quantity = item['quantity'] as int? ?? 1;
        return sum + (price * quantity);
      },
    );
  }

  /// Check if an item is in the cart
  bool isInCart(int clothesId) {
    return _cartItems.any((item) => item['clothes']['id'] == clothesId);
  }

  Future<void> loadCart(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // print('Loading cart...'); // Debug print
      final response = await _apiService.getCart();
      // print('Cart loaded from API: $response'); // Debug print
      
      if (response.isEmpty) {
        // print('Cart is empty'); // Debug print
        _cartItems = [];
      } else {
        // print('Setting cart items: $response'); // Debug print
        _cartItems = response;
      }
      
      print('Final cart items: $_cartItems'); // Debug print
    } catch (e, stackTrace) {
      print('Error loading cart: $e'); // Debug print
      print('Stack trace: $stackTrace'); // Debug stack trace
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load cart: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(BuildContext context, int clothesId) async {
    try {
      print('Adding item $clothesId to cart...'); // Debug print
      await _apiService.addToCart(clothesId);
      print('Item added to cart, reloading cart...'); // Debug print
      await loadCart(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to cart successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding to cart: $e'); // Debug print
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> removeFromCart(BuildContext context, int cartItemId) async {
    try {
      print('Removing item $cartItemId from cart...'); // Debug print
      await _apiService.removeFromCart(cartItemId);
      print('Item removed from cart, reloading cart...'); // Debug print
      await loadCart(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from cart successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error removing from cart: $e'); // Debug print
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove from cart: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> updateQuantity(BuildContext context, int cartItemId, int quantity) async {
    try {
      print('Updating quantity for item $cartItemId to $quantity...'); // Debug print
      await _apiService.updateCartItemQuantity(cartItemId, quantity);
      print('Quantity updated, reloading cart...'); // Debug print
      await loadCart(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quantity updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating quantity: $e'); // Debug print
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update quantity: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 