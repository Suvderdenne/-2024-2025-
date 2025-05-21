import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/family_member.dart';
import '../api/api_service.dart';

class EditClanMemberScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onMemberUpdated;
  final FamilyMember member;

  const EditClanMemberScreen({
    super.key,
    required this.authService,
    required this.onMemberUpdated,
    required this.member,
  });

  @override
  _EditClanMemberScreenState createState() => _EditClanMemberScreenState();
}

class _EditClanMemberScreenState extends State<EditClanMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _biographyController = TextEditingController();
  String _selectedGender = 'Эр';
  DateTime _selectedBirthDate = DateTime.now();
  DateTime? _selectedDeathDate;
  String? _selectedPlaceId;
  String? _selectedUyeId;
  String? _selectedUrgiinOvogId;
  List<Map<String, dynamic>> _places = [];
  List<Map<String, dynamic>> _uye = [];
  List<Map<String, dynamic>> _urgiinOvog = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadData();
  }

  void _initializeData() {
    // Initialize form fields with existing member data
    _nameController.text = widget.member.name;
    _lastnameController.text = widget.member.lastname ?? '';
    _selectedGender = widget.member.gender;
    _selectedBirthDate = widget.member.birthdate;
    _selectedDeathDate = widget.member.diedate;
    _biographyController.text = widget.member.biography ?? '';

    // Set place ID if available
    if (widget.member.birthplace != null) {
      _selectedPlaceId = widget.member.birthplace!['uid'];
    }

    // Set uye ID if available
    if (widget.member.generation != null) {
      _selectedUyeId = widget.member.generation!['uid'];
    }

    // Set urgiinovog ID if available
    if (widget.member.urgiinovog != null) {
      _selectedUrgiinOvogId = widget.member.urgiinovog!['uid'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final places = await widget.authService.getPlaces();
      final uye = await widget.authService.getUye();
      final urgiinOvog = await widget.authService.getUrgiinOvog();

      setState(() {
        _places = places;
        _uye = uye;
        _urgiinOvog = urgiinOvog;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isBirthDate
              ? _selectedBirthDate
              : (_selectedDeathDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _selectedBirthDate = picked;
        } else {
          _selectedDeathDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green[800]!, Colors.green[600]!],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        '${widget.member.lastname ?? ''} ${widget.member.name}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Мэдээлэл засах',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSection('Хувийн мэдээлэл', Icons.person, [
                              _buildTextField(
                                controller: _nameController,
                                label: 'Нэр',
                                icon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Нэр оруулна уу';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _lastnameController,
                                label: 'Овог',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                value: _selectedGender,
                                label: 'Хүйс',
                                icon: Icons.person,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Эр',
                                    child: Text('Эр'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Эм',
                                    child: Text('Эм'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildDateField(
                                label: 'Төрсөн огноо',
                                value: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(_selectedBirthDate),
                                onTap: () => _selectDate(context, true),
                              ),
                              const SizedBox(height: 16),
                              _buildDateField(
                                label: 'Нас барсан огноо',
                                value:
                                    _selectedDeathDate != null
                                        ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(_selectedDeathDate!)
                                        : 'Тодорхойгүй',
                                onTap: () => _selectDate(context, false),
                              ),
                            ]),
                            const SizedBox(height: 24),
                            _buildSection('Нэмэлт мэдээлэл', Icons.info, [
                              _buildDropdown(
                                value: _selectedPlaceId,
                                label: 'Төрсөн газар',
                                icon: Icons.location_on,
                                items:
                                    _places.map((place) {
                                      return DropdownMenuItem<String>(
                                        value: place['uid']?.toString(),
                                        child: Text(
                                          '${place['name']} (${place['country']})',
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPlaceId = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                value: _selectedUyeId,
                                label: 'Үе',
                                icon: Icons.generating_tokens,
                                items:
                                    _uye.map((uye) {
                                      return DropdownMenuItem<String>(
                                        value: uye['uid']?.toString(),
                                        child: Text(
                                          uye['uyname']?.toString() ??
                                              'Unknown',
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUyeId = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                value: _selectedUrgiinOvogId,
                                label: 'Ургийн овог',
                                icon: Icons.family_restroom,
                                items:
                                    _urgiinOvog.map((ovog) {
                                      return DropdownMenuItem<String>(
                                        value: ovog['uid']?.toString(),
                                        child: Text(
                                          ovog['urgiinovog']?.toString() ??
                                              'Unknown',
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUrgiinOvogId = value;
                                  });
                                },
                              ),
                            ]),
                            const SizedBox(height: 24),
                            _buildSection('Намтар', Icons.book, [
                              _buildTextField(
                                controller: _biographyController,
                                label: 'Намтар',
                                icon: Icons.book,
                                maxLines: 5,
                              ),
                            ]),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[800],
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Хадгалах',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
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

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green[800], size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[800]!),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[800]!),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today, color: Colors.green[800]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[800]!),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        child: Text(value),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create updated member object
        final updatedMember = FamilyMember(
          fromPersonId: widget.member.fromPersonId,
          uid: widget.member.uid,
          relationshipType: widget.member.relationshipType,
          name: _nameController.text,
          lastname: _lastnameController.text,
          gender: _selectedGender,
          birthdate: _selectedBirthDate,
          diedate: _selectedDeathDate,
          biography: _biographyController.text,
          birthplace:
              _selectedPlaceId != null
                  ? {
                    'uid': _selectedPlaceId,
                    'name':
                        _places.firstWhere(
                          (p) => p['uid'] == _selectedPlaceId,
                        )['name'],
                    'country':
                        _places.firstWhere(
                          (p) => p['uid'] == _selectedPlaceId,
                        )['country'],
                  }
                  : null,
          generation:
              _selectedUyeId != null
                  ? {
                    'uid': _selectedUyeId,
                    'uyname':
                        _uye.firstWhere(
                          (u) => u['uid'] == _selectedUyeId,
                        )['uyname'],
                    'level':
                        _uye.firstWhere(
                          (u) => u['uid'] == _selectedUyeId,
                        )['level'],
                  }
                  : null,
          urgiinovog:
              _selectedUrgiinOvogId != null
                  ? {
                    'uid': _selectedUrgiinOvogId,
                    'urgiinovog':
                        _urgiinOvog.firstWhere(
                          (u) => u['uid'] == _selectedUrgiinOvogId,
                        )['urgiinovog'],
                  }
                  : null,
        );

        // Call the API to update the member
        final success = await widget.authService.updateFamilyMember(
          updatedMember,
        );

        if (success && mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Овгийн гишүүн амжилттай шинэчлэгдлээ!'),
              backgroundColor: Colors.green,
            ),
          );

          // Call the callback to refresh the list
          widget.onMemberUpdated();

          // Navigate back to the previous screen
          Navigator.of(context).pop();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Овгийн гишүүн шинэчлэхэд алдаа гарлаа!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Алдаа: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
