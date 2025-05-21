// screens/test_result_screen.dart

import 'package:flutter/material.dart';

class TestResultScreen extends StatelessWidget {
  final Map<String, dynamic> response;

  const TestResultScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final score = response['score'];
    final totalQuestions = response['total_questions'];
    final correctAnswers = response['correct_answers'];
    final incorrectQuestions = response['incorrect_questions'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Test Result")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Make scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Test Complete!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text("Score: $score%", style: const TextStyle(fontSize: 20)),
              Text("Correct Answers: $correctAnswers / $totalQuestions", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              const SizedBox(height: 30),
              if (incorrectQuestions.isNotEmpty) ...[
                const Text(
                  "Incorrect Questions:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 10),
                ...incorrectQuestions.map<Widget>((q) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Q: ${q['question']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Your Answer: ${q['your_answer']}", style: const TextStyle(color: Colors.red)),
                            Text("Correct Answer: ${q['correct_answer']}", style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                    ))
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
