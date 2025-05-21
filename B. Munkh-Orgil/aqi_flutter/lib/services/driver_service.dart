import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DriverService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Map<String, dynamic>>> getDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/drivers/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Холбогдоход хэт удаан байна. Интернэт холболтоо шалгана уу.');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((driver) {
          return {
            'first_name': driver['first_name'] ?? 'Нэргүй',
            'last_name': driver['last_name'] ?? '',
            'phone_number': driver['phone_number'] ?? '',
            'license_number': driver['license_number'] ?? '',
            'location': driver['location'] ?? 'Байршил тодорхойгүй',
            'lat': driver['latitude']?.toDouble() ?? 47.921,
            'lng': driver['longitude']?.toDouble() ?? 106.920,
            'rating': 4.8,
            'car': 'Toyota Prius',
            'is_verified': driver['is_verified'] ?? false,
            'profile_photo': driver['profile_photo'],
          };
        }).toList();
      } else {
        throw Exception('Жолооч нарын мэдээлэл авахад алдаа гарлаа');
      }
    } on http.ClientException {
      throw Exception('Сервертэй холбогдох боломжгүй байна. Интернэт холболтоо шалгана уу.');
    } on FormatException {
      throw Exception('Серверээс буруу хариу ирлээ');
    } catch (e) {
      throw Exception('Алдаа гарлаа: $e');
    }
  }

  Future<Map<String, dynamic>?> getDriverById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/drivers/$id/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'first_name': data['first_name'] ?? 'Нэргүй',
          'last_name': data['last_name'] ?? '',
          'phone_number': data['phone_number'] ?? '',
          'license_number': data['license_number'] ?? '',
          'location': data['location'] ?? 'Байршил тодорхойгүй',
          'lat': data['latitude']?.toDouble() ?? 47.921,
          'lng': data['longitude']?.toDouble() ?? 106.920,
          'rating': 4.8,
          'car': 'Toyota Prius',
          'is_verified': data['is_verified'] ?? false,
          'profile_photo': data['profile_photo'],
        };
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Жолоочийн мэдээлэл авахад алдаа гарлаа');
      }
    } catch (e) {
      throw Exception('Алдаа гарлаа: $e');
    }
  }
} 