import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class AuthService {
  // For Android emulator
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  // For iOS simulator
  // static const String baseUrl = 'http://localhost:8000/api';
  // For physical device (replace with your computer's IP address)
  // static const String baseUrl = 'http://192.168.1.X:8000/api';

  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/'),
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Холбогдоход хэт удаан байна. Интернэт холболтоо шалгана уу.');
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': phoneNumber,
          'password': password,
        }),
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Холбогдоход хэт удаан байна. Интернэт холболтоо шалгана уу.');
        },
      );

      final data = json.decode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Алдаа гарлаа');
      }
    } on SocketException {
      throw Exception('Сервертэй холбогдох боломжгүй байна. Интернэт холболтоо шалгана уу.');
    } on FormatException {
      throw Exception('Серверээс буруу хариу ирлээ');
    } catch (e) {
      throw Exception('Сервертэй холбогдоход алдаа гарлаа: $e');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String carModel,
    required String carPlate,
    String location = 'Ulaanbaatar',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'full_name': name,
          'phone_number': phone,
          'email': email,
          'password': password,
          'password_confirm': password,
          'car_model': carModel,
          'car_plate': carPlate,
          'location': location,
        }),
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Холбогдоход хэт удаан байна. Интернэт холболтоо шалгана уу.');
        },
      );

      final data = json.decode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Алдаа гарлаа');
      }
    } on SocketException {
      throw Exception('Сервертэй холбогдох боломжгүй байна. Интернэт холболтоо шалгана уу.');
    } on FormatException {
      throw Exception('Серверээс буруу хариу ирлээ');
    } catch (e) {
      throw Exception('Сервертэй холбогдоход алдаа гарлаа: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String carModel,
    required String carPlate,
    File? profileImage,
  }) async {
    try {
      // Create a multipart request
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/users/update/'),
      );

      // Add text fields
      request.fields['full_name'] = name;
      request.fields['phone_number'] = phone;
      request.fields['email'] = email;
      request.fields['car_model'] = carModel;
      request.fields['car_plate'] = carPlate;

      // Add image file if provided
      if (profileImage != null) {
        var file = await http.MultipartFile.fromPath(
          'profile_photo',
          profileImage.path,
        );
        request.files.add(file);
      }

      // Send the request
      var streamedResponse = await request.send().timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Холбогдоход хэт удаан байна. Интернэт холболтоо шалгана уу.');
        },
      );

      // Get the response
      var response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Профайл амжилттай шинэчлэгдлээ',
          'user': data,
        };
      } else {
        throw Exception(data['message'] ?? 'Алдаа гарлаа');
      }
    } on SocketException {
      throw Exception('Сервертэй холбогдох боломжгүй байна. Интернэт холболтоо шалгана уу.');
    } on FormatException {
      throw Exception('Серверээс буруу хариу ирлээ');
    } catch (e) {
      throw Exception('Сервертэй холбогдоход алдаа гарлаа: $e');
    }
  }
} 