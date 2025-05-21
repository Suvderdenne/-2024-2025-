import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_service.dart';

class ProfileService {
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.getApiUrl('profile/')),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.getApiUrl('profile/$userId/')),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? phoneNumber,
    String? address,
    String? bio,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      
      if (phoneNumber != null) body['phone_number'] = phoneNumber;
      if (address != null) body['address'] = address;
      if (bio != null) body['bio'] = bio;

      final response = await http.put(
        Uri.parse(ApiService.getApiUrl('profile/')),
        headers: await ApiService.getHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updateProfilePicture(String base64Image) async {
    try {
      final response = await http.put(
        Uri.parse(ApiService.getApiUrl('profile/')),
        headers: await ApiService.getHeaders(),
        body: json.encode({
          'profile_picture': base64Image,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to update profile picture');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 