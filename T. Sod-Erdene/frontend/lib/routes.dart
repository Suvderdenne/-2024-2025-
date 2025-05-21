import 'package:flutter/material.dart';
import 'screens/login.dart' as login_screen;
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/furniture_detail.dart';
import 'screens/order_confirmation.dart';
import 'screens/checkout_screen.dart';
import 'screens/profile.dart';
import 'screens/shopping_cart.dart';
import 'screens/splash.dart';
import 'screens/forgot_password.dart';
import 'main.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String forgotPassword = '/forgot';
  static const String profile = '/profile';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const login_screen.LoginScreen());
      case register:
        return _buildRoute(const RegisterScreen());
      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen());
      case home:
        if (settings.arguments != null) {
          final args = settings.arguments as HomePageArgs;
          return _buildRoute(
            HomePage(
              cartItems: args.cartItems,
              onAddToCart: (data) {
                args.onAddToCart(data);
                return;
              },
            ),
          );
        }
        return _buildRoute(const MainAppScreen());
      case productDetails:
        if (settings.arguments is! ProductDetailArguments) {
          return _errorRoute('Invalid arguments for product detail');
        }
        final args = settings.arguments as ProductDetailArguments;
        final furnitureItem = FurnitureItem.fromMap(args.product);
        return _buildRoute(
          FurnitureDetail(
            furnitureItem: furnitureItem,
            onAddToCart: (FurnitureItem item, int quantity) {
              // Handle add to cart logic here
              print('${item.name} added to cart with quantity $quantity');
            },
          ),
        );
      case cart:
        final args = settings.arguments as List<Map<String, dynamic>>?;
        return _buildRoute(CartScreen(cartItems: args ?? []));
      case checkout:
        final args = settings.arguments as List<Map<String, dynamic>>?;
        return _buildRoute(
          CheckoutScreen(cartItems: args ?? [], onOrderConfirmed: () {}),
        );
      case profile:
        return _buildRoute(
          ProfileScreen(
            onNavigateToOrderHistory: () {
              // Handle navigation to order history
            },
          ),
        );
      case orders:
        return _buildRoute(
          OrderConfirmationScreen(
            orderData: {},
            cartItems: [],
            totalPrice: 0,
            paymentMethod: '',
          ),
        );
      case splash:
        return _buildRoute(const SplashScreen());
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  static MaterialPageRoute<T> _buildRoute<T>(Widget widget) {
    return MaterialPageRoute<T>(builder: (_) => widget);
  }

  static MaterialPageRoute<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
    );
  }
}

class ProductDetailArguments {
  final Map<String, dynamic> product;

  ProductDetailArguments({required this.product});
}

class HomePageArgs {
  final List<Map<String, dynamic>> cartItems;
  final void Function(dynamic) onAddToCart;

  HomePageArgs({required this.cartItems, required this.onAddToCart});
}
