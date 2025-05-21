import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yapnvibefe/pages/playercount.dart';
import 'package:yapnvibefe/pages/spiescount.dart';
import 'package:yapnvibefe/pages/timer.dart';
import 'package:yapnvibefe/pages/pack.dart';
import 'package:yapnvibefe/pages/mainspy.dart';

class Spy extends StatefulWidget {
  @override
  _SpyState createState() => _SpyState();
}

class _SpyState extends State<Spy> {
  String players = "";
  String spies = "";
  String timer = "";
  String pack = "";
  String sid = "";
  String? userId;

  bool isLoading = true;

  int? selectedTimer;
  int? selectedSpies;
  int? selectedPlayer;
  int? spyId;

  List<String> playerNames = [];

  @override
  void initState() {
    super.initState();
    _initializeUserAndData();
  }

  Future<void> _initializeUserAndData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id'); // ✅ Fixed: assign to class field
    playerNames = prefs.getStringList('player_names') ?? [];
    await _loadSpyData(userId);
  }

  Future<void> _loadSpyData(String? userId) async {
    if (userId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      // Fetch Pack Data
      final packResponse = await http.get(
        Uri.parse('http://localhost:8000/spypack/$userId/'),
        // Uri.parse('http://192.168.4.245/spypack/$userId/'),
      );

      if (packResponse.statusCode == 200) {
        final data = jsonDecode(packResponse.body);
        final spyPacks = data['spypack'];
        if (spyPacks != null && spyPacks.isNotEmpty) {
          final spyPack = spyPacks[0];
          pack = spyPack['pack_name']?.toString() ?? "Not set";
        } else {
          pack = "Not set";
        }
      }
    } catch (e) {
      debugPrint('Error loading spy pack: $e');
    }

    try {
      // Fetch Game Settings
      final settingsResponse = await http.get(
        Uri.parse('http://localhost:8000/spies/$userId/'),
        // Uri.parse('http://192.168.4.245/spies/$userId/'),
      );

      if (settingsResponse.statusCode == 200) {
        final data = jsonDecode(settingsResponse.body);
        if (data['spy_data'] != null && data['spy_data'].isNotEmpty) {
          final spyData = data['spy_data'][0];

          spyId = spyData['id'];
          selectedTimer = spyData['timer'];
          selectedSpies = spyData['spies'];
          selectedPlayer = spyData['players'];

          players = selectedPlayer.toString();
          spies = selectedSpies.toString();
          timer = selectedTimer.toString();
          sid = spyId.toString();
        }
      }
    } catch (e) {
      debugPrint('Error loading spy settings: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _savePlayerRoles(List<String> playerRoles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('player_roles', playerRoles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _gameSettingItem(
                    Icons.group,
                    "Players",
                    players,
                    onTap: () async {
                      final shouldRefresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerCountScreen(
                            initialPlayers: selectedPlayer,
                            spyId: spyId!,
                          ),
                        ),
                      );
                      if (shouldRefresh == true) {
                        _initializeUserAndData();
                      }
                    },
                  ),
                  _gameSettingItem(
                    Icons.person_off,
                    "Spies",
                    spies,
                    onTap: () async {
                      final shouldRefresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Spiescount(
                            initialSpies: selectedSpies,
                            initialPlayers: selectedPlayer,
                            spyId: spyId!,
                          ),
                        ),
                      );
                      if (shouldRefresh == true) {
                        _initializeUserAndData();
                      }
                    },
                  ),
                  _gameSettingItem(
                    Icons.timer,
                    "Timer",
                    timer.isNotEmpty ? "$timer min" : "Not set",
                    onTap: () async {
                      final shouldRefresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Timer(
                            initialTimer: selectedTimer,
                            spyId: spyId!,
                          ),
                        ),
                      );
                      if (shouldRefresh == true) {
                        _initializeUserAndData();
                      }
                    },
                  ),
                  _gameSettingItem(
                    Icons.style,
                    "Pack",
                    pack,
                    onTap: () async {
                      final shouldRefresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PacksScreen(),
                        ),
                      );
                      if (shouldRefresh == true) {
                        _initializeUserAndData();
                      }
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFe0166d),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (userId == null ||
                            selectedPlayer == null ||
                            selectedSpies == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please complete all settings")),
                          );
                          return;
                        }

                        List<String> playerRoles = List.generate(
                          selectedPlayer!,
                          (index) =>
                              "${playerNames[index]} - ${index < selectedSpies! ? 'Spy' : 'Item'}",
                        );

                        await _savePlayerRoles(playerRoles);

                        debugPrint("Game started with:");
                        debugPrint("Players: $players");
                        debugPrint("Spies: $spies");
                        debugPrint("Timer: $timer");
                        debugPrint("Pack: $pack");

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainSpy(
                              players: selectedPlayer!,
                              spies: selectedSpies!,
                              timer: selectedTimer!,
                              userId: userId!,
                              playerNames: playerNames,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Start Game",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }

  Widget _gameSettingItem(IconData icon, String title, String value,
      {VoidCallback? onTap}) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFFe0166d)),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFe0166d),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: Text(
          value.isNotEmpty ? value : "Not set",
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
