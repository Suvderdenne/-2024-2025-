import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/family_member.dart';
import '../api/api_service.dart';

class AddClanMemberScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onMemberAdded;
  final String fromPersonId;
  final String relationshipType;

  const AddClanMemberScreen({
    super.key,
    required this.authService,
    required this.onMemberAdded,
    required this.fromPersonId,
    required this.relationshipType,
  });

  @override
  _AddClanMemberScreenState createState() => _AddClanMemberScreenState();
}

class _AddClanMemberScreenState extends State<AddClanMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _biographyController = TextEditingController();
  String _selectedGender = 'Эр';
  String _selectedRelationshipType = 'ХҮҮХЭД';
  DateTime _selectedBirthDate = DateTime.now();
  DateTime? _selectedDeathDate;
  String? _selectedPlaceId;
  String? _selectedUyeId;
  String? _selectedUrgiinOvogId;
  List<Map<String, dynamic>> _places = [];
  List<Map<String, dynamic>> _uye = [];
  List<Map<String, dynamic>> _urgiinOvog = [];
  List<Map<String, dynamic>> _relationshipTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setGenderFromRelationship();
  }

  void _setGenderFromRelationship() {
    setState(() {
      switch (_selectedRelationshipType) {
        case 'ЭХ':
        case 'ЭГЧ':
        case 'ЭМЭЭ':
          _selectedGender = 'Эм';
          break;
        case 'ЭЦЭГ':
        case 'АХ':
        case 'ӨВӨӨ':
          _selectedGender = 'Эр';
          break;
        default:
          _selectedGender = 'Эр';
      }
    });
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
      final relationshipTypes = await widget.authService.getRelationshipTypes();

      setState(() {
        _places = places;
        _uye = uye;
        _urgiinOvog = urgiinOvog;
        _relationshipTypes = relationshipTypes;
        _selectedRelationshipType = widget.relationshipType;
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
                      const Text(
                        'Овгийн гишүүн нэмэх',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Шинэ гишүүний мэдээлэл оруулах',
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
                                value: _selectedRelationshipType,
                                label: 'Хамаарал',
                                icon: Icons.people,
                                items:
                                    _relationshipTypes.map((type) {
                                      return DropdownMenuItem<String>(
                                        value: type['type'],
                                        child: Text(
                                          type['label'] ?? type['type'],
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRelationshipType = value!;
                                    _setGenderFromRelationship();
                                  });
                                },
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
                                'Нэмэх',
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
        final member = FamilyMember(
          fromPersonId: widget.fromPersonId,
          uid: const Uuid().v4(),
          relationshipType: _selectedRelationshipType,
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

        final success = await widget.authService.createFamilyMember(member);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Овгийн гишүүн амжилттай нэмэгдлээ!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onMemberAdded();
          Navigator.of(context).pop();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Овгийн гишүүн нэмэхэд алдаа гарлаа!'),
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
