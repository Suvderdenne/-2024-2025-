class ApiConstants {
  // For Android emulator, use 10.0.2.2 to access localhost
  static const String baseUrl = 'http://127.0.0.1:8000';

  // API endpoints
  static const String login = '/login/';
  static const String register = '/register/';
  static const String carParts = '/carpart_list/';
  static const String cart = '/cart/';
  static const String cartItem = '/cart/item/';
  static const String checkout = '/checkout/';
  static const String profile = '/profile/';
  static const String orders = '/orders/';
}
