import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/profile_service.dart';
import 'dart:ui';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final int? userId; // If null, show current user's profile

  const ProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic>? _profile;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Enhanced theme colors
  final Color primaryColor = const Color(0xFF1E293B);
  final Color accentColor = const Color(0xFF3B82F6);
  final Color highlightColor = const Color(0xFF10B981);
  final Color bgColor = const Color(0xFFF8FAFC);
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF1E293B);
  final Color textSecondaryColor = const Color(0xFF64748B);

  // Controllers for editing
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final profile = widget.userId != null
          ? await _profileService.getUserProfile(widget.userId!)
          : await _profileService.getMyProfile();

      setState(() {
        _profile = profile;
        _phoneController.text = profile['phone_number'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _bioController.text = profile['bio'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final updatedProfile = await _profileService.updateProfile(
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        bio: _bioController.text,
      );

      setState(() {
        _profile = updatedProfile;
        _isEditing = false;
        _isLoading = false;
      });

      _showSuccessSnackBar('Profile updated successfully');
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _showErrorSnackBar(e.toString());
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text(message, style: TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: highlightColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message, style: TextStyle(fontSize: 16))),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
          _error = null;
        });

        // Read the image file and convert to base64
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Upload the image
        await _profileService.updateProfilePicture(base64Image);

        // Reload profile to get new image URL
        await _loadProfile();

        _showSuccessSnackBar('Profile picture updated successfully');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _showErrorSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: accentColor,
                strokeWidth: 3,
              ),
              SizedBox(height: 24),
              Text(
                'Loading profile...',
                style: GoogleFonts.poppins(
                  color: textSecondaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(Icons.error_outline, size: 48, color: Colors.red),
              ),
              SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: textPrimaryColor,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loadProfile,
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_profile == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            'Profile not found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: textSecondaryColor,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          if (widget.userId == null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: _isEditing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                // Reset form values
                                _phoneController.text =
                                    _profile!['phone_number'] ?? '';
                                _addressController.text =
                                    _profile!['address'] ?? '';
                                _bioController.text = _profile!['bio'] ?? '';
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.white),
                            onPressed: _updateProfile,
                          ),
                        ],
                      )
                    : IconButton(
                        key: ValueKey('edit'),
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          setState(() => _isEditing = true);
                        },
                      ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            // Profile Header with Cover Image
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                child: Stack(
                  children: [
                    // Cover Image or Gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              primaryColor,
                              accentColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Dark overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Profile Picture and Name
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                // Profile picture with animated border
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        accentColor,
                                        highlightColor,
                                        accentColor,
                                      ],
                                      stops: [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                  child: Hero(
                                    tag: 'profile_picture_${_profile!['id']}',
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            _profile!['profile_picture'] != null
                                                ? MemoryImage(
                                                    base64Decode(_profile![
                                                            'profile_picture']
                                                        .split(',')[1]),
                                                    scale: 1.0,
                                                  )
                                                : null,
                                        child: _profile!['profile_picture'] ==
                                                null
                                            ? Text(
                                                _profile!['username'][0]
                                                    .toUpperCase(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                                // Camera button
                                if (widget.userId == null)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _pickAndUploadImage,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: highlightColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Username
                            Text(
                              _profile!['username'],
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            // Email
                            Text(
                              _profile!['email'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards
                      Container(
                        height: 100,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.favorite,
                                label: 'Followers',
                                value: '${_profile!['followers_count'] ?? 0}',
                                color: Colors.red.shade400,
                              ),
                            ),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.people,
                                label: 'Following',
                                value: '${_profile!['following_count'] ?? 0}',
                                color: accentColor,
                              ),
                            ),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.star,
                                label: 'Rating',
                                value: '${_profile!['rating'] ?? 4.5}',
                                color: Colors.amber.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Contact Information Card
                      _buildSectionTitle('Contact Information'),
                      SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isEditing) ...[
                                _buildTextFormField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  icon: Icons.phone,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      // Simple phone validation
                                      if (value.length < 8) {
                                        return 'Please enter a valid phone number';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                _buildTextFormField(
                                  controller: _addressController,
                                  label: 'Address',
                                  icon: Icons.location_on,
                                  maxLines: 2,
                                ),
                              ] else ...[
                                if (_profile!['phone_number'] != null &&
                                    _profile!['phone_number'].isNotEmpty)
                                  _buildInfoTile(
                                    icon: Icons.phone,
                                    title: 'Phone',
                                    subtitle: _profile!['phone_number'],
                                    iconColor: accentColor,
                                  ),
                                if (_profile!['address'] != null &&
                                    _profile!['address'].isNotEmpty)
                                  _buildInfoTile(
                                    icon: Icons.location_on,
                                    title: 'Address',
                                    subtitle: _profile!['address'],
                                    iconColor: accentColor,
                                  ),
                                if ((_profile!['phone_number'] == null ||
                                        _profile!['phone_number'].isEmpty) &&
                                    (_profile!['address'] == null ||
                                        _profile!['address'].isEmpty))
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'No contact information added yet',
                                        style: GoogleFonts.poppins(
                                          color: textSecondaryColor,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Bio Card
                      _buildSectionTitle('About'),
                      SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _isEditing
                              ? _buildTextFormField(
                                  controller: _bioController,
                                  label: 'Bio',
                                  icon: Icons.description,
                                  maxLines: 5,
                                  hint: 'Tell us about yourself...',
                                )
                              : _profile!['bio'] != null &&
                                      _profile!['bio'].isNotEmpty
                                  ? Text(
                                      _profile!['bio'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: textSecondaryColor,
                                        height: 1.5,
                                      ),
                                    )
                                  : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'No bio information added yet',
                                          style: GoogleFonts.poppins(
                                            color: textSecondaryColor,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Call-to-action section
                      if (widget.userId != null)
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: accentColor.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // TODO: Implement message functionality
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Message',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // TODO: Implement follow functionality
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: accentColor,
                                      side: BorderSide(color: accentColor),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Follow',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: textSecondaryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textSecondaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: accentColor),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textSecondaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textSecondaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: GoogleFonts.poppins(color: textSecondaryColor),
      ),
      style: GoogleFonts.poppins(
        color: textPrimaryColor,
        fontSize: 16,
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
