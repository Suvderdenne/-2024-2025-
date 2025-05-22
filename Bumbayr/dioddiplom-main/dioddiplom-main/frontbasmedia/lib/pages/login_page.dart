import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _apiService = ApiService();

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _apiService.login(
          _emailController.text,
          _passwordController.text,
        );
        Navigator.pushReplacementNamed(context, '/');
      } else {
        await _apiService.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
        setState(() {
          _isLogin = true;
          _nameController.clear();
          _confirmPasswordController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Бүртгүүлэлт амжилттай. Нэвтрэх үед нэвтрэх'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.sports_basketball, size: 64, color: Colors.blueAccent),
                    SizedBox(height: 24),
                    Text(
                      _isLogin ? 'Нэвтрэх' : 'Бүртгүүлэх',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 36),
                    if (!_isLogin)
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Нэр',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Нэрээ оруулна уу';
                          }
                          return null;
                        },
                      ),
                    if (!_isLogin) SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'И-мэйл',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'И-мэйл хаягаа оруулна уу';
                        }
                        if (!value.contains('@')) {
                          return 'Зөв и-мэйл хаяг оруулна уу';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Нууц үг',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Нууц үгээ оруулна уу';
                        }
                        if (!_isLogin && value.length < 6) {
                          return 'Нууц үг хамгийн багадаа 6 тэмдэгт байх ёстой';
                        }
                        return null;
                      },
                    ),
                    if (!_isLogin) ...[
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Нууц үгээ давтах',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Нууц үгээ давтах';
                          }
                          if (value != _passwordController.text) {
                            return 'Нууц үг таарахгүй байна';
                          }
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isLogin ? 'Нэвтрэх' : 'Бүртгүүлэх',
                              style: TextStyle(fontSize: 17),
                            ),
                    ),
                    SizedBox(height: 18),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isLogin = !_isLogin;
                                if (_isLogin) {
                                  _confirmPasswordController.clear();
                                }
                              });
                            },
                      child: Text(
                        _isLogin
                            ? 'Шинэ хэрэглэгч? Бүртгүүлэх'
                            : 'Бүртгэлтэй юу? Нэвтрэх',
                        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
// ...existing code...