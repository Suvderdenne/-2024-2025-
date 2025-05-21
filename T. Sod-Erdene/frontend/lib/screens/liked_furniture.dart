import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../auth_service.dart';
import '../routes.dart';
import 'furniture_detail.dart';

class LikedFurniture extends StatefulWidget {
  const LikedFurniture({super.key});

  @override
  State<LikedFurniture> createState() => _LikedFurnitureState();
}

class _LikedFurnitureState extends State<LikedFurniture> {
  bool _isLoading = true; // Татаж байгааг илтгэнэ
  List<dynamic> _likedFurniture = []; // Таалагдсан тавилгуудын жагсаалт
  String? _errorMessage; // Алдааны мессеж

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadLikes(); // эхэлмэгц хэрэглэгч нэвтэрсэн эсэх болон like өгөгдлийг татах
  }

  // Хэрэглэгч нэвтэрсэн эсэхийг шалгаж, таалагдсан тавилгуудыг татах
  Future<void> _checkAuthAndLoadLikes() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }
      await _loadLikedFurniture();
    } catch (e) {
      setState(() {
        _errorMessage = 'Алдаа гарлаа: $e';
        _isLoading = false;
      });
    }
  }

  // API ашиглан таалагдсан тавилгуудыг татах
  Future<void> _loadLikedFurniture() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Нэвтрэлт шаардлагатай';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/furniture/liked/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _likedFurniture = jsonDecode(response.body);
          _isLoading = false;
        });
      } else if (response.statusCode == 401 && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        setState(() {
          _errorMessage = 'Таалагдсан тавилга ачаалахад алдаа гарлаа';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Серверээс мэдээлэл авахад алдаа гарлаа: $e';
        _isLoading = false;
      });
    }
  }

  // Тухайн тавилгын like/унlike үйлдлийг хийх
  Future<void> _toggleLike(int furnitureId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Эхлээд нэвтэрнэ үү')));
        return;
      }

      final response = await http.post(
        Uri.parse(
          'http://127.0.0.1:8000/api/furniture/$furnitureId/toggle_like/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token', // Токен зөв байгаа эсэхийг шалга
        },
      );

      if (response.statusCode == 200) {
        await _loadLikedFurniture(); // like-ийн дараа жагсаалтыг дахин ачаална
      } else if (response.statusCode == 401 && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Like солих үед алдаа гарлаа')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Алдаа: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_likedFurniture.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Таалагдсан бүтээгдэхүүн байхгүй байна',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _likedFurniture.length,
      itemBuilder: (context, index) {
        final item = _likedFurniture[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => FurnitureDetail(
                        furnitureItem: FurnitureItem.fromMap(item), onAddToCart: (FurnitureItem item, int quantity) {  },
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(item['pic'].split(',').last),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${item['price']}₮',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _toggleLike(item['id']),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
