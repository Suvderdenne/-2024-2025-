import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/clothes_provider.dart';
import '../models/clothes_category.dart';
import 'package:google_fonts/google_fonts.dart';

class AddClothesScreen extends StatefulWidget {
  const AddClothesScreen({super.key});

  @override
  State<AddClothesScreen> createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _sizeController = TextEditingController();
  final _brandController = TextEditingController();
  final _pickupLocationController = TextEditingController();
  final _shippingCostController = TextEditingController();
  final _reasonController = TextEditingController();
  final _originalPriceController = TextEditingController();

  XFile? _imageFile;
  String? _imageBase64;
  String _selectedGender = 'U';
  String _selectedCondition = 'good';
  int? _selectedCategoryId;
  bool _availableForPickup = false;
  bool _isSubmitting = false;

  final Map<String, String> _genderChoices = {
    'M': 'Эрэгтэй',
    'F': 'Эмэгтэй',
    'U': 'Хоёулаад',
  };

  final Map<String, String> _conditionChoices = {
    'new': 'Шинэ (шошготой)',
    'like_new': 'Шинэ шиг',
    'good': 'Сайхан',
    'fair': 'Дунд',
    'poor': 'Муу',
  };

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = pickedFile;
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Зураг сонгоход алдаа гарлаа: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Зураг сонгоно уу'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ангилал сонгоно уу'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final price = double.parse(_priceController.text);
      final originalPrice = _originalPriceController.text.isNotEmpty 
          ? double.parse(_originalPriceController.text) 
          : null;
      
      final shippingCost = _shippingCostController.text.isNotEmpty 
          ? double.parse(_shippingCostController.text) 
          : null;

      final size = _sizeController.text.trim().isNotEmpty ? _sizeController.text.trim() : null;
      final brand = _brandController.text.trim().isNotEmpty ? _brandController.text.trim() : null;
      final pickupLocation = _pickupLocationController.text.trim().isNotEmpty 
          ? _pickupLocationController.text.trim() 
          : null;
      final reasonForSale = _reasonController.text.trim().isNotEmpty 
          ? _reasonController.text.trim() 
          : null;

      await Provider.of<ClothesProvider>(context, listen: false).addClothes(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        price,
        _imageBase64!,
        _phoneController.text.trim(),
        _selectedCategoryId!,
        _selectedGender,
        condition: _selectedCondition,
        originalPrice: originalPrice,
        size: size,
        brand: brand,
        availableForPickup: _availableForPickup,
        pickupLocation: pickupLocation,
        shippingCost: shippingCost,
        reasonForSale: reasonForSale,
      );

      if (!mounted) return;
      
      await Provider.of<ClothesProvider>(context, listen: false).loadClothes();
      
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Алдаа гарлаа: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    _sizeController.dispose();
    _brandController.dispose();
    _pickupLocationController.dispose();
    _shippingCostController.dispose();
    _reasonController.dispose();
    _originalPriceController.dispose();
    super.dispose();
  }

  Widget _buildImagePreview() {
    final backgroundColor = const Color.fromARGB(255, 10, 38, 46);
    final cardColor = const Color(0xFF1A3C2E);

    if (_imageFile == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 50,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'Зураг оруулах',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: kIsWeb
                  ? NetworkImage(_imageFile!.path)
                  : FileImage(File(_imageFile!.path)) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() {
                _imageFile = null;
                _imageBase64 = null;
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefixText,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    final cardColor = const Color(0xFF1A3C2E);
    
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: Colors.white70),
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

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color.fromARGB(255, 10, 38, 46);
    final cardColor = const Color(0xFF1A3C2E);
    final accentColor = const Color(0xFF0F594F);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Шинэ бараа нэмэх',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isSubmitting
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: _buildImagePreview(),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    _buildTextField(
                      controller: _titleController,
                      label: 'Гарчиг*',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Гарчиг оруулна уу' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Тайлбар*',
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Тайлбар оруулна уу' : null,
                    ),
                    const SizedBox(height: 16),

                    // Price
                    _buildTextField(
                      controller: _priceController,
                      label: 'Үнэ*',
                      prefixText: '\$ ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Үнэ оруулна уу';
                        final price = double.tryParse(value!);
                        if (price == null) return 'Буруу тоо';
                        if (price <= 0) return 'Үнэ 0-ээс их байх ёстой';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Original Price
                    _buildTextField(
                      controller: _originalPriceController,
                      label: 'Жинхэнэ үнэ',
                      prefixText: '\$ ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return null;
                        final price = double.tryParse(value!);
                        if (price == null) return 'Буруу тоо';
                        if (price <= 0) return 'Үнэ 0-ээс их байх ёстой';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Утасны дугаар*',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Утасны дугаар оруулна уу';
                        if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value!)) {
                          return 'Зөв утасны дугаар оруулна уу';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Size
                    _buildTextField(
                      controller: _sizeController,
                      label: 'Хэмжээ',
                    ),
                    const SizedBox(height: 16),

                    // Brand
                    _buildTextField(
                      controller: _brandController,
                      label: 'Брэнд',
                    ),
                    const SizedBox(height: 16),

                    // Condition
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCondition,
                        items: _conditionChoices.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(
                                    e.value,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCondition = value!),
                        decoration: const InputDecoration(
                          labelText: 'Төлөв*',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        dropdownColor: cardColor,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        items: _genderChoices.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(
                                    e.value,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedGender = value!),
                        decoration: const InputDecoration(
                          labelText: 'Хүйс*',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        dropdownColor: cardColor,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category
                    FutureBuilder<List<ClothesCategory>>(
                      future: Provider.of<ClothesProvider>(context, listen: false)
                          .getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Алдаа гарлаа: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButtonFormField<int>(
                            value: _selectedCategoryId,
                            items: snapshot.data
                                ?.map((category) => DropdownMenuItem(
                                      value: category.id,
                                      child: Text(
                                        category.name,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedCategoryId = value),
                            decoration: const InputDecoration(
                              labelText: 'Ангилал*',
                              labelStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                            dropdownColor: cardColor,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) =>
                                value == null ? 'Ангилал сонгоно уу' : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pickup Options
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Авч очих боломжтой',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: _availableForPickup,
                        onChanged: (value) =>
                            setState(() => _availableForPickup = value),
                      ),
                    ),
                    if (_availableForPickup) ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _pickupLocationController,
                        label: 'Авч очих газар',
                        validator: (value) =>
                            _availableForPickup && (value?.isEmpty ?? true)
                                ? 'Авч очих газар оруулна уу'
                                : null,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Shipping Cost
                    _buildTextField(
                      controller: _shippingCostController,
                      label: 'Хүргэлтийн төлбөр',
                      prefixText: '\$ ',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isNotEmpty ?? false) {
                          if (double.tryParse(value!) == null) return 'Буруу тоо';
                          if (double.parse(value) < 0) return 'Төлбөр сөрөг байж болохгүй';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Reason for Sale
                    _buildTextField(
                      controller: _reasonController,
                      label: 'Зарах шалтгаан',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Нэмэх',
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
}
