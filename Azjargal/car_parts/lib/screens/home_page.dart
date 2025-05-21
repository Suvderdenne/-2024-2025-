import 'dart:async';
import 'dart:io';
import 'package:car_parts/screens/search_result_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_part.dart';
import 'detail_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../utils/constants.dart';

void main() {
  runApp(CarPartsApp());
}

class CarPartsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFF58220), // Улбар шар өнгө
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFF58220),
          primary: Color(0xFFF58220),
          background: Color(0xFF0F1923), // Хар хөх өнгө (логин хуудсын дэвсгэр)
        ),
        scaffoldBackgroundColor: Color(0xFF0F1923),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0F1923),
          foregroundColor: Colors.white,
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Color(0xFF1C2A35),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/home': (context) => HomePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => HomePage(arguments: settings.arguments as Map<String, dynamic>?),
          );
        }
        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const HomePage({Key? key, this.arguments}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  int _cartItemCount = 0;
  Timer? _bannerTimer;
  bool _hasRefreshed = false;

  final List<Map<String, dynamic>> banners = [
    {'image': 'assets/123.jpg'},
    {'image': 'assets/dugui.jpg'},
    {'image': 'assets/tos.jpg'},
    {'image': 'assets/banner.jpg'},
    {'image': 'assets/uuu.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
    _checkLoginStatus();
    _loadCartCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we need to refresh
    if (!_hasRefreshed) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['refresh'] == true) {
        _loadCartCount();
        _hasRefreshed = true;
      }
    }
  }

  Future<void> _loadCartCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/cart/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _cartItemCount = (data['cart_items'] as List).length;
          });
        }
      }
    } catch (e) {
      print('Error loading cart count: $e');
    }
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      // Хэрэв токен байхгүй бол логин хуудас руу шилжүүлэх
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _currentBannerIndex = (_currentBannerIndex + 1) % banners.length;
      });
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _addToCart() {
    setState(() {
      _cartItemCount++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Бараа сагсанд нэмэгдлээ'),
        backgroundColor: Color(0xFFF58220),
      ),
    );
  }

  bool _isSearching = false; // Add this with your other state variables

  Future<List<dynamic>> searchCarParts(String query) async {
    try {
      final url = Uri.parse(
        'http://127.0.0.1:8000/search/?q=${Uri.encodeComponent(query)}',
      );
      debugPrint('🔍 Search API called: $url');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      debugPrint('🔍 Response status: ${response.statusCode}');
      debugPrint('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(
          utf8.decode(response.bodyBytes),
        ); // Handle UTF-8 properly

        // Handle both possible response formats
        if (decoded is List) {
          return decoded;
        } else if (decoded is Map && decoded.containsKey('results')) {
          return decoded['results'];
        } else {
          throw FormatException('Unexpected response format');
        }
      } else {
        throw HttpException(
          'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('🔍 Search error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent going back to checkout page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: DefaultTabController(
        length: 6,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              icon: FutureBuilder<String?>(
                future: _getProfileImage(),
                builder: (context, imageSnapshot) {
                  if (imageSnapshot.hasData && imageSnapshot.data != null && imageSnapshot.data!.isNotEmpty) {
                    return ClipOval(
                      child: Image.network(
                        imageSnapshot.data!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildInitialsAvatar();
                        },
                      ),
                    );
                  }
                  return _buildInitialsAvatar();
                },
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings, color: Color(0xFFA38566)),
                SizedBox(width: 8),
                Text(
                  "Авто Сэлбэгийн Худалдаа",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA38566),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.settings, color: Color(0xFFA38566)),
              ],
            ),
            centerTitle: true,
            actions: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CartPage()),
                      );
                    },
                    icon: Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  if (_cartItemCount > 0)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Color(0xFFF58220),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$_cartItemCount',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Хайх",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1C2A35),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (value) async {
                    if (value.isEmpty || _isSearching) return;

                    setState(() => _isSearching = true);

                    try {
                      final results = await searchCarParts(value);
                      if (results.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Хайлтын үр дүн олдсонгүй')),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SearchResultsPage(
                                  searchQuery: value,
                                  results: results,
                                ),
                          ),
                        );
                      }
                    } on FormatException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Хариуны формат буруу: ${e.message}'),
                        ),
                      );
                    } on HttpException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Серверийн алдаа: ${e.message}')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Алдаа гарлаа: $e')));
                    } finally {
                      setState(() => _isSearching = false);
                    }
                  },
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Container(
                height: 200,
                margin: EdgeInsets.only(top: 10),
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.asset(
                              banners[index]['image'],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.5),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentBannerIndex == index
                              ? Color(0xFFF58220)
                              : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1C2A35),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  labelColor: Color(0xFFF58220),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFFF58220),
                  indicatorSize: TabBarIndicatorSize.label,
                  isScrollable: true,
                  tabs: [
                    Tab(text: "БҮГД"),
                    Tab(text: "ХӨДӨЛГҮҮР"),
                    Tab(text: "ТООРМОС"),
                    Tab(text: "ЦАХИЛГААН"),
                    Tab(text: "ГАДНА"),
                    Tab(text: "ДОТОР"),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: List.generate(6, (index) {
                    final category =
                        [
                          "Бүх",
                          "Хөдөлгүүр",
                          "Тоормос",
                          "Цахилгаан",
                          "Гадна",
                          "Дотор",
                        ][index];
                    return CarPartListPage(
                      category: category,
                      onAddToCart: _addToCart,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return FutureBuilder<String?>(
      future: _getUsername(),
      builder: (context, usernameSnapshot) {
        if (usernameSnapshot.hasData && usernameSnapshot.data != null) {
          return CircleAvatar(
            backgroundColor: Color(0xFFF58220),
            child: Text(
              usernameSnapshot.data![0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return CircleAvatar(
          backgroundColor: Color(0xFFF58220),
          child: Icon(Icons.person, color: Colors.white),
        );
      },
    );
  }

  Future<String?> _getUsername() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      
      if (token != null) {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['username'];
        }
      }
    } catch (e) {
      print('Error getting username: $e');
    }
    return null;
  }

  Future<String?> _getProfileImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      
      if (token != null) {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final imageUrl = data['profile_picture'];
          print('Profile image URL: $imageUrl'); // Debug print
          return imageUrl;
        }
      }
    } catch (e) {
      print('Error getting profile image: $e');
    }
    return null;
  }
}

