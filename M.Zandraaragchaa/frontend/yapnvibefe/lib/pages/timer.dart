import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Timer extends StatefulWidget {
  final int? initialTimer;
  final int spyId;

  const Timer({
    Key? key,
    required this.spyId,
    this.initialTimer,
  }) : super(key: key);

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  int? selectedTimer;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    selectedTimer = (widget.initialTimer != null &&
            widget.initialTimer! >= 1 &&
            widget.initialTimer! <= 10)
        ? widget.initialTimer
        : 3;
  }

  Future<void> submitTimer() async {
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
        "timer": selectedTimer,
      });

      final response = await http.post(
        Uri.parse("http://localhost:8000/spy/edit/${widget.spyId}/"),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.pink),
        title: const Text(
          "Timer",
          style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 10),
          Expanded(child: _buildTimerPicker()),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerPicker() {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(
        initialItem: (selectedTimer ?? 3) - 1,
      ),
      itemExtent: 50,
      onSelectedItemChanged: (int index) {
        setState(() {
          selectedTimer = index + 1;
        });
      },
      backgroundColor: Colors.white,
      children: List<Widget>.generate(10, (index) {
        final value = index + 1;
        final isSelected = value == selectedTimer;
        return Center(
          child: Text(
            "$value min",
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
      onTap: isSubmitting ? null : submitTimer,
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
