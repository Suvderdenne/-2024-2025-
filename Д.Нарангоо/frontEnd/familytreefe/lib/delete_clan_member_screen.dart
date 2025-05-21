import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../api/api_service.dart';

class DeleteClanMemberScreen extends StatefulWidget {
  final AuthService authService;
  final List<FamilyMember> members;

  const DeleteClanMemberScreen({
    super.key,
    required this.authService,
    required this.members,
  });

  @override
  State<DeleteClanMemberScreen> createState() => _DeleteClanMemberScreenState();
}

class _DeleteClanMemberScreenState extends State<DeleteClanMemberScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FamilyMember> filteredMembers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    filteredMembers = widget.members;
    _searchController.addListener(_filterMembers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMembers =
          widget.members.where((member) {
            return member.name.toLowerCase().contains(query) ||
                (member.lastname?.toLowerCase().contains(query) ?? false);
          }).toList();
    });
  }

  Future<void> _deleteMember(FamilyMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Гишүүн устгах'),
            content: Text(
              'Та ${member.name} гишүүнийг устгахдаа итгэлтэй байна уу?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Болих'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Устгах',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        isLoading = true;
      });

      try {
        // First, remove all relationships with this member
        final success = await widget.authService.deleteFamilyMember(member.uid);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${member.name} гишүүн амжилттай устгагдлаа'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return success
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Гишүүнийг устгахад алдаа гарлаа'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Алдаа гарлаа: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Гишүүн устгах',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.black),
                          hintText: 'Хайх утгаа оруулна уу!',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  // Members List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                member.gender == 'Эр'
                                    ? Colors.blue
                                    : Colors.pink,
                            child: Icon(
                              member.gender == 'Эр' ? Icons.male : Icons.female,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            '${member.lastname ?? ''} ${member.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Төрсөн: ${member.birthdate.year}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMember(member),
                            tooltip: 'Устгах',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
