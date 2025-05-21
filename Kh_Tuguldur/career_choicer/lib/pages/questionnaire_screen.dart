import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'result_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

const royalBlue = Color(0xFF4169E1);

class _QuestionnaireScreenState extends State<QuestionnaireScreen> with TickerProviderStateMixin {
  List<dynamic> questions = [];
  Map<int, int> selectedAnswers = {};
  int currentPage = 0;
  final int itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  int get totalPages => (questions.length / itemsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(_animationController);
  }

  void updateProgressBar() {
    double progress = (currentPage + 1) / totalPages;
    _progressAnimation = Tween<double>(begin: _progressAnimation.value, end: progress)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward(from: 0);
  }

  Future<void> fetchQuestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/questions/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      var decodedJson = utf8.decode(response.bodyBytes);
      setState(() {
        questions = jsonDecode(decodedJson);
        updateProgressBar();
      });
    } else {
      print("Error fetching questions: ${response.statusCode}");
    }
  }

  Future<void> submitResponses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("Error: Token is null");
      return;
    }

    List<Map<String, int>> responses = selectedAnswers.entries
        .map((entry) => {"question_id": entry.key, "option_id": entry.value})
        .toList();

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/submit/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"responses": responses}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(data: data)),
      );
    } else {
      print("Error submitting responses: ${response.body}");
    }
  }

  void goToNextPage() {
    if (currentPage < totalPages - 1) {
      setState(() {
        currentPage++;
        updateProgressBar();
      });
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      submitResponses();
    }
  }

  void goToPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        updateProgressBar();
      });
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int start = currentPage * itemsPerPage;
    int end = (currentPage + 1) * itemsPerPage;
    end = end > questions.length ? questions.length : end;
    List<dynamic> displayedQuestions = questions.sublist(start, end);

    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text("Асуултууд", style: TextStyle(color: Colors.white)),
        backgroundColor: royalBlue,
        elevation: 4,
      ),
      body: questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress bar with animation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor: Colors.grey[300],
                            color: royalBlue,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(12),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Page ${currentPage + 1} of $totalPages",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: displayedQuestions.length,
                    itemBuilder: (context, index) {
                      var question = displayedQuestions[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Color(0xFFF0F4FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Асуулт ${start + index + 1}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: royalBlue,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                question["text"],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 12),
                              if (question["options"] != null && question["options"].isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: question["options"].map<Widget>((option) {
                                    int optionIndex = question["options"].indexOf(option);
                                    bool isSelected = selectedAnswers[question["id"]] == option["id"];
                                    Color optionColor;

                                    switch (optionIndex) {
                                      case 0: optionColor = Color(0xFFE57373); break;
                                      case 1: optionColor = Color(0xFFFFB74D); break;
                                      case 2: optionColor = Color(0xFFB0BEC5); break;
                                      case 3: optionColor = Color(0xFFA5D6A7); break;
                                      case 4: optionColor = Color(0xFF81C784); break;
                                      default: optionColor = Colors.grey;
                                    }

                                    return AnimatedScale(
                                      scale: isSelected ? 1.1 : 1.0,
                                      duration: Duration(milliseconds: 200),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedAnswers[question["id"]] = option["id"];
                                          });

                                          Future.delayed(Duration(milliseconds: 300), () {
                                            int absoluteIndex = start + index;
                                            if (absoluteIndex + 1 < questions.length) {
                                              if ((index + 1) < displayedQuestions.length) {
                                                _scrollController.animateTo(
                                                  _scrollController.position.pixels + 250,
                                                  duration: Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              } else {
                                                goToNextPage();
                                              }
                                            } else {
                                              submitResponses();
                                            }
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? optionColor.withOpacity(0.9)
                                                    : optionColor.withOpacity(0.2),
                                                border: Border.all(
                                                  color: isSelected ? optionColor : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: isSelected
                                                    ? Icon(Icons.check, color: Colors.white, size: 20)
                                                    : null,
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            SizedBox(
                                              width: 60,
                                              child: Text(
                                                option["text"],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: currentPage > 0 ? goToPreviousPage : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: royalBlue,
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Previous", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: goToNextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: royalBlue,
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(currentPage < totalPages - 1 ? "Next" : "Submit", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