// ===========================================
// CarPartListPage эндээс эхэлж байна
// ===========================================

class CarPartListPage extends StatefulWidget {
  final String category;
  final Function onAddToCart;

  CarPartListPage({required this.category, required this.onAddToCart});

  @override
  _CarPartListPageState createState() => _CarPartListPageState();
}

class _CarPartListPageState extends State<CarPartListPage> {
  List<dynamic> carParts = [];
  bool isLoading = true;
  // Сагсанд нэмсэн бараануудын ID-г хадгалах
  Set<int> addedToCartItems = {};

  @override
  void initState() {
    super.initState();
    fetchCarParts();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchCarParts() async {
    setState(() => isLoading = true);

    String? token = await getToken();

    if (token == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Та нэвтрээгүй байна. Дахин нэвтэрнэ үү.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
      return;
    }

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.carParts}');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          carParts = data['car_parts'];
          isLoading = false;
        });
      } else {
        throw Exception('Машины сэлбэг ачаалахад алдаа гарлаа');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа: $e'), backgroundColor: Colors.red),
      );
    }
  }

  List<dynamic> get filteredParts {
    if (widget.category == 'Бүх') return carParts;
    return carParts.where((part) => part['Төрөл'] == widget.category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: Color(0xFFF58220)))
        : GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filteredParts.length,
          itemBuilder: (context, index) {
            final part = filteredParts[index];
            final partId = part['id'];
            final imageUrl = part['Зураг'] ?? '';
            final isInCart = addedToCartItems.contains(partId);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPage(carPart: part)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1C2A35),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stack) => Container(
                                color: Color(0xFF2A3A45),
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            part['Нэр'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '₮${part['Үнэ']}',
                            style: TextStyle(
                              color: Color(0xFFF58220),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        widget.onAddToCart();
                        // Төлөвийг өөрчлөх
                        setState(() {
                          addedToCartItems.add(partId);
                        });

                        try {
                          final token = await getToken();
                          if (token == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Нэвтэрч орно уу'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final response = await http.post(
                            Uri.parse(
                              '${ApiConstants.baseUrl}${ApiConstants.cart}',
                            ),
                            headers: {
                              'Authorization': 'Token $token',
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode({
                              'car_part_id': partId,
                              'quantity': 1,
                            }),
                          );

                          if (response.statusCode == 201) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Бараа амжилттай сагсанд нэмэгдлээ!',
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            final data = jsonDecode(response.body);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(data['error'] ?? 'Алдаа гарлаа'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Алдаа гарлаа: $e'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: isInCart ? Colors.green : Color(0xFFF58220),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isInCart ? 'Сагсанд нэмэгдсэн' : 'Сагсанд нэмэх',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }
}
