import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Spiescount extends StatefulWidget {
  final int? initialSpies;
  final int? initialPlayers;
  final int spyId;

  const Spiescount({
    Key? key,
    required this.spyId,
    this.initialSpies,
    this.initialPlayers,
  }) : super(key: key);

  @override
  State<Spiescount> createState() => _SpiescountState();
}

class _SpiescountState extends State<Spiescount> {
  int? selectedSpies;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final maxSpies = _getMaxSpies();
    selectedSpies =
        (widget.initialSpies != null && widget.initialSpies! <= maxSpies)
            ? widget.initialSpies
            : 1;
  }

  int _getMaxSpies() {
    if (widget.initialPlayers != null && widget.initialPlayers! >= 3) {
      return (widget.initialPlayers! / 3)
          .floor()
          .clamp(1, widget.initialPlayers!);
    }
    return 1;
  }

  Future<void> _submitSpiesCount() async {
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
        "spies": selectedSpies,
      });

      final response = await http.post(
        Uri.parse("http://localhost:8000/spy/edit/${widget.spyId}/"),
        // Uri.parse("http://192.168.4.245/spy/edit/${widget.spyId}/"),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
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
    final maxSpies = _getMaxSpies();
    if ((selectedSpies ?? 1) > maxSpies) {
      selectedSpies = maxSpies;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.pink),
        title: const Text(
          "Spies",
          style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 10),
          Expanded(child: _buildSpiesPicker(maxSpies)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpiesPicker(int maxSpies) {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(
        initialItem: (selectedSpies ?? 1) - 1,
      ),
      itemExtent: 50,
      onSelectedItemChanged: (int index) {
        setState(() {
          selectedSpies = index + 1;
        });
      },
      backgroundColor: Colors.white,
      children: List<Widget>.generate(maxSpies, (index) {
        final value = index + 1;
        final isSelected = value == selectedSpies;
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
      onTap: isSubmitting ? null : _submitSpiesCount,
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
                  "SAVE",
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
