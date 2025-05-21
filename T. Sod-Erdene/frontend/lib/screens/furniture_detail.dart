import 'package:flutter/material.dart';
import 'package:frontend/auth_service.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FurnitureItem {
  final int id;
  final String name;
  final int price;
  final String model;
  final List<Color> colors;
  final double rating;
  final int reviews;
  final String description;
  bool isFavorite;

  FurnitureItem({
    required this.id,
    required this.name,
    required this.price,
    required this.model,
    required this.colors,
    required this.rating,
    required this.reviews,
    required this.description,
    this.isFavorite = false,
  });

  factory FurnitureItem.fromMap(Map<String, dynamic> map) {
    return FurnitureItem(
      id: map['id'] ?? UniqueKey().toString().hashCode,
      name: map['title'] ?? 'Unnamed Product',
      price:
          map['price']?.toString() == '0'
              ? 0
              : int.tryParse(map['price'].toString()) ?? 0,
      model: map['model_3d'] ?? 'default_model.glb',
      colors: _parseColors(map['colors']),
      rating: (map['rating'] ?? 0).toDouble(),
      reviews: map['reviews'] ?? 0,
      description: map['description'] ?? 'No description available',
      isFavorite: map['isFavorite'] ?? false,
    );
  }
  String get formattedPrice => price.toStringAsFixed(2);

  static List<Color> _parseColors(dynamic colors) {
    if (colors is List<Color>) return colors;
    if (colors is List) {
      return colors.map((c) {
        if (c is Color) return c;
        if (c is String) {
          switch (c.toLowerCase()) {
            case 'red':
              return Colors.red;
            case 'blue':
              return Colors.blue;
            case 'green':
              return Colors.green;
            case 'brown':
              return Colors.brown;
            case 'black':
              return Colors.black;
            default:
              return Colors.grey;
          }
        }
        return Colors.grey;
      }).toList();
    }
    return [Colors.grey];
  }
}

class FurnitureDetail extends StatefulWidget {
  final FurnitureItem furnitureItem;
  final Function(FurnitureItem item, int quantity) onAddToCart;

  const FurnitureDetail({
    super.key,
    required this.furnitureItem,
    required this.onAddToCart,
  });

  @override
  State<FurnitureDetail> createState() => _FurnitureDetailState();
}

