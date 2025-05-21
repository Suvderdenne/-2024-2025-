import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../api/api_service.dart';
import 'package:flutter/foundation.dart';

class AddRelationshipScreen extends StatefulWidget {
  final AuthService authService;
  final List<FamilyMember> members;
  final VoidCallback onRelationshipAdded;

  const AddRelationshipScreen({
    super.key,
    required this.authService,
    required this.members,
    required this.onRelationshipAdded,
  });

  @override
  State<AddRelationshipScreen> createState() => _AddRelationshipScreenState();
}

class _AddRelationshipScreenState extends State<AddRelationshipScreen> {
  FamilyMember? _selectedFromMember;
  FamilyMember? _selectedToMember;
  String _selectedRelationshipType = 'ХҮҮХЭД';
  List<Map<String, dynamic>> _relationshipTypes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRelationshipTypes();
  }

  Future<void> _loadRelationshipTypes() async {
    try {
      final types = await widget.authService.getRelationshipTypes();
      setState(() {
        _relationshipTypes = types;
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading relationship types: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _addRelationship() async {
    if (_selectedFromMember == null || _selectedToMember == null) {
      _showSnackBar('Та хоёр гишүүнийг сонгоно уу');
      return;
    }

    // Validate that both members have valid UIDs
    if (_selectedFromMember!.uid.isEmpty || _selectedToMember!.uid.isEmpty) {
      _showSnackBar('Буруу гишүүн сонголт байна. Дахин оролдоно уу.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (kDebugMode) {
        print('Adding relationship with:');
        print('fromPersonId: ${_selectedFromMember!.uid}');
        print('toPersonId: ${_selectedToMember!.uid}');
        print('relationshipType: $_selectedRelationshipType');
      }

      final success = await widget.authService.addRelationship(
        fromPersonId: _selectedFromMember!.uid,
        toPersonId: _selectedToMember!.uid,
        relationshipType: _selectedRelationshipType,
      );

      if (success) {
        if (mounted) {
          _showSnackBar('Харилцаа амжилттай нэмэгдлээ');
          widget.onRelationshipAdded();
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          _showSnackBar('Харилцаа нэмэхэд алдаа гарлаа');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Харилцаа нэмэх үед алдаа гарлаа: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showSelectionDialog({
    required String title,
    required List<FamilyMember> members,
    required Function(FamilyMember) onSelected,
  }) async {
    await showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return Card(
                          elevation: 0,
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: Text(
                              '${member.lastname ?? ''} ${member.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              member.relationshipType,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            onTap: () {
                              onSelected(member);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _showRelationshipTypeDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Харилцааны төрөл сонгох',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _relationshipTypes.length,
                      itemBuilder: (context, index) {
                        final type = _relationshipTypes[index];
                        return Card(
                          elevation: 0,
                          color:
                              _selectedRelationshipType == type['type']
                                  ? Colors.green[50]
                                  : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading:
                                _selectedRelationshipType == type['type']
                                    ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                    : const Icon(Icons.person_outline),
                            title: Text(type['label']),
                            onTap: () {
                              setState(() {
                                _selectedRelationshipType = type['type'];
                              });
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required IconData icon,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: color ?? Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.green[800], size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Харилцаа нэмэх',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[800]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Гэр бүлийн гишүүд хоорондын харилцааг тодорхойлно уу',
                        style: TextStyle(color: Colors.blue[800], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // From Member Selection
              _buildSelectionCard(
                title: 'Эхлэх гишүүн',
                subtitle: _selectedFromMember?.name ?? 'Сонгох',
                icon: Icons.person,
                color: Colors.green[50],
                onTap: () {
                  _showSelectionDialog(
                    title: 'Эхлэх гишүүн сонгох',
                    members: widget.members,
                    onSelected: (member) {
                      if (kDebugMode) {
                        print(
                          'Selected from member: ${member.name} with uid: ${member.uid}',
                        );
                      }
                      setState(() {
                        _selectedFromMember = member;
                      });
                    },
                  );
                },
              ),

              // To Member Selection
              _buildSelectionCard(
                title: 'Харилцаатай гишүүн',
                subtitle: _selectedToMember?.name ?? 'Сонгох',
                icon: Icons.people_alt,
                color: Colors.amber[50],
                onTap: () {
                  _showSelectionDialog(
                    title: 'Харилцаатай гишүүн сонгох',
                    members: widget.members,
                    onSelected: (member) {
                      if (kDebugMode) {
                        print(
                          'Selected to member: ${member.name} with uid: ${member.uid}',
                        );
                      }
                      setState(() {
                        _selectedToMember = member;
                      });
                    },
                  );
                },
              ),

              // Relationship Type Selection
              _buildSelectionCard(
                title: 'Харилцааны төрөл',
                subtitle:
                    _relationshipTypes.isEmpty
                        ? 'Ачаалж байна...'
                        : _relationshipTypes.firstWhere(
                          (type) => type['type'] == _selectedRelationshipType,
                          orElse: () => {'label': _selectedRelationshipType},
                        )['label'],
                icon: Icons.connect_without_contact,
                color: Colors.purple[50],
                onTap: () {
                  if (_relationshipTypes.isEmpty) {
                    _showSnackBar('Харилцааны төрлүүдийг ачаалж байна...');
                    return;
                  }
                  _showRelationshipTypeDialog();
                },
              ),

              const Spacer(),

              // Submit Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addRelationship,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Ачаалж байна...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withAlpha(
                                    (0.8 * 255).round(),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : const Text(
                            'Харилцаа нэмэх',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
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
