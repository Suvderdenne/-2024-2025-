import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:yapnvibefe/pages/spy.dart';

class Playernames extends StatefulWidget {
  final int playerCount;

  const Playernames({super.key, required this.playerCount});

  @override
  State<Playernames> createState() => _PlayernamesState();
}

class _PlayernamesState extends State<Playernames> {
  late List<TextEditingController> controllers;
  late List<int?> playerIds;
  late List<String> playerNames;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(Playernames oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playerCount != oldWidget.playerCount) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    controllers =
        List.generate(widget.playerCount, (_) => TextEditingController());
    playerIds = List.filled(widget.playerCount, null);
    playerNames = List.filled(widget.playerCount, '');
    _loadExistingPlayers();
  }

  Future<void> _loadExistingPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    // Try loading from SharedPreferences first
    List<String>? storedNames = prefs.getStringList('player_names');
    if (storedNames != null && storedNames.length == widget.playerCount) {
      for (int i = 0; i < storedNames.length; i++) {
        controllers[i].text = storedNames[i];
        playerNames[i] = storedNames[i];
      }
      setState(() {});
    }

    // Then load from server if userId exists
    if (userId == null) return;

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/players/list/$userId/'),
      // Uri.parse('http://192.168.4.245/players/list/$userId/'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List players = data['pack_data'];

      players.sort((a, b) => a['id'].compareTo(b['id']));

      for (int i = 0; i < players.length && i < widget.playerCount; i++) {
        controllers[i].text = players[i]['name'];
        playerIds[i] = players[i]['id'];
        playerNames[i] = players[i]['name'];
      }

      setState(() {});
    }
  }

  Future<void> _savePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    bool hasEmptyName =
        controllers.any((controller) => controller.text.trim().isEmpty);

    if (hasEmptyName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all player names')),
      );
      return;
    }

    // Save to SharedPreferences
    List<String> names = controllers.map((c) => c.text.trim()).toList();
    await prefs.setStringList('player_names', names);

    for (int i = 0; i < controllers.length; i++) {
      final name = controllers[i].text.trim();
      final playerId = playerIds[i];

      if (playerId == null) {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/players/add/$userId/'),
          // Uri.parse('http://192.168.4.245/players/add/$userId/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'playername': name}),
        );
        if (response.statusCode == 200) {
          final res = jsonDecode(response.body);
          playerIds[i] = res['player_id'];
        } else {
          debugPrint('Add failed: ${response.body}');
        }
      } else {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/players/edit/$playerId/'),
          // Uri.parse('http://192.168.4.245/players/edit/$playerId/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'playername': name}),
        );
        if (response.statusCode != 200) {
          debugPrint('Edit failed: ${response.body}');
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Players saved')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Spy()),
    );
  }

  Future<void> _deletePlayer(int index) async {
    final playerId = playerIds[index];
    if (playerId == null) return;

    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/players/delete/$playerId/'),
      // Uri.parse('http://192.168.4.245/players/delete/$playerId/'),
    );

    if (response.statusCode == 200) {
      controllers[index].clear();
      playerIds[index] = null;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player deleted')),
      );

      // Also update local storage
      final prefs = await SharedPreferences.getInstance();
      List<String>? names = prefs.getStringList('player_names');
      if (names != null && index < names.length) {
        names[index] = '';
        await prefs.setStringList('player_names', names);
      }
    } else {
      debugPrint('Delete failed: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        title: const Text("Enter Player Names"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.playerCount,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controllers[index],
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Player ${index + 1}',
                              labelStyle: const TextStyle(color: Colors.pink),
                              filled: true,
                              fillColor: Colors.pink[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.pink),
                          onPressed: () => _deletePlayer(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _savePlayers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'SAVE PLAYERS',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
