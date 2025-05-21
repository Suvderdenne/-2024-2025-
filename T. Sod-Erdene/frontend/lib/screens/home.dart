// Like toggle боломж нэмсэн хувилбар
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';
import 'package:frontend/screens/furniture_detail.dart';

class HomePage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final void Function(Map<String, dynamic> item) onAddToCart;

  const HomePage({
    super.key,
    required this.cartItems,
    required this.onAddToCart,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> furnitureItems = [];
  Set<int> likedFurnitureIds = {}; // Таалагдсан ID-ууд

  List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.all_inclusive,
      'name': 'Бүгд',
      'dbName': 'All',
      'color': Colors.deepPurple,
    },
    {
      'icon': Icons.chair_outlined,
      'name': 'Сандал',
      'dbName': 'Chair',
      'color': Colors.orange,
    },
    {
      'icon': Icons.table_restaurant_outlined,
      'name': 'Ширээ',
      'dbName': 'Tables',
      'color': Colors.green,
    },
    {
      'icon': Icons.weekend_outlined,
      'name': 'Буйдан',
      'dbName': 'Sofa',
      'color': Colors.blue,
    },
    {
      'icon': Icons.bed_outlined,
      'name': 'Ор',
      'dbName': 'Beds',
      'color': Colors.purple,
    },
    {
      'icon': Icons.kitchen_outlined,
      'name': 'Шүүгээ',
      'dbName': 'Cabinet',
      'color': Colors.brown,
    },
    {
      'icon': Icons.light_outlined,
      'name': 'Гэрэл',
      'dbName': 'Lamp',
      'color': Colors.yellow,
    },
  ];

  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFurniture();
    _loadLikedFurnitureIds();
  }

  Future<void> _fetchFurniture() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/furniture/'),
      );
      if (response.statusCode == 200) {
        setState(() {
          furnitureItems = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Тавилгуудыг ачаалахад алдаа гарлаа: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Серверт холбогдоход алдаа гарлаа: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLikedFurnitureIds() async {
    final token = await AuthService.getToken();
    if (token == null) return;
    final res = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/furniture/liked/'),
      headers: {'Authorization': 'Token $token'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        likedFurnitureIds = data.map<int>((e) => e['id'] as int).toSet();
      });
    }
  }

  List<dynamic> get _filteredFurniture {
    String searchQuery = _searchController.text.toLowerCase();
    List<dynamic> filtered = furnitureItems;

    if (_selectedCategoryIndex > 0) {
      final dbName = categories[_selectedCategoryIndex]['dbName'];
      filtered =
          filtered.where((item) => item['category']['name'] == dbName).toList();
    }

    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (item) => item['title'].toLowerCase().contains(searchQuery),
              )
              .toList();
    }
    return filtered;
  }

  Future<void> _toggleLike(int id) async {
    final token = await AuthService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Та эхлээд нэвтэрнэ үү.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Optimistically update the UI
    final isCurrentlyLiked = likedFurnitureIds.contains(id);
    setState(() {
      if (isCurrentlyLiked) {
        likedFurnitureIds.remove(id);
      } else {
        likedFurnitureIds.add(id);
      }
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/furniture/$id/toggle_like/'),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode != 200) {
        // Revert the optimistic update if the API call fails
        setState(() {
          if (isCurrentlyLiked) {
            likedFurnitureIds.add(id);
          } else {
            likedFurnitureIds.remove(id);
          }
        });
        print('Error toggling like: ${response.statusCode}');
      }
    } catch (e) {
      // Revert the optimistic update if an exception occurs
      setState(() {
        if (isCurrentlyLiked) {
          likedFurnitureIds.add(id);
        } else {
          likedFurnitureIds.remove(id);
        }
      });
      print('Error toggling like: $e');
    }
  }

  Future<Uint8List?> _decodeBase64Image(String base64String) async {
    try {
      final cleanedBase64 = base64String.split(',').last;
      return base64Decode(cleanedBase64);
    } catch (e) {
      return null;
    }
  }

  void _handleAddToCart(dynamic item) async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!mounted) return;

      if (!isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Та нэвтрэх шаардлагатай'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Та нэвтрэх шаардлагатай'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final cartData = {
        "furniture_id": item['id'],
        "quantity": 1,
        "price": item['price'],
      };

      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/cart/add-item/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
        body: jsonEncode(cartData),
      );

      if (response.statusCode == 201) {
        final cartItem = Map<String, dynamic>.from({
          'id': item['id'],
          'title': item['title'],
          'price': item['price'],
          'quantity': 1,
          'image': item['pic'],
        });
        widget.onAddToCart(cartItem);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['title']} амжилттай сагсанд нэмэгдлээ'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['error'] ?? 'Алдаа гарлаа'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Алдаа гарлаа: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Тавилга хайх...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ангилал',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = _selectedCategoryIndex == index;
                          return GestureDetector(
                            onTap:
                                () => setState(
                                  () => _selectedCategoryIndex = index,
                                ),
                            child: Container(
                              width: 75,
                              margin: const EdgeInsets.only(right: 10),
                              child: Column(
                                children: [
                                  Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? cat['color'].withOpacity(0.2)
                                              : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? cat['color']
                                                : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      cat['icon'],
                                      color:
                                          isSelected
                                              ? cat['color']
                                              : Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat['name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color:
                                          isSelected
                                              ? cat['color']
                                              : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Онцлох бүтээгдэхүүн',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _filteredFurniture.isEmpty
                        ? const Center(child: Text('Тавилга олдсонгүй'))
                        : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredFurniture.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                          itemBuilder: (context, index) {
                            final item = _filteredFurniture[index];
                            return _buildFurnitureCard(item);
                          },
                        ),
                  ],
                ),
              ),
    );
  }

  Widget _buildFurnitureCard(dynamic item) {
    final bool isLiked = likedFurnitureIds.contains(item['id']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => FurnitureDetail(
                  furnitureItem: FurnitureItem.fromMap(item),
                  onAddToCart: (furnitureItem, quantity) {
                    final cartItem = Map<String, dynamic>.from({
                      'id': item['id'],
                      'title': item['title'],
                      'price': item['price'],
                      'quantity': quantity,
                      'image': item['pic'],
                    });
                    widget.onAddToCart(cartItem);
                  },
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: FutureBuilder<Uint8List?>(
                  future: _decodeBase64Image(item['pic']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData) {
                      return const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      );
                    }
                    return Image.memory(snapshot.data!, fit: BoxFit.cover);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['price'] != null
                          ? '${double.tryParse(item['price'].toString())?.toStringAsFixed(2) ?? '0.00'}₮'
                          : 'Үнэ байхгүй',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => _toggleLike(item['id']),
                        ),
                        GestureDetector(
                          onTap: () => _handleAddToCart(item),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
