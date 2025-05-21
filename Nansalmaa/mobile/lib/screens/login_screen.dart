import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/screens/register_screen.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _usernameController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          elevation: 4,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Modified color palette with dark green as background
    final primaryColor = const Color(0xFF121212); // Rich black
    final accentColor = const Color(0xFFE0E0E0); // Silver
    final backgroundColor = const Color.fromARGB(255, 10, 38, 46); // Dark green
    final secondaryColor = const Color(0xFF757575); // Mid gray
    final highlightColor = const Color(0xFF212121); // Charcoal

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              const Color(0xFF0A3828), // Slightly lighter dark green
              backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                          height: screenSize.height * 0.02), // Reduced spacing

                      // Lottie animation with reduced height
                      Hero(
                        tag: 'logo',
                        child: Center(
                          child: Lottie.asset(
                            "assets/1deh.json",
                            height:
                                screenSize.height * 0.30, // Reduced from 0.40
                          ),
                        ),
                      ),

                      const SizedBox(height: 12), // Reduced from 24

                      // Tagline with subtle animation
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Text(
                              'ThriftFind',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 30, // Reduced from 36
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),

                      SizedBox(
                          height:
                              screenSize.height * 0.03), // Reduced from 0.05

                      // Username Field with enhanced styling
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _usernameController,
                          style: GoogleFonts.lato(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Нэвтрэх нэр',
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            hintText: 'Нэвтрэх нэрээ оруулна уу',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.person_outline,
                                color: Colors.grey[300]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: accentColor, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Colors.redAccent, width: 1.5),
                            ),
                            filled: true,
                            fillColor: const Color(
                                0xFF1A3C2E), // Dark green form background
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Нэвтрэх нэрээ оруулна уу';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16), // Reduced from 20

                      // Password Field with enhanced styling
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          style: GoogleFonts.lato(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Нууц үг',
                            labelStyle: TextStyle(color: Colors.grey[300]),
                            hintText: 'Нууц үгээ оруулна уу',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.lock_outline,
                                color: Colors.grey[300]),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[300],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: accentColor, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Colors.redAccent, width: 1.5),
                            ),
                            filled: true,
                            fillColor: const Color(
                                0xFF1A3C2E), // Dark green form background
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Нууц үгээ оруулна уу';
                            }
                            return null;
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Forgot password functionality
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                          ),
                          child: Text(
                            'Нууц үг мартсан?',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Reduced from 28

                      // Smaller buttons with modified styling
                      Row(
                        children: [
                          // Login Button
                          Expanded(
                            child: Container(
                              height: 48, // Reduced from 56
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF0F594F), // Dark teal
                                    const Color(0xFF084038), // Darker teal
                                  ],
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20, // Reduced from 24
                                        width: 20, // Reduced from 24
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Нэвтрэх',
                                        style: GoogleFonts.lato(
                                          fontSize: 15, // Reduced from 17
                                          fontWeight: FontWeight.bold,
                                          letterSpacing:
                                              1.0, // Reduced from 1.2
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Register Button
                          Expanded(
                            child: Container(
                              height: 48, // Reduced from 56
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF0F594F), // Dark teal
                                    const Color(0xFF084038), // Darker teal
                                  ],
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Бүртгүүлэх',
                                  style: GoogleFonts.lato(
                                    fontSize: 15, // Reduced from 17
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0, // Reduced from 1.2
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24), // Reduced from 32

                      // Stylish divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[800]!,
                                    Colors.grey[500]!,
                                    Colors.grey[800]!,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'ЭСВЭЛ',
                              style: GoogleFonts.lato(
                                color: Colors.grey[300],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[500]!,
                                    Colors.grey[800]!,
                                    Colors.grey[800]!,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24), // Reduced from 30

                      // Enhanced social login buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialLoginButton(
                            icon: Icons.g_mobiledata,
                            color: Colors.red[700]!,
                            onTap: () {},
                          ),
                          const SizedBox(width: 20),
                          _socialLoginButton(
                            icon: Icons.facebook,
                            color: Colors.blue[800]!,
                            onTap: () {},
                          ),
                          const SizedBox(width: 20),
                          _socialLoginButton(
                            icon: Icons.apple,
                            color: Colors.white,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12), // Reduced from 14
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A3C2E), // Dark green to match form fields
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 26, // Reduced from 30
        ),
      ),
    );
  }
}
