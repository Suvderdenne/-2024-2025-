import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/auth_service.dart';
import 'package:frontend/routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  // Mongolian translations
  final Map<String, String> translations = {
    'create_account': 'Шинэ бүртгэл үүсгэх',
    'join_community': 'Манай сандал диваны ертөнцөд нэгдээрэй',
    'username': 'Хэрэглэгчийн нэр',
    'email': 'Имэйл',
    'password': 'Нууц үг',
    'confirm_password': 'Нууц үг давтах',
    'register': 'Бүртгүүлэх',
    'have_account': 'Бүртгэлтэй юу? ',
    'login': 'Нэвтрэх',
    'username_required': 'Хэрэглэгчийн нэрээ оруулна уу',
    'username_length': 'Хамгийн багадаа 3 тэмдэгт байх ёстой',
    'email_required': 'Имэйлээ оруулна уу',
    'invalid_email': 'Буруу имэйл формат',
    'password_required': 'Нууц үгээ оруулна уу',
    'password_length': 'Хамгийн багадаа 6 тэмдэгт байх ёстой',
    'password_mismatch': 'Нууц үг таарахгүй байна',
    'register_failed': 'Бүртгэл амжилтгүй боллоо',
    'connection_error': 'Интернэт холболтоо шалгана уу',
  };

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = translations['password_mismatch']);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response['success'] == true) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        if (mounted) {
          setState(() {
            // Show specific error message from backend if available
            _errorMessage = response['message'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = translations['connection_error']);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://hips.hearstapps.com/hmg-prod/images/gonzalez-abreu-alas-architects-gaa-portfolio-interiors-great-room-architectural-detail-design-detail-1501104286-275239-1563558552.jpg?crop=1xw:1xh;center,top&resize=980:*',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translations['create_account']!,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      translations['join_community']!,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Registration Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                              label: translations['username']!,
                              icon: Icons.person,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return translations['username_required'];
                              }
                              if (value.length < 3) {
                                return translations['username_length'];
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                              label: translations['email']!,
                              icon: Icons.email,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return translations['email_required'];
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return translations['invalid_email'];
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                              label: translations['password']!,
                              icon: Icons.lock,
                              isPassword: true,
                              onToggleVisibility: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return translations['password_required'];
                              }
                              if (value.length < 6) {
                                return translations['password_length'];
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                              label: translations['confirm_password']!,
                              icon: Icons.lock_outline,
                              isPassword: true,
                              onToggleVisibility: () {
                                setState(
                                  () =>
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword,
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return translations['password_required'];
                              }
                              if (value != _passwordController.text) {
                                return translations['password_mismatch'];
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : Text(
                                        translations['register']!,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Text(
                                  translations['have_account']!,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white70,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.login,
                                    );
                                  },
                                  child: Text(
                                    translations['login']!,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon:
          isPassword
              ? IconButton(
                icon: Icon(
                  isPassword
                      ? (_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off)
                      : (_obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                  color: Colors.white,
                ),
                onPressed: onToggleVisibility,
              )
              : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
    );
  }
}
