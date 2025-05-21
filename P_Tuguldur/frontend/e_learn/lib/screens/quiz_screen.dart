import 'package:e_learn/api_service.dart';
import 'package:e_learn/screens/test_result_screen.dart';
import 'package:e_learn/tools/quiz_question.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String token;
  final String category;
  final String level;

  const QuizScreen({required this.token, required this.category, required this.level});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<QuizQuestion>> futureQuestions;
  Map<int, int> userAnswers = {}; // questionId -> choiceId

  @override
  void initState() {
    super.initState();
    futureQuestions = ApiService().fetchQuiz(widget.token, widget.category, widget.level);
  }

  void submitAnswers(List<QuizQuestion> questions) async {
    List<Map<String, dynamic>> answers = questions.map((q) {
      return {
        "question_id": q.id,
        "selected_choice_id": userAnswers[q.id] ?? 0,
      };
    }).toList();

    try {
      var response = await ApiService().submitTest(
        widget.token,
        answers,
        widget.category,
        widget.level,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Submitted')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestResultScreen(response: response),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF8BC34A);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Quiz", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<QuizQuestion>>(
        future: futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final questions = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  ...questions.map((q) {
                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              q.text,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...q.choices.map((c) {
                              return RadioListTile<int>(
                                title: Text(c.text),
                                activeColor: primaryColor,
                                value: c.id,
                                groupValue: userAnswers[q.id],
                                onChanged: (val) {
                                  setState(() {
                                    userAnswers[q.id] = val!;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => submitAnswers(questions),
                      child: const Text("Submit", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Failed to load questions"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
