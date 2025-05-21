import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/auth_service.dart';
import 'package:frontend/routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onNavigateToOrderHistory;

  const ProfileScreen({super.key, required this.onNavigateToOrderHistory});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _changingPassword = false;
  Map<String, dynamic> _userData = {};
  String? _errorMessage;
  String? _successMessage;

  // Controllers for form fields
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Password change controllers
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadProfile();
  }

  Future<void> _checkAuthAndLoadProfile() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
          return;
        }
      }
      await _loadUserProfile();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking authentication status';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication required';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/users/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
          _isLoading = false;
          // Initialize controllers with current data
          _usernameController.text = _userData['username'] ?? '';
          _emailController.text = _userData['email'] ?? '';
          _phoneController.text = _userData['phone'] ?? '';
          _addressController.text = _userData['address'] ?? '';
        });
      } else if (response.statusCode == 401) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _isLoading = true;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication required';
          _isLoading = false;
        });
        return;
      }

      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/users/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _successMessage = 'Profile updated successfully';
          _isEditing = false;
          _userData = jsonDecode(response.body);
        });
      } else if (response.statusCode == 401) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating profile: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await AuthService.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _successMessage = result['message'];
          _changingPassword = false;
          // Clear password fields
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        } else {
          _errorMessage = result['error'];
        }
      });
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Гарах үйлдэл амжилтгүй боллоо. Дахин оролдоно уу.';
        _isLoading = false;
      });
      print('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      // App bar removed as requested
      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.brown),
                )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing
                ? 'Мэдээллээ шинэчлэх'
                : _changingPassword
                ? 'Нууц үгээ солих'
                : 'Хувийн мэдээллээ удирдах',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.brown[700],
            ),
          ),
          const SizedBox(height: 30),

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
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          // Success message
          if (_successMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          // Content based on mode
          if (_isEditing)
            _buildEditForm()
          else if (_changingPassword)
            _buildPasswordForm()
          else
            _buildProfileView(),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile avatar
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.brown[700],
                child: Text(
                  _userData['username']?.isNotEmpty == true
                      ? _userData['username'][0].toUpperCase()
                      : '?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'ID: ${_userData['id'] ?? 'Мэдээлэл байхгүй'}',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.brown[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Profile info card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  'Хэрэглэгчийн нэр',
                  _userData['username'] ?? 'Тохируулаагүй',
                ),
                const Divider(),
                _buildInfoRow('Имэйл', _userData['email'] ?? 'Тохируулаагүй'),
                const Divider(),
                _buildInfoRow('Утас', _userData['phone'] ?? 'Тохируулаагүй'),
                const Divider(),
                _buildInfoRow('Хаяг', _userData['address'] ?? 'Тохируулаагүй'),
                if (_userData['created_at'] != null) ...[
                  const Divider(),
                  _buildInfoRow(
                    'Бүртгүүлсэн огноо',
                    _formatDate(_userData['created_at']),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                    _changingPassword = false;
                    _errorMessage = null;
                    _successMessage = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Профайл засах',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _changingPassword = true;
                    _isEditing = false;
                    _errorMessage = null;
                    _successMessage = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[400],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Нууц үг солих',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Add logout button here since we removed it from app bar
        ElevatedButton(
          onPressed: _logout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[400],
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Гарах',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _usernameController,
            style: TextStyle(color: Colors.brown[900]),
            decoration: _buildInputDecoration(
              label: 'Хэрэглэгчийн нэр',
              icon: Icons.person,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Хэрэглэгчийн нэрээ оруулна уу';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Colors.brown[900]),
            decoration: _buildInputDecoration(
              label: 'Имэйл',
              icon: Icons.email,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Имэйл хаягаа оруулна уу';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Зөв имэйл хаяг оруулна уу';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: Colors.brown[900]),
            decoration: _buildInputDecoration(
              label: 'Утасны дугаар',
              icon: Icons.phone,
            ),
            // Phone validation is optional
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _addressController,
            keyboardType: TextInputType.streetAddress,
            style: TextStyle(color: Colors.brown[900]),
            decoration: _buildInputDecoration(label: 'Хаяг', icon: Icons.home),
            maxLines: 2,
            // Address validation is optional
          ),
          const SizedBox(height: 30),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _errorMessage = null;
                      _successMessage = null;

                      // Reset form values
                      _usernameController.text = _userData['username'] ?? '';
                      _emailController.text = _userData['email'] ?? '';
                      _phoneController.text = _userData['phone'] ?? '';
                      _addressController.text = _userData['address'] ?? '';
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Цуцлах',
                    style: GoogleFonts.montserrat(
                      color: Colors.brown[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Хадгалах',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrentPassword,
            style: TextStyle(color: Colors.brown[900]),
            decoration: _buildInputDecoration(
              label: 'Одоогийн нууц үг',
              icon: Icons.lock,
              isPassword: true,
              onToggleVisibility: () {
                setState(() {
                  _obscureCurrentPassword = !_obscureCurrentPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Одоогийн нууц үгээ оруулна уу';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            style: TextStyle(color: Colors.brown[900]),
            decoration: _buildInputDecoration(
              label: 'Шинэ нууц үг',
              icon: Icons.lock_outline,
              isPassword: true,
              onToggleVisibility: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Шинэ нууц үгээ оруулна уу';
              }
              if (value.length < 6) {
                return 'Нууц үг хамгийн багадаа 6 тэмдэгт байх ёстой';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: TextStyle(color: Colors.brown[900]),
            decoration: _buildInputDecoration(
              label: 'Шинэ нууц үгээ баталгаажуулах',
              icon: Icons.lock_outline,
              isPassword: true,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Шинэ нууц үгээ давтан оруулна уу';
              }
              if (value != _newPasswordController.text) {
                return 'Нууц үг таарахгүй байна';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.forgotPassword);
              },
              child: Text(
                'Нууц үгээ мартсан уу?',
                style: GoogleFonts.montserrat(
                  color: Colors.brown[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _changingPassword = false;
                      _errorMessage = null;
                      _successMessage = null;

                      // Clear password fields
                      _currentPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Цуцлах',
                    style: GoogleFonts.montserrat(
                      color: Colors.brown[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Нууц үг солих',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.brown[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.brown[900],
              fontWeight: FontWeight.bold,
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
    Function()? onToggleVisibility,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.brown[700]),
      prefixIcon: Icon(icon, color: Colors.brown[700]),
      suffixIcon:
          isPassword
              ? IconButton(
                icon: Icon(
                  _obscureCurrentPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.brown[700],
                ),
                onPressed: onToggleVisibility,
              )
              : null,
      filled: true,
      fillColor: Colors.brown[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown[700]!, width: 2),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
