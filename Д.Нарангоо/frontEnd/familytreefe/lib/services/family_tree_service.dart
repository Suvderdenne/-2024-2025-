import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/family_member.dart';

class FamilyTreeService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<void> addRelationship(FamilyMember member) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/relationship/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from_person_id': member.fromPersonId,
          'to_person_id': member.uid,
          'relationship_type': member.relationshipType,
        }),
      );

      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Relationship added successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to add relationship: ${response.body}');
        }
        throw Exception('Failed to add relationship: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding relationship: $e');
      }
      throw Exception('Error adding relationship: $e');
    }
  }
}
