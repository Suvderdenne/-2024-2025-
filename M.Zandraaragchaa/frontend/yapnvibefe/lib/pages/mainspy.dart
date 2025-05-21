import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yapnvibefe/pages/time.dart';

class MainSpy extends StatefulWidget {
  final int players;
  final int spies;
  final int timer;
  final String userId;
  final List<String> playerNames;

  const MainSpy({
    Key? key,
    required this.players,
    required this.spies,
    required this.timer,
    required this.userId,
    required this.playerNames,
  }) : super(key: key);

  @override
  State<MainSpy> createState() => _MainSpyState();
}

class _MainSpyState extends State<MainSpy> {
  List<Map<String, String>> playerRoles = [];
  String? location;
  bool isRevealed = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    await _fetchLocation();
    _assignRoles();
  }

  Future<void> _fetchLocation() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/spypackitem/${widget.userId}/'),
        // Uri.parse('http://192.168.4.245/spypackitem/${widget.userId}/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        location = data['spypackitem'][0]['pack_item_name'];
      } else {
        location = "Unknown Location";
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
      location = "Unknown Location";
    }
  }

  void _assignRoles() async {
    final indices = List.generate(widget.players, (i) => i)..shuffle();
    final roles = List.filled(widget.players, location ?? "Location Unknown");

    for (int i = 0; i < widget.spies; i++) {
      roles[indices[i]] = "spy";
    }

    final generatedRoles =
        List<Map<String, String>>.generate(widget.players, (i) {
      return {
        'name': widget.playerNames[i],
        'role': roles[i],
      };
    });

    setState(() {
      playerRoles = generatedRoles;
    });

    final prefs = await SharedPreferences.getInstance();
    final stored = playerRoles.map((p) => "${p['name']}-${p['role']}").toList();
    await prefs.setStringList('player_roles', stored);
  }

  void _nextPlayer() {
    setState(() {
      isRevealed = false;
      if (currentIndex < playerRoles.length - 1) {
        currentIndex++;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimerScreen(
              timer: widget.timer,
              playerRoles: playerRoles,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = playerRoles.isNotEmpty ? playerRoles[currentIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Role Reveal"),
        backgroundColor: Colors.pink,
      ),
      body: player == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: GestureDetector(
                onTap: () {
                  if (!isRevealed) {
                    setState(() {
                      isRevealed = true;
                    });
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pink layered cards (clean corners and spacing)
                        for (int i = 0; i < 4; i++)
                          Positioned(
                            bottom: i * 6,
                            child: Container(
                              width: 320,
                              height: 540,
                              decoration: BoxDecoration(
                                color: Colors.pink.shade100,
                                borderRadius: BorderRadius.circular(
                                    32), // match main card
                              ),
                            ),
                          ),

                        // Main white card
                        Container(
                          width: 340,
                          height: 580,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: isRevealed
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        player['role'] == 'spy'
                                            ? Icons.visibility
                                            : Icons.location_on,
                                        size: 80,
                                        color: Colors.pink,
                                      ),
                                      const SizedBox(height: 30),
                                      Text(
                                        player['role'] == 'spy'
                                            ? 'Spy'
                                            : player['role'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        player['role'] == 'spy'
                                            ? "You are the Spy. Guess the location!"
                                            : "You are a Local. Find the Spy!",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 40),
                                      ElevatedButton(
                                        onPressed: _nextPlayer,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.pink,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: const Text("Next Player"),
                                      )
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.lock,
                                          size: 80, color: Colors.pink),
                                      const SizedBox(height: 30),
                                      Text(
                                        player['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        "Tap to reveal role",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
