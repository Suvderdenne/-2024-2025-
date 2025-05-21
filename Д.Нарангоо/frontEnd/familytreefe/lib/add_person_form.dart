import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api/api_service.dart';

class AddPersonForm extends StatefulWidget {
  final AuthService authService;
  final Function? onPersonAdded;

  const AddPersonForm({
    super.key,
    required this.authService,
    this.onPersonAdded,
  });

  @override
  _AddPersonFormState createState() => _AddPersonFormState();
}

class _AddPersonFormState extends State<AddPersonForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _biographyController = TextEditingController();
  String _selectedGender = 'Эр';
  DateTime _selectedBirthDate = DateTime.now();
  DateTime? _selectedDeathDate;
  Map<String, dynamic>? _selectedBirthplace;
  Map<String, dynamic>? _selectedUrgiinOvog;
  Map<String, dynamic>? _selectedUye;
  List<Map<String, dynamic>> _places = [];
  List<Map<String, dynamic>> _urgiinOvogList = [];
  List<Map<String, dynamic>> _uyeList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _loadUrgiinOvog();
    _loadUye();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    setState(() => _isLoading = true);
    try {
      final places = await widget.authService.getPlaces();
      setState(() => _places = places);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Газрын мэдээлэл ачаалахад алдаа гарлаа: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUrgiinOvog() async {
    setState(() => _isLoading = true);
    try {
      final urgiinOvog = await widget.authService.getUrgiinOvog();
      setState(() => _urgiinOvogList = urgiinOvog);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ургийн овгийн мэдээлэл ачаалахад алдаа гарлаа: $e'),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUye() async {
    setState(() => _isLoading = true);
    try {
      final uye = await widget.authService.getUye();
      setState(() => _uyeList = uye);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Үеийн мэдээлэл ачаалахад алдаа гарлаа: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final person = {
          'name': _nameController.text,
          'lastname': _lastnameController.text,
          'gender': _selectedGender,
          'birthdate': _selectedBirthDate.toIso8601String().split('T')[0],
          'diedate': _selectedDeathDate?.toIso8601String().split('T')[0],
          'biography': _biographyController.text,
          'birthplace': _selectedBirthplace,
          'urgiinovog_id': _selectedUrgiinOvog?['uid'],
          'uye_id': _selectedUye?['uid'],
        };

        final success = await widget.authService.createSimplePerson(person);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Хүн амжилттай нэмэгдлээ')),
            );
            if (widget.onPersonAdded != null) {
              widget.onPersonAdded!();
            }
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Хүн нэмэхэд алдаа гарлаа')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Алдаа гарлаа: $e')));
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Хүн нэмэх'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Нэр',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Нэр оруулна уу';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastnameController,
                        decoration: const InputDecoration(
                          labelText: 'Овог',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Хүйс',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Эр', child: Text('Эр')),
                          DropdownMenuItem(value: 'Эм', child: Text('Эм')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Төрсөн огноо'),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd').format(_selectedBirthDate),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, true),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Нас барсан огноо'),
                        subtitle: Text(
                          _selectedDeathDate != null
                              ? DateFormat(
                                'yyyy-MM-dd',
                              ).format(_selectedDeathDate!)
                              : 'Тодорхойгүй',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, false),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedBirthplace,
                        decoration: const InputDecoration(
                          labelText: 'Төрсөн газар',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _places.map((place) {
                              return DropdownMenuItem(
                                value: place,
                                child: Text(
                                  '${place['name']}, ${place['country']}',
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBirthplace = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedUrgiinOvog,
                        decoration: const InputDecoration(
                          labelText: 'Ургийн овог',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _urgiinOvogList.map((urgiinOvog) {
                              return DropdownMenuItem(
                                value: urgiinOvog,
                                child: Text(urgiinOvog['urgiinovog']),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUrgiinOvog = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedUye,
                        decoration: const InputDecoration(
                          labelText: 'Үе',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _uyeList.map((uye) {
                              return DropdownMenuItem(
                                value: uye,
                                child: Text(
                                  '${uye['uyname']} (${uye['level']})',
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUye = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _biographyController,
                        decoration: const InputDecoration(
                          labelText: 'Намтар',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Нэмэх',
                                    style: TextStyle(fontSize: 16),
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
