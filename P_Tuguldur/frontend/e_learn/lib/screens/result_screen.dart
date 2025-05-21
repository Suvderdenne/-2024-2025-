import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final incorrect = List.from(result['incorrect_questions']);
    const primaryColor = Color(0xFF8BC34A);
    const lightBgColor = Color(0xFFEFFAF1);

    return Scaffold(
      backgroundColor: lightBgColor,
      appBar: AppBar(
        title: const Text('Test Results'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Score",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${result['score']} / ${result['total']}",
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const Divider(height: 24),
                    Text("Level: ${result['level']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Text(
                      result['level_description'],
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (incorrect.isNotEmpty) ...[
              const Text("Incorrect Answers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              for (var item in incorrect)
                Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['question'],
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Your Answer: ${item['your_answer_text']}",
                          style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Correct Answer: ${item['correct_answer_text']}",
                          style: const TextStyle(color: primaryColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else
              const Center(
                child: Text(
                  "Great job! All answers were correct 🎉",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: primaryColor),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