class _FurnitureDetailState extends State<FurnitureDetail>
    with SingleTickerProviderStateMixin {
  int selectedColorIndex = 0;
  int quantity = 1;
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();

  // Mongolian translations
  final Map<String, String> translations = {
    'details': 'Дэлгэрэнгүй',
    'specifications': 'Үзүүлэлтүүд',
    'reviews': 'Сэтгэгдэлүүд',
    'material': 'Материал',
    'dimensions': 'Хэмжээ',
    'weight': 'Жин',
    'assembly': 'Угсралт',
    'color': 'Өнгө',
    'quantity': 'Тоо хэмжээ',
    'add_to_cart': 'Сагсанд нэмэх',
    'login_required': 'Та нэвтэрсний дараа сагсанд нэмэх боломжтой',
    'error_occurred': 'Алдаа гарлаа. Дахин оролдоно уу',
    'added_to_cart': 'сагсанд нэмэгдлээ',
    'no_reviews': 'Одоогоор сэтгэгдэл алга байна',
    'add_review': 'Үнэлгээ өгөх',
    'write_review': 'Сэтгэгдэл бичих',
    'submit': 'Илгээх',
    'empty_review': 'Сэтгэгдэл хоосон байна!',
    'review_success': 'Сэтгэгдэл амжилттай нэмэгдлээ!',
    'review_error': 'Сэтгэгдэл нэмэхэд алдаа гарлаа',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAuthAndLoadReviews();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _checkAuthAndLoadReviews() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translations['login_required']!),
          backgroundColor: Colors.red,
        ),
      );
    }
    _fetchReviews();
  }

  void _addToCart() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!mounted) return;

      if (!isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations['login_required']!),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations['login_required']!),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final cartData = {
        "furniture_id": widget.furnitureItem.id,
        "quantity": quantity,
        "price":
            widget.furnitureItem.price, // Ensure backend accepts string price
      };

      // Debug: Print the request payload
      print("Sending cart data: ${jsonEncode(cartData)}");

      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/cart/add-item/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
        body: jsonEncode(cartData),
      );

      // Debug: Print response details
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        widget.onAddToCart(widget.furnitureItem, quantity); // Notify parent
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.furnitureItem.name} ${translations['added_to_cart']}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorData['error'] ??
                  errorData['detail'] ??
                  translations['error_occurred']!,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Exception in _addToCart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${translations['error_occurred']}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _rating = 5.0;
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = true;

  Future<void> _fetchReviews() async {
    try {
      setState(() => _loadingReviews = true);

      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/api/furniture/${widget.furnitureItem.id}/reviews/',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _reviews = List<Map<String, dynamic>>.from(data));
      } else {
        print("Failed to fetch reviews: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    } finally {
      setState(() => _loadingReviews = false);
    }
  }

  Future<void> _submitComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translations['empty_review']!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations['login_required']!),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final url =
          'http://127.0.0.1:8000/api/furniture/${widget.furnitureItem.id}/reviews/';
      final headers = {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({'rating': _rating, 'comment': comment});

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        _commentController.clear();
        setState(() => _rating = 5.0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations['review_success']!),
            backgroundColor: Colors.green,
          ),
        );
        _fetchReviews();
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['error'] ?? translations['review_error']!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${translations['error_occurred']}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleReviewAction(String action, int reviewId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translations['login_required']!),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.delete(
        Uri.parse(
          'http://127.0.0.1:8000/api/furniture/${widget.furnitureItem.id}/reviews/$reviewId/',
        ),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 204) {
        _fetchReviews();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Үнэлгээ амжилттай устгагдлаа'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorData['error'] ?? translations['error_occurred']!,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${translations['error_occurred']}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.furnitureItem;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 20,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[100]!, Colors.grey[200]!],
                ),
              ),
              child: ModelViewer(
                src: 'assets/models/${item.model.split('/').last}',
                ar: true,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item.rating}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '(${item.reviews} reviews)',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${item.formattedPrice}₮',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: const UnderlineTabIndicator(
                                borderSide: BorderSide(
                                  color: Colors.deepPurple,
                                  width: 2,
                                ),
                                insets: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              labelColor: Colors.deepPurple,
                              unselectedLabelColor: Colors.grey[700],
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              tabs: [
                                Tab(text: translations['details']!),
                                Tab(text: translations['specifications']!),
                                Tab(text: translations['reviews']!),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                SingleChildScrollView(
                                  child: Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSpecItem(
                                        'Материал',
                                        'Premium Quality Wood',
                                      ),
                                      _buildSpecItem(
                                        'Хэмжээс',
                                        '65см x 72см x 80см',
                                      ),
                                      _buildSpecItem('Жин', '12.5 кг'),
                                      _buildSpecItem(
                                        'Угсралт',
                                        'Шаардлагатай, багаж хэрэгсэл орсон',
                                      ),
                                    ],
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: _buildReviewsTab(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            translations['color']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: List.generate(item.colors.length, (
                              index,
                            ) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedColorIndex = index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 14),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: item.colors[index],
                                    border: Border.all(
                                      color:
                                          selectedColorIndex == index
                                              ? Colors.deepPurple
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow:
                                        selectedColorIndex == index
                                            ? [
                                              BoxShadow(
                                                color: Colors.deepPurple
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child:
                                      selectedColorIndex == index
                                          ? const Center(
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          )
                                          : null,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Text(
                                translations['quantity']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    _buildQuantityButton(
                                      icon: Icons.remove,
                                      onTap: () {
                                        if (quantity > 1) {
                                          setState(() {
                                            quantity--;
                                          });
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      width: 40,
                                      child: Center(
                                        child: Text(
                                          '$quantity',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    _buildQuantityButton(
                                      icon: Icons.add,
                                      onTap: () {
                                        setState(() {
                                          quantity++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      12 + MediaQuery.of(context).padding.bottom,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.deepPurple),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _addToCart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                translations['add_to_cart']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _buildSpecItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (_loadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_reviews.length} ${translations['reviews']!}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < widget.furnitureItem.rating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reviews.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    (review['username'] as String? ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                review['username'] as String? ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < (review['rating'] as num? ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (review['user_info']?['username'] ==
                            (review['username'] as String?))
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed:
                                () =>
                                    _handleReviewAction('delete', review['id']),
                            color: Colors.red[300],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(review['comment'] as String? ?? ''),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateTime.parse(
                      review['created_at'] as String,
                    ).toLocal().toString().split(' ')[0],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              );
            },
          ),
          if (_reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  translations['no_reviews']!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translations['add_review']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => GestureDetector(
                      onTap: () => setState(() => _rating = index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: translations['write_review']!,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      translations['submit']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
