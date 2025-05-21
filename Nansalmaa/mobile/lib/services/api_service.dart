import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/clothes_category.dart';

class ApiService {
  // Update this to your actual server URL
  static const String baseUrl = 'http://127.0.0.1:8000/api';  // For Android emulator
  // static const String baseUrl = 'http://localhost:8000/api';  // For iOS simulator
  final _storage = const FlutterSecureStorage();

  // Auth APIs
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password,
    String email,
    String firstName,
    String lastName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        if (errorData is Map<String, dynamic>) {
          // Handle specific error messages from the server
          final errorMessage = errorData.values.first;
          if (errorMessage is List) {
            throw Exception(errorMessage.first);
          } else if (errorMessage is String) {
            throw Exception(errorMessage);
          }
        }
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout/'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to logout');
    }
  }

  // Profile APIs
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? profileImage,
  }) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Authentication required');

    final response = await http.patch(
      Uri.parse('$baseUrl/users/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        if (profileImage != null) 'profile_image': profileImage,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(error['error'] ?? 'Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> updateProfileImage(String base64Image) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Authentication required');

    // Format the base64 image as a data URL if it's not already
    String formattedImage = base64Image;
    if (!base64Image.startsWith('data:image')) {
      formattedImage = 'data:image/jpeg;base64,$base64Image';
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/users/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'profile_image': formattedImage,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(error['error'] ?? 'Failed to update profile image');
    }
  }

  // Clothes APIs
  Future<List<Map<String, dynamic>>> getClothes({
    String? searchQuery,
    int? categoryId,
    String? gender,
  }) async {
    final queryParams = <String, String>{};
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }
    if (categoryId != null) {
      queryParams['category'] = categoryId.toString();
    }
    if (gender != null) {
      queryParams['gender'] = gender;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/clothes/').replace(queryParameters: queryParams),
      headers: {'Accept': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load clothes');
  }

  Future<List<ClothesCategory>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/'),
      headers: {'Accept': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => ClothesCategory.fromJson(json)).toList();
    }
    throw Exception('Failed to load categories');
  }

  Future<Map<String, dynamic>> getClothesById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/clothes/$id/'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load clothes details');
    }
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
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Authentication required');

    final response = await http.post(
      Uri.parse('$baseUrl/clothes/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'price': price,
        'image_base64': imageBase64,
        'phone_number': phoneNumber,
        'category': categoryId,
        'gender': gender,
        'condition': condition,
        'original_price': originalPrice,
        'size': size,
        'brand': brand,
        'available_for_pickup': availableForPickup,
        'pickup_location': pickupLocation,
        'shipping_cost': shippingCost,
        'reason_for_sale': reasonForSale,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add clothes: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getMyListings() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/clothes/my_listings/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to load my listings');
    }
  }

  // Cart APIs
  Future<List<Map<String, dynamic>>> getCart() async {
    final token = await _storage.read(key: 'token');
    final sessionId = await _storage.read(key: 'session_id');

    final response = await http.get(
      Uri.parse('$baseUrl/cart/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (sessionId != null) 'X-Session-ID': sessionId,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));

      final newSessionId = response.headers['x-session-id'];
      if (newSessionId != null) {
        await _storage.write(key: 'session_id', value: newSessionId);
      }

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data.containsKey('items')) {
        return List<Map<String, dynamic>>.from(data['items']);
      } else if (data is Map && data.containsKey('cart_items')) {
        return List<Map<String, dynamic>>.from(data['cart_items']);
      }

      throw Exception('Unexpected cart data format');
    } else if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else {
      throw Exception('Failed to load cart: ${response.statusCode}');
    }
  }

  Future<void> addToCart(int clothesId) async {
    final token = await _storage.read(key: 'token');
    final sessionId = await _storage.read(key: 'session_id');

    final response = await http.post(
      Uri.parse('$baseUrl/cart/add/'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        if (sessionId != null) 'X-Session-ID': sessionId,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'clothes_id': clothesId,
      }),
    );

    if (response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to add to cart');
    }

    final newSessionId = response.headers['x-session-id'];
    if (newSessionId != null) {
      await _storage.write(key: 'session_id', value: newSessionId);
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    final token = await _storage.read(key: 'token');
    final sessionId = await _storage.read(key: 'session_id');

    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$cartItemId/remove/'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        if (sessionId != null) 'X-Session-ID': sessionId,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to remove from cart');
    }
  }

  Future<void> updateCartItemQuantity(int cartItemId, int quantity) async {
    final token = await _storage.read(key: 'token');
    final sessionId = await _storage.read(key: 'session_id');

    final response = await http.put(
      Uri.parse('$baseUrl/cart/$cartItemId/update_quantity/'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        if (sessionId != null) 'X-Session-ID': sessionId,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to update quantity');
    }
  }

  // Order APIs
  Future<List<Map<String, dynamic>>> getOrders() async {
    final token = await _storage.read(key: 'token');
    final sessionId = await _storage.read(key: 'session_id');

    final response = await http.get(
      Uri.parse('$baseUrl/orders/'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        if (sessionId != null) 'X-Session-ID': sessionId,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<Map<String, dynamic>> createOrder(
      int cartId, Map<String, String> shippingDetails) async {
    final token = await _storage.read(key: 'token');
    final sessionId = await _storage.read(key: 'session_id');

    final response = await http.post(
      Uri.parse('$baseUrl/orders/'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        if (sessionId != null) 'X-Session-ID': sessionId,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'cart_id': cartId,
        'shipping_name': shippingDetails['name'],
        'shipping_phone': shippingDetails['phone'],
        'shipping_address': shippingDetails['address'],
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to create order');
    }
  }

  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    final token = await _storage.read(key: 'token');
    final sessionId = await _storage.read(key: 'session_id');

    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId/'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        if (sessionId != null) 'X-Session-ID': sessionId,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load order details');
    }
  }

  Future<Map<String, dynamic>> buyClothes(int clothesId) async {
    final token = await _storage.read(key: 'token');
    if (token == null) throw Exception('Authentication required');

    final response = await http.post(
      Uri.parse('$baseUrl/clothes/$clothesId/buy/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to buy item');
    }
  }
}
