import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_member.dart';

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000/api";
  String? _token;
  Map<String, dynamic>? _userInfo;
  static const String _tokenKey = 'auth_token';
  static const String _userInfoKey = 'user_info';

  // Getter for token
  String? get token => _token;

  // Initialize shared preferences and load token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final userInfoString = prefs.getString(_userInfoKey);
    if (userInfoString != null) {
      _userInfo = json.decode(userInfoString);
    }
  }

  // Save token and user info to shared preferences
  Future<void> _saveUserData(
    String token,
    Map<String, dynamic> userInfo,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userInfoKey, json.encode(userInfo));
    _token = token;
    _userInfo = userInfo;
  }

  // Clear user data from shared preferences
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userInfoKey);
    _token = null;
    _userInfo = null;
  }

  // Get current user info
  Map<String, dynamic>? get userInfo => _userInfo;

  // Check if user is logged in
  bool isLoggedIn() {
    return _token != null;
  }

  // Register method
  Future<bool> register(
    String username,
    String email,
    String password,
    String repassword,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": _token != null ? "Bearer $_token" : "",
      },
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "repassword": repassword,
      }),
    );
    try {
      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response Body: ${json.decode(utf8.decode(response.bodyBytes))}');
      }
      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Бүртгэл амжилттай!');
        }
        return true; // Registration successful
      } else if (response.statusCode == 400) {
        var errorData = jsonDecode(response.body);
        if (kDebugMode) {
          print(errorData['error'] ?? 'Бүртгэл амжилтгүй. Давтан оролдоно уу');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Бүртгэлийн үйл явцад алдаа гарлаа: $e");
      }
      return false; // Handle any connection or other issues
    }
    return false; // Ensure a return value in all cases
  }

  // Login method
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login/"),
        body: jsonEncode({"username": username, "password": password}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          print('Response Status: ${response.statusCode}');
          print("Logged in! Response data: $data");
        }

        // Check if token exists in response
        if (data['token'] != null) {
          // Create user info object
          final userInfo = {
            'username': username,
            'uid': data['uid'],
            'email': data['email'] ?? '',
          };

          if (kDebugMode) {
            print("Saving user info: $userInfo");
          }

          await _saveUserData(data['token'], userInfo);
          return true;
        } else {
          if (kDebugMode) {
            print("No token received in response");
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print("Login failed with status: ${response.statusCode}");
          print(
            "Response body: ${json.decode(utf8.decode(response.bodyBytes))}",
          );
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login error: $e");
      }
      return false;
    }
  }

  Future<bool> logout() async {
    if (_token != null) {
      try {
        final response = await http.post(
          Uri.parse("$baseUrl/logout/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Token $_token",
          },
        );

        if (response.statusCode == 200) {
          await clearUserData();
          return true;
        } else {
          if (kDebugMode) {
            print("Logout failed with status: ${response.statusCode}");
            print("Response body: ${response.body}");
          }
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Logout error: $e");
        }
        return false;
      }
    } else {
      await clearUserData(); // fallback clear
      return true;
    }
  }

  Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    if (uid.isEmpty) {
      if (kDebugMode) {
        print('Error: Empty UID provided to fetchProfile');
      }
      return null;
    }

    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return null;
    }
    if (kDebugMode) {
      print('Fetching profile from URL: $baseUrl/profile/$uid/');
    }
    final url = Uri.parse("$baseUrl/profile/$uid/");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token", // Ensure token is correct here
        },
      );

      if (response.statusCode == 200) {
        final profileData = json.decode(utf8.decode(response.bodyBytes));
        return profileData;
      } else {
        if (kDebugMode) {
          print("Failed to fetch profile: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return null; // Handle failure
      }
    } catch (e) {
      if (kDebugMode) {
        print("Profile fetch error: $e");
      }
      return null;
    }
  }

  Future<bool> createOrUpdatePerson(Map<String, dynamic> personData) async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return false;
    }

    if (_userInfo == null || _userInfo!['uid'] == null) {
      if (kDebugMode) {
        print('Error: No user info available');
      }
      return false;
    }

    final url = Uri.parse("$baseUrl/profile/${_userInfo!['uid']}/");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
        body: jsonEncode(personData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          print("Failed to create/update person: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Create/update person error: $e");
      }
      return false;
    }
  }

  Future<bool> deleteUser(String uid) async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/profile/$uid/delete/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        await clearUserData();
        return true;
      } else {
        if (kDebugMode) {
          print("Failed to delete user: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Delete user error: $e");
      }
      return false;
    }
  }

  Future<List<FamilyMember>> getFamilyMembers() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    if (_userInfo == null || _userInfo!['uid'] == null) {
      if (kDebugMode) {
        print('Error: No user info available');
        print('User info: $_userInfo');
      }
      return [];
    }

    try {
      if (kDebugMode) {
        print('Fetching family members for user: ${_userInfo!['uid']}');
      }

      // First get the user's profile to get their person
      final profile = await fetchProfile(_userInfo!['uid']);
      if (profile == null) {
        if (kDebugMode) {
          print('Profile not found for user: ${_userInfo!['uid']}');
        }
        return [];
      }

      if (kDebugMode) {
        print('User profile found: $profile');
      }

      // Get family members using the user's UID directly
      final response = await http.get(
        Uri.parse("$baseUrl/family/${_userInfo!['uid']}/list/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (kDebugMode) {
        print('Family members API response status: ${response.statusCode}');
        print(
          'Family members API response body: ${utf8.decode(response.bodyBytes)}',
        );
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        List<FamilyMember> members = [];

        // Add the user's own information first
        if (profile['person'] != null) {
          if (kDebugMode) {
            print('Adding user\'s own information to members list');
          }
          members.add(
            FamilyMember(
              fromPersonId: _userInfo!['uid'],
              uid: profile['person']['uid'] ?? '',
              relationshipType: 'ӨӨРӨӨ',
              name: profile['person']['name'],
              lastname: profile['person']['lastname'],
              gender: profile['person']['gender'],
              birthdate: DateTime.parse(profile['person']['birthdate']),
              diedate:
                  profile['person']['diedate'] != null
                      ? DateTime.parse(profile['person']['diedate'])
                      : null,
              biography: profile['person']['biography'],
              birthplace:
                  profile['person']['birthplace'] != null
                      ? {
                        'uid': profile['person']['birthplace']['uid'],
                        'name': profile['person']['birthplace']['name'],
                        'country': profile['person']['birthplace']['country'],
                      }
                      : null,
              generation:
                  profile['person']['generation'] != null
                      ? {
                        'uid': profile['person']['generation']['uid'],
                        'uyname': profile['person']['generation']['uyname'],
                        'level': profile['person']['generation']['level'],
                      }
                      : null,
              urgiinovog:
                  profile['person']['urgiinovog'] != null
                      ? {
                        'uid': profile['person']['urgiinovog']['uid'],
                        'urgiinovog':
                            profile['person']['urgiinovog']['urgiinovog'],
                      }
                      : null,
            ),
          );
        }

        // Convert all family members to a flat list
        data.forEach((relationship, people) {
          if (kDebugMode) {
            print('Processing relationship type: $relationship');
            print('Number of people in this relationship: ${people.length}');
          }
          for (var person in people) {
            if (kDebugMode) {
              print(
                'Adding family member: ${person['name']} with relationship: $relationship',
              );
            }
            members.add(
              FamilyMember(
                fromPersonId: _userInfo!['uid'],
                uid: person['uid'] ?? '',
                relationshipType: relationship,
                name: person['name'],
                lastname: person['lastname'],
                gender: person['gender'],
                birthdate: DateTime.parse(person['birthdate']),
                diedate:
                    person['diedate'] != null
                        ? DateTime.parse(person['diedate'])
                        : null,
                biography: person['biography'],
                birthplace:
                    person['birthplace'] != null
                        ? {
                          'uid': person['birthplace']['uid'],
                          'name': person['birthplace']['name'],
                          'country': person['birthplace']['country'],
                        }
                        : null,
                generation:
                    person['generation'] != null
                        ? {
                          'uid': person['generation']['uid'],
                          'uyname': person['generation']['uyname'],
                          'level': person['generation']['level'],
                        }
                        : null,
                urgiinovog:
                    person['urgiinovog'] != null
                        ? {
                          'uid': person['urgiinovog']['uid'],
                          'urgiinovog': person['urgiinovog']['urgiinovog'],
                        }
                        : null,
              ),
            );
          }
        });

        // Process children to determine their actual parent
        final siblings =
            members
                .where(
                  (m) =>
                      m.relationshipType == 'АХ' ||
                      m.relationshipType == 'ЭГЧ' ||
                      m.relationshipType == 'ДҮҮ',
                )
                .toList();

        // First, collect all children
        final allChildren =
            members.where((m) => m.relationshipType == 'ХҮҮХЭД').toList();

        // Then, for each child, determine if they belong to a sibling
        for (var child in allChildren) {
          // Find the sibling that this child belongs to
          final parentSibling = siblings.firstWhere(
            (sibling) => child.fromPersonId == sibling.uid,
            orElse: () => members.first,
          );

          // If the child belongs to a sibling, update their relationship
          if (parentSibling.relationshipType != 'ӨӨРӨӨ') {
            child.relationshipType =
                '${parentSibling.relationshipType}ИЙН ХҮҮХЭД';
            child.fromPersonId = parentSibling.uid;
            if (kDebugMode) {
              print(
                'Updated child ${child.name} to be child of ${parentSibling.name}',
              );
            }
          }
        }

        if (kDebugMode) {
          print('Total family members loaded: ${members.length}');
        }
        return members;
      } else {
        if (kDebugMode) {
          print("Failed to load family members: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching family members: $e");
      }
      return [];
    }
  }

  Future<bool> createFamilyMember(FamilyMember member) async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return false;
    }

    try {
      // Format the data according to the API requirements
      final requestData = {
        'from_person_id': member.fromPersonId,
        'relationship_type': member.relationshipType,
        'name': member.name,
        'lastname': member.lastname,
        'gender': member.gender,
        'birthdate':
            member.birthdate.toIso8601String().split(
              'T',
            )[0], // Format as YYYY-MM-DD
        'diedate': member.diedate?.toIso8601String().split('T')[0],
        'biography': member.biography,
      };

      // Add birthplace if available
      if (member.birthplace != null) {
        requestData['place_id'] = member.birthplace!['uid'];
      }

      // Add generation (uye) if available
      if (member.generation != null) {
        requestData['uye_id'] = member.generation!['uid'];
      }

      // Add urgiinovog if available
      if (member.urgiinovog != null) {
        requestData['urgiinovog_id'] = member.urgiinovog!['uid'];
      }

      if (kDebugMode) {
        print('Sending request data: $requestData');
      }

      final response = await http.post(
        Uri.parse("$baseUrl/family/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
        body: json.encode(requestData),
      );

      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
        print('Response body: ${utf8.decode(response.bodyBytes)}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print('Error response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating family member: $e');
      }
      return false;
    }
  }

  Future<bool> updateFamilyMember(FamilyMember member) async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return false;
    }

    try {
      // Format the data according to the API requirements
      final requestData = {
        'name': member.name,
        'lastname': member.lastname,
        'gender': member.gender,
        'birthdate':
            member.birthdate.toIso8601String().split(
              'T',
            )[0], // Format as YYYY-MM-DD
        'diedate': member.diedate?.toIso8601String().split('T')[0],
        'biography': member.biography,
      };

      // Add birthplace if available
      if (member.birthplace != null) {
        requestData['place_id'] = member.birthplace!['uid'];
      }

      // Add generation (uye) if available
      if (member.generation != null) {
        requestData['uye_id'] = member.generation!['uid'];
      }

      // Add urgiinovog if available
      if (member.urgiinovog != null) {
        requestData['urgiinovog_id'] = member.urgiinovog!['uid'];
      }

      if (kDebugMode) {
        print('Sending update request data: $requestData');
        print('Member UID: ${member.uid}');
      }

      // Check if member.uid is empty or null
      if (member.uid.isEmpty) {
        if (kDebugMode) {
          print('Error: Member UID is empty');
        }
        return false;
      }

      final response = await http.put(
        Uri.parse("$baseUrl/family/${member.uid}/update/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
        body: json.encode(requestData),
      );

      if (kDebugMode) {
        print('Update response status code: ${response.statusCode}');
        print('Update response body: ${utf8.decode(response.bodyBytes)}');
      }

      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print('Error response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating family member: $e');
      }
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPlaces() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/places/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map(
              (item) => {
                'uid': item['uid'],
                'name': item['name'],
                'country': item['country'],
              },
            )
            .toList();
      } else {
        if (kDebugMode) {
          print("Failed to load places: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching places: $e");
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUye() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/uye/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map(
              (item) => {
                'uid': item['uid'],
                'uyname': item['uyname'],
                'level': item['level'],
              },
            )
            .toList();
      } else {
        if (kDebugMode) {
          print("Failed to load uye: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching uye: $e");
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUrgiinOvog() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/urgiinovog/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map(
              (item) => {'uid': item['uid'], 'urgiinovog': item['urgiinovog']},
            )
            .toList();
      } else {
        if (kDebugMode) {
          print("Failed to load urgiin ovog: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching urgiin ovog: $e");
      }
      return [];
    }
  }

  Future<List<FamilyMember>> getClanMembers(String clanId) async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/urgiinovog/$clanId/members/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final members =
            data.map((person) {
              Map<String, dynamic>? birthplace;
              if (person['birthplace'] != null) {
                birthplace = {
                  'uid': person['birthplace']['uid'],
                  'name': person['birthplace']['name'],
                  'country': person['birthplace']['country'],
                };
              }

              Map<String, dynamic>? generation;
              if (person['generation'] != null) {
                generation = {
                  'uid': person['generation']['uid'],
                  'uyname': person['generation']['uyname'],
                  'level': person['generation']['level'],
                };
              }

              Map<String, dynamic>? urgiinovog;
              if (person['urgiinovog'] != null) {
                urgiinovog = {
                  'uid': person['urgiinovog']['uid'],
                  'urgiinovog': person['urgiinovog']['urgiinovog'],
                };
              }

              return FamilyMember(
                fromPersonId: person['uid'],
                uid: person['uid'],
                relationshipType: 'НЭГДСЭНГҮЙ',
                name: person['name'],
                lastname: person['lastname'],
                gender: person['gender'],
                birthdate: DateTime.parse(person['birthdate']),
                diedate:
                    person['diedate'] != null
                        ? DateTime.parse(person['diedate'])
                        : null,
                biography: person['biography'],
                birthplace: birthplace,
                generation: generation,
                urgiinovog: urgiinovog,
              );
            }).toList();

        if (kDebugMode) {
          print('Total clan members loaded: ${members.length}');
        }
        return members;
      } else {
        if (kDebugMode) {
          print("Failed to load clan members: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching clan members: $e");
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRelationshipTypes() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/relationship-types/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map((item) => {'type': item['type'], 'label': item['label']})
            .toList();
      } else {
        if (kDebugMode) {
          print("Failed to load relationship types: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching relationship types: $e");
      }
      return [];
    }
  }

  Future<bool> addRelationship({
    required String fromPersonId,
    required String toPersonId,
    required String relationshipType,
  }) async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return false;
    }

    if (kDebugMode) {
      print('Adding relationship with:');
      print('fromPersonId: $fromPersonId');
      print('toPersonId: $toPersonId');
      print('relationshipType: $relationshipType');
    }

    final url = Uri.parse("$baseUrl/relationship/");

    try {
      // Create the request data with the exact field names expected by the backend
      final requestData = {
        'from_person_id': fromPersonId,
        'to_person_id': toPersonId,
        'relationship_type': relationshipType,
      };

      if (kDebugMode) {
        print('Sending request data: $requestData');
      }

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
        body: jsonEncode(requestData),
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${utf8.decode(response.bodyBytes)}');
      }

      if (response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          print("Failed to add relationship: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Add relationship error: $e");
      }
      return false;
    }
  }

  Future<bool> createSimplePerson(Map<String, dynamic> personData) async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/simple-person/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
        body: json.encode(personData),
      );

      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
        print('Response body: ${utf8.decode(response.bodyBytes)}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print('Error response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating simple person: $e');
      }
      return false;
    }
  }

  Future<List<FamilyMember>> getAllPeople() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    try {
      // First get all people
      final response = await http.get(
        Uri.parse("$baseUrl/simple-person/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        // Then get family members to check relationships
        final familyMembers = await getFamilyMembers();

        // Create a map of UIDs to relationship types
        final Map<String, String> relationshipMap = {};
        for (var member in familyMembers) {
          relationshipMap[member.uid] = member.relationshipType;
        }

        return data.map((person) {
          final String relationshipType =
              relationshipMap[person['uid']] ?? 'НЭГДСЭНГҮЙ';
          return FamilyMember(
            fromPersonId: _userInfo!['uid'],
            uid: person['uid'],
            relationshipType: relationshipType,
            name: person['name'],
            lastname: person['lastname'],
            gender: person['gender'],
            birthdate: DateTime.parse(person['birthdate']),
            diedate:
                person['diedate'] != null
                    ? DateTime.parse(person['diedate'])
                    : null,
            biography: person['biography'],
            birthplace: person['birthplace'],
            generation: person['generation'],
            urgiinovog: person['urgiinovog'],
          );
        }).toList();
      } else {
        if (kDebugMode) {
          print("Failed to load all people: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching all people: $e");
      }
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserClan() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return null;
    }

    if (_userInfo == null || _userInfo!['uid'] == null) {
      if (kDebugMode) {
        print('Error: No user info available');
      }
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/${_userInfo!['uid']}/clan/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (kDebugMode) {
        print('User clan API response status: ${response.statusCode}');
        print(
          'User clan API response body: ${utf8.decode(response.bodyBytes)}',
        );
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return data;
      } else {
        if (kDebugMode) {
          print("Failed to load user clan: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user clan: $e");
      }
      return null;
    }
  }

  Future<List<FamilyMember>> getPeopleByLastName(String lastname) async {
    if (_token == null) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/people/lastname/$lastname/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (json) => FamilyMember(
                uid: json['uid'],
                name: json['name'],
                lastname: json['lastname'],
                gender: json['gender'],
                birthdate: json['birthdate'],
                diedate: json['diedate'],
                biography: json['biography'],
                birthplace:
                    json['birthplace'] != null
                        ? {
                          'uid': json['birthplace']['uid'],
                          'name': json['birthplace']['name'],
                          'country': json['birthplace']['country'],
                        }
                        : null,
                generation:
                    json['generation'] != null
                        ? {
                          'uid': json['generation']['uid'],
                          'uyname': json['generation']['uyname'],
                          'level': json['generation']['level'],
                        }
                        : null,
                relationshipType:
                    'НЭГДСЭНГҮЙ', // Default relationship type for clan members
                fromPersonId:
                    '', // Empty string since this is not a direct relationship
              ),
            )
            .toList();
      } else {
        if (kDebugMode) {
          print('Failed to get people by last name: ${response.body}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting people by last name: $e');
      }
      return [];
    }
  }

  Future<bool> deleteFamilyMember(String uid) async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/family/$uid/delete/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (kDebugMode) {
        print('Delete family member response status: ${response.statusCode}');
        print(
          'Delete family member response body: ${utf8.decode(response.bodyBytes)}',
        );
      }

      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print("Failed to delete family member: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting family member: $e");
      }
      return false;
    }
  }
}
