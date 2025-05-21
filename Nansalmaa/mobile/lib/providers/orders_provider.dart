import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrdersProvider with ChangeNotifier {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    try {
      _isLoading = true;
      notifyListeners();
      _orders = await _apiService.getOrders();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createOrder(int cartId) async {
    try {
      _isLoading = true;
      notifyListeners();
      final order = await _apiService.createOrder(cartId);
      await loadOrders();
      return order;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
