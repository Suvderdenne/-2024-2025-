import 'dart:async';
import 'dart:convert';
import 'package:e_learn/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestScreen extends StatefulWidget {
  final String token;

  const TestScreen({super.key, required this.token});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<dynamic> questions = [];
  Map<int, int> answers = {};
  Timer? timer;
  int remainingSeconds = 18 * 60;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds <= 0) {
        timer?.cancel();
        submitTest();
      } else if (mounted) {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  Future<void> fetchQuestions() async {
    final res = await http.get(
      Uri.parse('http://localhost:8000/test-questions/'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (res.statusCode == 200 && mounted) {
      setState(() {
        questions = json.decode(utf8.decode(res.bodyBytes));
      });
    }
  }

  Future<void> submitTest() async {
    timer?.cancel();
    final serializableAnswers =
        answers.map((key, value) => MapEntry(key.toString(), value));

    final response = await http.post(
      Uri.parse('http://localhost:8000/submit/'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({'answers': serializableAnswers}),
    );

    if (response.statusCode == 200) {
      final result = json.decode(utf8.decode(response.bodyBytes));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(result: result),
          ),
        );
      }
    }
  }

  void _answerQuestion(int questionId, int selectedOption) {
    if (mounted) {
      setState(() {
        answers[questionId] = selectedOption;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF8BC34A); // Green
    const Color selectedColor = Color(0xFFDFF0D8); // Light green highlight

    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'Test (${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: submitTest,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: questions.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemBuilder: (context, index) {
          final q = questions[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${index + 1}. ${q['question']}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 1; i <= 4; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: answers[q['id']] == i ? selectedColor : Colors.transparent,
                        border: Border.all(
                          color: answers[q['id']] == i ? primaryColor : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: RadioListTile<int>(
                        value: i,
                        groupValue: answers[q['id']],
                        activeColor: primaryColor,
                        onChanged: (val) => _answerQuestion(q['id'], val!),
                        title: Text(
                          q['choice$i'],
                          style: const TextStyle(fontSize: 15),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
