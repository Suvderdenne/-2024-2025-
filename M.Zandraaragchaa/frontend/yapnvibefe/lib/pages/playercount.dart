import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:yapnvibefe/pages/playernames.dart';

class PlayerCountScreen extends StatefulWidget {
  final int? initialPlayers;
  final int spyId;

  const PlayerCountScreen({
    Key? key,
    required this.spyId,
    this.initialPlayers,
  }) : super(key: key);

  @override
  State<PlayerCountScreen> createState() => _PlayerCountScreenState();
}

class _PlayerCountScreenState extends State<PlayerCountScreen> {
  int? selectedPlayers;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    selectedPlayers = widget.initialPlayers ?? 3;
  }

  Future<void> _submitPlayerCount() async {
    setState(() => isSubmitting = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID not found. Please log in again.')),
      );
      setState(() => isSubmitting = false);
      return;
    }

    try {
      final body = jsonEncode({
        "user_id": userId,
        "players": selectedPlayers,
      });

      final response = await http.post(
        Uri.parse("http://localhost:8000/spy/edit/${widget.spyId}/"),
        // Uri.parse("http://192.168.4.245/spy/edit/${widget.spyId}/"),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Playernames(playerCount: selectedPlayers!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: ${response.body}")),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.pink),
        title: const Text(
          "Players",
          style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 10),
          Expanded(child: _buildPlayerCountPicker()),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCountPicker() {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(
        initialItem: (selectedPlayers ?? 3) - 3,
      ),
      itemExtent: 50,
      onSelectedItemChanged: (int index) {
        setState(() {
          selectedPlayers = index + 3;
        });
      },
      backgroundColor: Colors.white,
      children: List<Widget>.generate(48, (index) {
        final value = index + 3;
        final isSelected = value == selectedPlayers;
        return Center(
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              color: isSelected ? Colors.pink : Colors.grey[500],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: isSubmitting ? null : _submitPlayerCount,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isSubmitting
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text(
                  "PLAYERS' NAMES",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }
}
