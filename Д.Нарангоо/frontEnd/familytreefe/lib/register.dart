import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api/api_service.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService authService;

  const RegisterScreen({super.key, required this.authService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final success = await widget.authService.register(
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _rePasswordController.text.trim(),
        );

        if (success && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LoginScreen(authService: widget.authService),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Бүртгэл амжилтгүй боллоо. Мэдээллээ шалгана уу.';
          });
        }
      } catch (_) {
        setState(() {
          _errorMessage = 'Сүлжээний алдаа гарлаа. Дахин оролдоно уу.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF008000), Color(0xFFE6F7E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withAlpha(50), width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withAlpha(180)),
          prefixIcon: Icon(prefixIcon, color: Colors.white.withAlpha(200)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF008000), Color(0xFFE6F7E6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _buildLogo(),
                      const SizedBox(height: 40),
                      _buildTextField(
                        controller: _usernameController,
                        hintText: 'Хэрэглэгчийн нэр',
                        prefixIcon: Icons.person_outline,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Хэрэглэгчийн нэр оруулна уу'
                                    : null,
                      ),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Имэйл',
                        prefixIcon: Icons.email_outlined,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Имэйл хаяг оруулна уу'
                                    : null,
                      ),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Нууц үг',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white.withAlpha(180),
                          ),
                          onPressed:
                              () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                        ),
                        validator:
                            (value) =>
                                value == null || value.length < 6
                                    ? 'Хамгийн багадаа 6 тэмдэгт'
                                    : null,
                      ),
                      _buildTextField(
                        controller: _rePasswordController,
                        hintText: 'Нууц үгээ давтана уу',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator:
                            (value) =>
                                value != _passwordController.text
                                    ? 'Нууц үг таарахгүй байна'
                                    : null,
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF008000),
                            elevation: 8,
                            shadowColor: Colors.black.withAlpha(100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF008000),
                                    ),
                                  )
                                  : const Text(
                                    'БҮРТГҮҮЛЭХ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Бүртгэлтэй юу?',
                            style: TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Go back to login
                            },
                            child: const Text(
                              'Нэвтрэх',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF008000),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
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

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                offset: const Offset(0, 10),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: ClipOval(child: Image.asset('logo.jpg', fit: BoxFit.cover)),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Бүртгүүлэх',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
