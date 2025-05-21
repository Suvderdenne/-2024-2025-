import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'home_page.dart';

class CheckoutPage extends StatefulWidget {
  final double total;
  final int itemCount;

  const CheckoutPage({
    Key? key,
    required this.total,
    required this.itemCount,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  // Custom theme colors
  final Color primaryColor = const Color(0xFF0F1923);
  final Color accentColor = const Color(0xFFF58220);
  final Color bgColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF2D3748);
  final Color textSecondaryColor = const Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _errorMessage = 'Төлбөр тооцоогоо үргэлжлүүлэхийн тулд нэвтэрнэ үү';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _nameController.text =
              '${data['нэр'] ?? ''} ${data['овог_нэр'] ?? ''}'.trim();
          _phoneController.text = data['утас'] ?? '';
          _addressController.text = data['хаяг'] ?? '';
          _emailController.text = data['email'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading user data: $e';
      });
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Захиалга өгөхийн тулд нэвтэрнэ үү');
      }

      // First clear the cart
      final clearCartResponse = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/cart/clear/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'shipping_address': _addressController.text,
          'phone_number': _phoneController.text,
          'email': _emailController.text,
        }),
      );

      if (clearCartResponse.statusCode == 200) {
        if (mounted) {
          // Show the thank you popup
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Баярлалаа!'),
                content: const Text('Худалдан авалт хийсэнд баярлалаа!'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        throw Exception('Failed to clear cart: ${clearCartResponse.body}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _errorMessage != null
          ? _buildErrorView()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderSummary(),
                      const SizedBox(height: 24),
                      _buildShippingDetails(),
                      const SizedBox(height: 24),
                      _buildPaymentMethod(),
                      const SizedBox(height: 32),
                      _buildPlaceOrderButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: textPrimaryColor),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadUserData,
            icon: Icon(Icons.refresh),
            label: Text('Дахин оролдоно уу'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Захиалгын хураангуй',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Нийт зүйлс',
                  style: TextStyle(color: textSecondaryColor),
                ),
                Text(
                  '${widget.itemCount}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Нийт дүн',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
                Text(
                  '₮${widget.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Хүргэлтийн дэлгэрэнгүй мэдээлэл',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Бүтэн нэр',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Нэрээ оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Утасны дугаар',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Утасны дугаараа оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Хүргэлтийн хаяг',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Хүргэлтийн хаягаа оруулна уу';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Төлбөрийн арга',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.payment, color: accentColor),
              title: Text(' Бэлэн мөнгө'),
              subtitle: Text('Захиалгаа хүлээн авахдаа бэлэн мөнгөөр төлөх'),
              trailing: Icon(Icons.check_circle, color: accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Захиалга өгөх',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
