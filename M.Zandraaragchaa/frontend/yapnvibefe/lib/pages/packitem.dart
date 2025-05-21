import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yapnvibefe/pages/spy.dart';

class PackItemsScreen extends StatefulWidget {
  final int packId;
  final String userId; // Add userId to identify the user
  final bool isUserPack;

  const PackItemsScreen({
    super.key,
    required this.packId,
    required this.userId,
    required this.isUserPack,
  });

  @override
  _PackItemsScreenState createState() => _PackItemsScreenState();
}

class _PackItemsScreenState extends State<PackItemsScreen>
    with TickerProviderStateMixin {
  List packItems = [];
  String? currentUserId;
  late AnimationController _bgAnimation;

  @override
  void initState() {
    super.initState();
    fetchPackItems();
    _getCurrentUserId();
    _bgAnimation = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimation.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('user_id');
    });
  }

  Future<void> fetchPackItems() async {
    final response = await http.get(Uri.parse(
        'http://127.0.0.1:8000/packitems/${widget.packId}/?user_id=${widget.userId}'));
    // 'http://192.168.4.245/packitems/${widget.packId}/?user_id=${widget.userId}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        packItems = data['packitem_data'] ?? [];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load pack items')),
      );
    }
  }

  Future<void> _addPackItem() async {
    final TextEditingController itemController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Add Pack Item', style: TextStyle(color: Colors.pink)),
          content: TextField(
            controller: itemController,
            decoration: const InputDecoration(labelText: 'Pack Item Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final itemName = itemController.text.trim();
                if (itemName.isNotEmpty) {
                  try {
                    final response = await http.post(
                      Uri.parse('http://127.0.0.1:8000/packitem/add/'),
                      // Uri.parse('http://192.168.4.245/packitem/add/'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'pack_id': widget.packId,
                        'itemname': itemName,
                        'user_id': widget.userId,
                      }),
                    );

                    if (response.statusCode == 200) {
                      fetchPackItems();
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to add pack item')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error occurred')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePackItem(int itemId) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      try {
        final response = await http.delete(
          Uri.parse('http://127.0.0.1:8000/packitem/delete/$itemId/'),
          // Uri.parse('http://192.168.4.245/packitem/delete/$itemId/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': widget.userId}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pack item deleted')),
          );
          fetchPackItems();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete pack item')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred during deletion')),
        );
      }
    }
  }

  Future<void> updateSpyPack(String userId, int packId, bool isOwn) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/spypack/edit/$userId/'),
        // Uri.parse('http://192.168.4.245/spypack/edit/$userId/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pack': packId,
          'isown': isOwn,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spy pack updated successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Spy(),
          ),
        );
// ✅ Go back after selection
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update spy pack')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error occurred while updating spy pack')),
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
                    title: const Text('Pack Items',
                        style: TextStyle(color: Colors.black)),
                    actions: [
                      if (widget.isUserPack)
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.pink),
                          onPressed: _addPackItem,
                        ),
                    ],
                    centerTitle: true,
                  ),
                  packItems.isEmpty
                      ? const Expanded(
                          child: Center(child: CircularProgressIndicator()))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: packItems.length,
                            itemBuilder: (context, index) {
                              final item = packItems[index];
                              final canEdit = item['can_edit'] ?? false;

                              return ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Colors.pink),
                                title: Text(
                                  item['itemname'],
                                  style: const TextStyle(color: Colors.black),
                                ),
                                trailing: canEdit
                                    ? IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deletePackItem(item['id']),
                                      )
                                    : null,
                                onTap: () {}, // Optional tap action
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
      floatingActionButton: SizedBox(
        height: 50,
        child: FloatingActionButton.extended(
          onPressed: () {
            updateSpyPack(widget.userId, widget.packId, widget.isUserPack);
          },
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text('Select', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.pink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
