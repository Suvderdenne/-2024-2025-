import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/clothes_category.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class ClothesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider = AuthProvider();
  List<Map<String, dynamic>> _clothes = [];
  List<Map<String, dynamic>> _myListings = [];
  List<ClothesCategory> _categories = [];
  bool _isLoading = false;
  final String baseUrl =
      'http://127.0.0.1:8000/api'; // Update for Android emulator
  // final String baseUrl = 'http://localhost:8000/api'; // Use this for iOS simulator
  List<Map<String, dynamic>> _soldItems = [];
  List<Map<String, dynamic>> _boughtItems = [];
  List<Map<String, dynamic>> _userRatings = [];

  List<Map<String, dynamic>> get clothes => _clothes;
  List<Map<String, dynamic>> get myListings => _myListings;
  List<ClothesCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get soldItems => _soldItems;
  List<Map<String, dynamic>> get boughtItems => _boughtItems;
  List<Map<String, dynamic>> get userRatings => _userRatings;

  Future<void> loadClothes({
    String? searchQuery,
    int? categoryId,
    String? gender,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _clothes = await _apiService.getClothes(
        searchQuery: searchQuery,
        categoryId: categoryId,
        gender: gender,
      );
      await loadCategories();
    } catch (e) {
      print('Error loading clothes: $e');
      _clothes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyListings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _myListings = await _apiService.getMyListings();
    } catch (e) {
      print('Error loading my listings: $e');
      _myListings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getClothesById(int id) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await http.get(
        Uri.parse('$baseUrl/clothes/$id/'),
        headers: {'Accept': 'application/json; charset=UTF-8'},
      );
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      throw Exception('Failed to load clothes details');
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _apiService.getCategories();
      notifyListeners();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<List<ClothesCategory>> getCategories() async {
    if (_categories.isEmpty) {
      await loadCategories();
    }
    return _categories;
  }

  Future<Map<String, dynamic>> addClothes(
    String title,
    String description,
    double price,
    String imageBase64,
    String phoneNumber,
    int categoryId,
    String gender, {
    String? condition,
    double? originalPrice,
    String? size,
    String? brand,
    bool? availableForPickup,
    String? pickupLocation,
    double? shippingCost,
    String? reasonForSale,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _apiService.addClothes(
        title,
        description,
        price,
        imageBase64,
        phoneNumber,
        categoryId,
        gender,
        condition: condition,
        originalPrice: originalPrice,
        size: size,
        brand: brand,
        availableForPickup: availableForPickup,
        pickupLocation: pickupLocation,
        shippingCost: shippingCost,
        reasonForSale: reasonForSale,
      );

      // Add the new item to the clothes list
      _clothes.insert(0, response);
      
      return response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getClothes() async {
    try {
      _clothes = await _apiService.getClothes();
      notifyListeners();
    } catch (e) {
      print('Error fetching clothes: $e');
      rethrow;
    }
  }

  Future<void> buyClothes(int clothesId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.buyClothes(clothesId);
      
      // Update the item in the clothes list
      final index = _clothes.indexWhere((item) => item['id'] == clothesId);
      if (index != -1) {
        _clothes[index] = response;
      }

      // Update the item in my listings if it exists there
      final myListingIndex = _myListings.indexWhere((item) => item['id'] == clothesId);
      if (myListingIndex != -1) {
        _myListings[myListingIndex] = response;
      }

      // Make sure to notify listeners of the change
      notifyListeners();
      
      // Refresh the entire clothes list to ensure consistency
      await loadClothes();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSoldItems() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/clothes/sold/'),
        headers: {
          'Authorization': 'Token ${_authProvider.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _soldItems = List<Map<String, dynamic>>.from(data);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load sold items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading sold items: $e');
      _soldItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBoughtItems() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/clothes/bought/'),
        headers: {
          'Authorization': 'Token ${_authProvider.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _boughtItems = List<Map<String, dynamic>>.from(data);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load bought items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading bought items: $e');
      _boughtItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserRatings() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/ratings/user/'),
        headers: {
          'Authorization': 'Token ${_authProvider.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _userRatings = List<Map<String, dynamic>>.from(data);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load user ratings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading user ratings: $e');
      _userRatings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
