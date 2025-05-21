import 'package:flutter/material.dart';
import 'package:frontend/routes.dart';
import 'package:frontend/auth_service.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/liked_furniture.dart';
import 'package:frontend/screens/notifications.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/screens/order_history.dart';
import 'package:frontend/screens/checkout_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final title = 'Содон Мебель';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppRoutes.splash,
      routes: {AppRoutes.home: (context) => const MainAppScreen()},
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.home && settings.arguments != null) {
          return AppRoutes.generateRoute(settings);
        }
        return AppRoutes.generateRoute(settings);
      },
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  var _currentIndex = 0;
  String? _userEmail;
  String? _username;
  final List<Map<String, dynamic>> _cart = [];
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkNotifications();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getCurrentUser();
    if (userData != null) {
      setState(() {
        _username = userData['username'];
        _userEmail = userData['email'];
      });
    }
  }

  Future<void> _checkNotifications() async {
    // This will be implemented to check for unread notifications
    // For now, we'll use a dummy value
    setState(() {
      _unreadNotifications = 2;
    });
  }

  void _signOut() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _addToCart(Map<String, dynamic> item) {
    final index = _cart.indexWhere((e) => e['id'] == item['id']);
    setState(() {
      if (index != -1) {
        _cart[index]['quantity'] += 1;
      } else {
        _cart.add({
          'id': item['id'],
          'name': item['title'],
          'price': double.parse(item['price'].toString()),
          'image': item['pic'],
          'quantity': 1,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        cartItems: _cart,
        onAddToCart: (dynamic item) {
          _addToCart(item);
        },
      ),
      const LikedFurniture(),
      const NotificationsScreen(),
      ProfileScreen(
        onNavigateToOrderHistory: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderHistory()),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text(
          'Содон Мебель',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CheckoutScreen(
                            cartItems: _cart,
                            onOrderConfirmed: () {
                              setState(() {
                                _cart.clear();
                              });
                            },
                          ),
                    ),
                  );
                },
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple[100]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _username ?? 'Хэрэглэгч',
                    style: const TextStyle(color: Colors.black87, fontSize: 18),
                  ),
                  Text(
                    _userEmail ?? 'email@example.com',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Профайл'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Таалагдсан'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('Захиалгын түүх'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderHistory()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Гарах', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Гарах'),
                        content: const Text(
                          'Та системээс гарахдаа итгэлтэй байна уу?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Үгүй'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _signOut();
                            },
                            child: const Text('Тийм'),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home_outlined),
            title: const Text("Нүүр"),
            selectedColor: Colors.deepPurple,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.favorite_border),
            title: const Text("Таалагдсан"),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (_unreadNotifications > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$_unreadNotifications',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: const Text("Мэдэгдэл"),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person_outline),
            title: const Text("Профайл"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
