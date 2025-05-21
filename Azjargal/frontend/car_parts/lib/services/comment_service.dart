import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_service.dart';

class CommentService {
  Future<List<Map<String, dynamic>>> getComments(int carPartId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.getApiUrl('car-parts/$carPartId/comments/')),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['comments']);
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> addComment(int carPartId, String text, {int? rating}) async {
    try {
      // Create the request body according to the CommentSerializer
      final Map<String, dynamic> body = {
        'text': text,
        'car_part_id': carPartId,  // Changed from 'car_part' to 'car_part_id'
      };
      
      // Only add rating if it's provided and valid
      if (rating != null && rating >= 1 && rating <= 5) {
        body['rating'] = rating;
      }

      print('Sending comment request with body: $body'); // Debug log

      final response = await http.post(
        Uri.parse(ApiService.getApiUrl('car-parts/$carPartId/comments/')),
        headers: await ApiService.getHeaders(),
        body: json.encode(body),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to add comment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updateComment(int commentId, String text, {int? rating}) async {
    try {
      final Map<String, dynamic> body = {'text': text};
      
      // Only add rating if it's provided and valid
      if (rating != null && rating >= 1 && rating <= 5) {
        body['rating'] = rating;
      }

      final response = await http.put(
        Uri.parse(ApiService.getApiUrl('comments/$commentId/')),
        headers: await ApiService.getHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to update comment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiService.getApiUrl('comments/$commentId/')),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete comment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
