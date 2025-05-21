import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/clothes_provider.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  String? _selectedImageBase64;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();

    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final clothesProvider =
          Provider.of<ClothesProvider>(context, listen: false);

      // Load user data
      if (authProvider.isAuthenticated) {
        _firstNameController.text = authProvider.user?['first_name'] ?? '';
        _lastNameController.text = authProvider.user?['last_name'] ?? '';
        _emailController.text = authProvider.user?['email'] ?? '';

        // Load user's items and ratings
        clothesProvider.loadMyListings();
        clothesProvider.loadSoldItems();
        clothesProvider.loadBoughtItems();
        clothesProvider.loadUserRatings();
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 400,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (bytes.length > 2 * 1024 * 1024) {
          // 2MB limit
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Зураг 2MB-ээс бага байх ёстой'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _selectedImageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Зураг сонгоход алдаа гарлаа: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        profileImage: _selectedImageBase64,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профайл амжилттай шинэчлэгдлээ'),
          backgroundColor: Color(0xFF0F594F),
        ),
      );
      setState(() {
        _isEditing = false;
        _selectedImageBase64 = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Шинэчлэл амжилтгүй боллоо: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final backgroundColor = const Color.fromARGB(255, 10, 38, 46);
    final cardColor = const Color(0xFF1A3C2E);
    final accentColor = const Color(0xFF0F594F);

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 80,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 20),
                Text(
                  'Профайл харахын тулд нэвтрэх хэрэгтэй',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'Нэвтрэх',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildProfileHeader(authProvider),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton('Профайл', 0, Icons.person),
                _buildNavButton('Зарах', 1, Icons.store),
                _buildNavButton('Зарагдсан', 2, Icons.done_all),
                _buildNavButton('Худалдан авсан', 3, Icons.shopping_bag),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          Expanded(
            child: _getSelectedView(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider) {
    final cardColor = const Color(0xFF1A3C2E);
    final accentColor = const Color(0xFF0F594F);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: _isEditing ? _selectProfileImage : null,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white24,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: _isEditing && _selectedImageBase64 != null
                        ? ClipOval(
                            child: Image.memory(
                              base64Decode(_selectedImageBase64!),
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          )
                        : authProvider.user?['profile_image'] != null
                            ? ClipOval(
                                child: Image.memory(
                                  base64Decode(authProvider.user!['profile_image']),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white.withOpacity(0.7),
                              ),
                  ),
                ),
              ),
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isEditing)
            Text(
              '${authProvider.user?['first_name']} ${authProvider.user?['last_name']}',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 4),
          if (!_isEditing)
            Text(
              authProvider.user?['email'] ?? '',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.white70,
              ),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 10),
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    final accentColor = const Color(0xFF0F594F);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? accentColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? accentColor : Colors.white70,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lato(
                color: isSelected ? accentColor : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedView() {
    switch (_selectedIndex) {
      case 0:
        return _buildProfileTab();
      case 1:
        return _buildItemsTab('selling');
      case 2:
        return _buildItemsTab('sold');
      case 3:
        return _buildItemsTab('bought');
      default:
        return _buildProfileTab();
    }
  }

  Widget _buildProfileTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final cardColor = const Color(0xFF1A3C2E);
    final accentColor = const Color(0xFF0F594F);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing) ...[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'Нэр',
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Нэр оруулна уу'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _lastNameController,
                    label: 'Овог',
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Овог оруулна уу' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'И-мэйл',
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'И-мэйл оруулна уу' : null,
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              'Хэрэглэгчийн мэдээлэл',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              Icons.person,
              'Нэр',
              '${authProvider.user?['first_name']} ${authProvider.user?['last_name']}',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              Icons.email,
              'И-мэйл',
              authProvider.user?['email'] ?? '',
            ),
          ],
          const SizedBox(height: 30),
          Text(
            'Үнэлгээ & Сэтгэгдэл',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<ClothesProvider>(
            builder: (context, clothesProvider, child) {
              if (clothesProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }

              final ratings = clothesProvider.userRatings;
              if (ratings.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 40,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Үнэлгээ байхгүй байна',
                        style: GoogleFonts.lato(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ratings.length,
                itemBuilder: (context, index) {
                  final rating = ratings[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  rating['rating'].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${rating['buyer_name']}-с',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          if (rating['comment'] != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              rating['comment'],
                              style: GoogleFonts.lato(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    final cardColor = const Color(0xFF1A3C2E);
    
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: cardColor,
      ),
      validator: validator,
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    final cardColor = const Color(0xFF1A3C2E);
    final accentColor = const Color(0xFF0F594F);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTab(String type) {
    final cardColor = const Color(0xFF1A3C2E);
    final accentColor = const Color(0xFF0F594F);

    return Consumer<ClothesProvider>(
      builder: (context, clothesProvider, child) {
        if (clothesProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        final items = type == 'selling'
            ? clothesProvider.myListings
            : type == 'sold'
                ? clothesProvider.soldItems
                : clothesProvider.boughtItems;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'selling'
                      ? Icons.add_shopping_cart
                      : type == 'sold'
                          ? Icons.check_circle
                          : Icons.shopping_bag,
                  size: 60,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  type == 'selling'
                      ? 'Идэвхтэй зар байхгүй байна'
                      : type == 'sold'
                          ? 'Зарагдсан бараа байхгүй байна'
                          : 'Худалдан авсан бараа байхгүй байна',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  type == 'selling'
                      ? 'Таны зар энд харагдана'
                      : type == 'sold'
                          ? 'Зарагдсан бараанууд энд харагдана'
                          : 'Худалдан авсан бараанууд энд харагдана',
                  style: GoogleFonts.lato(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (type == 'selling') ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add navigation to create listing screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Шинэ зар нэмэх',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (type == 'selling') {
              await clothesProvider.loadMyListings();
            } else if (type == 'sold') {
              await clothesProvider.loadSoldItems();
            } else {
              await clothesProvider.loadBoughtItems();
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(item, type);
            },
          ),
        );
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, String type) {
    final cardColor = const Color(0xFF1A3C2E);
    final accentColor = const Color(0xFF0F594F);
    final price = (item['price'] is String)
        ? double.tryParse(item['price']) ?? 0.0
        : (item['price'] as num?)?.toDouble() ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.white.withOpacity(0.1),
                child: item['image_base64'] != null
                    ? Image.memory(
                        base64Decode(item['image_base64']),
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.image,
                        color: Colors.white.withOpacity(0.7),
                        size: 40,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? 'Гарчиггүй',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: GoogleFonts.lato(
                      color: const Color(0xFF74C69D),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            if (type == 'selling')
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white70,
                ),
                onPressed: () => _showOptionsBottomSheet(context, item),
              ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context, Map<String, dynamic> item) {
    final cardColor = const Color(0xFF1A3C2E);
    final accentColor = const Color(0xFF0F594F);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.edit,
                  color: accentColor,
                ),
                title: Text(
                  'Зар засах',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit functionality
                },
              ),
              const Divider(height: 1, color: Colors.white24),
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  'Зар устгах',
                  style: GoogleFonts.lato(
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement delete functionality
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
