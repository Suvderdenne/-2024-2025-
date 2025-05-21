import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yapnvibefe/pages/packitem.dart';
import 'dart:convert';

class PacksScreen extends StatefulWidget {
  const PacksScreen({super.key});

  @override
  State<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends State<PacksScreen>
    with TickerProviderStateMixin {
  List packs = [];
  String? userId;
  int? selectedPackId;
  late AnimationController _bgAnimation;

  @override
  void initState() {
    super.initState();
    _bgAnimation = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    fetchPacks();
  }

  @override
  void dispose() {
    _bgAnimation.dispose();
    super.dispose();
  }

  Future<void> fetchPacks() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
    if (userId == null) return;

    final res =
        await http.get(Uri.parse('http://127.0.0.1:8000/packs/$userId/'));
    // await http.get(Uri.parse('http://192.168.4.245/packs/$userId/'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['pack_data'] != null) {
        setState(() {
          packs = data['pack_data'];
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load packs')),
      );
    }
  }

  void _navigateToPackItems(int packId) {
    final selectedPack =
        packs.firstWhere((p) => p['id'] == packId, orElse: () => {});
    final isUserPack =
        selectedPack.isNotEmpty && selectedPack['user'] == userId;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PackItemsScreen(
          packId: packId,
          userId: userId!,
          isUserPack: isUserPack,
        ),
      ),
    );
  }

  Future<void> _showCreatePackDialog() async {
    final TextEditingController packNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create a New Pack'),
          content: TextField(
            controller: packNameController,
            decoration: const InputDecoration(labelText: 'Pack Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final packName = packNameController.text.trim();
                if (packName.isNotEmpty) {
                  final response = await http.post(
                    Uri.parse('http://127.0.0.1:8000/pack/add/'),
                    // Uri.parse('http://192.168.4.245/pack/add/'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'name': packName,
                      'user_id': userId,
                    }),
                  );

                  if (response.statusCode == 200) {
                    fetchPacks();
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to create pack')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a pack
  Future<void> _deletePack(int packId) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Pack'),
          content: const Text('Are you sure you want to delete this pack?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel deletion
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      try {
        final response = await http.delete(
          Uri.parse('http://127.0.0.1:8000/pack/delete/$packId/'),
          // Uri.parse('http://192.168.4.245/pack/delete/$packId/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId}),
        );

        if (response.statusCode == 200) {
          setState(() {
            packs.removeWhere((pack) => pack['id'] == packId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pack deleted')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete pack')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred during deletion')),
        );
      }
    }
  }

  // Function to edit a pack
  Future<void> _editPack(int packId) async {
    final selectedPack =
        packs.firstWhere((pack) => pack['id'] == packId, orElse: () => {});

    if (selectedPack.isNotEmpty) {
      final TextEditingController packNameController =
          TextEditingController(text: selectedPack['name']);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Pack'),
            content: TextField(
              controller: packNameController,
              decoration: const InputDecoration(labelText: 'Pack Name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final packName = packNameController.text.trim();
                  if (packName.isNotEmpty) {
                    final response = await http.put(
                      Uri.parse('http://127.0.0.1:8000/pack/edit/$packId/'),
                      // Uri.parse('http://192.168.4.245/pack/edit/$packId/'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'name': packName,
                        'user_id': userId,
                      }),
                    );

                    if (response.statusCode == 200) {
                      fetchPacks(); // Refresh the list after editing
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to edit pack')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(Colors.pink[100], Colors.purple[100],
                      _bgAnimation.value)!,
                  Color.lerp(
                      Colors.orange[100], Colors.white, _bgAnimation.value)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Text('Choose a Pack',
                        style: TextStyle(color: Colors.black)),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.pink),
                        onPressed: _showCreatePackDialog,
                      ),
                    ],
                    centerTitle: true,
                  ),
                  packs.isEmpty
                      ? const Expanded(
                          child: Center(child: CircularProgressIndicator()))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: packs.length,
                            itemBuilder: (context, index) {
                              final pack = packs[index];
                              return ListTile(
                                title: Row(
                                  children: [
                                    Icon(Icons.style,
                                        color: Colors.pink), // Icon to display
                                    SizedBox(
                                        width:
                                            8), // Space between icon and text
                                    Text(
                                      pack['name'],
                                      style: TextStyle(
                                        color: selectedPackId == pack['id']
                                            ? Colors.pink
                                            : Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: pack['user'] == userId
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () =>
                                                _editPack(pack['id']),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _deletePack(pack['id']),
                                          ),
                                        ],
                                      )
                                    : null,
                                onTap: () => _navigateToPackItems(pack['id']),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
