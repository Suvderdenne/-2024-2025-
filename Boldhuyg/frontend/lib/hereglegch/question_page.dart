import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

// ------------------ Загвар ------------------
class Question {
  final int id;
  final String questionText;
  final String type;
  final String? imageBase64;
  final String? audioBase64;
  final List<MatchingItem>? matchingItems;

  Question({
    required this.id,
    required this.questionText,
    required this.type,
    this.imageBase64,
    this.audioBase64,
    this.matchingItems,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      questionText: json['question_text'] ?? 'Асуултын текст байхгүй',
      type: json['type'] ?? 'Төрөл байхгүй',
      imageBase64: json['image_base64'],
      audioBase64: json['audio_base64'],
      matchingItems: json['matching_items'] != null
          ? (json['matching_items'] as List)
              .map((item) => MatchingItem.fromJson(item))
              .toList()
          : null,
    );
  }
}

class MatchingItem {
  final int id;
  final String leftText;
  final String rightText;
  final String? leftImageBase64;
  final String? rightImageBase64;

  MatchingItem({
    required this.id,
    required this.leftText,
    required this.rightText,
    this.leftImageBase64,
    this.rightImageBase64,
  });

  factory MatchingItem.fromJson(Map<String, dynamic> json) {
    return MatchingItem(
      id: json['id'] ?? 0,
      leftText: json['left_text'] ?? '',
      rightText: json['right_text'] ?? '',
      leftImageBase64: json['left_image_base64'],
      rightImageBase64: json['right_image_base64'],
    );
  }
}

// ------------------ Үйлчилгээ ------------------
class QuestionService {
  static const String apiUrl = 'http://127.0.0.1:8000/questions/';

  static Future<List<Question>> fetchQuestions(
      String type, int activityId) async {
    print('Activity ID: $activityId');
    try {
      // Map the display type to the API expected type
      final typeMap = {
        'асуулт': 'question',
        'холбох': 'connect',
        'сонгох': 'choice',
      };

      // Get the API type or use the original if not found in map
      final apiType = typeMap[type.toLowerCase().trim()] ?? type;
      final encodedType = Uri.encodeComponent(apiType);
      final uri = Uri.parse('$apiUrl$activityId/?type=$encodedType');
      debugPrint('Fetching questions from: $uri');

      final response = await http.get(uri);
      debugPrint('Question API Response Status: ${response.statusCode}');
      debugPrint('Question API Response Body: ${response.body}');
      debugPrint('Question Type: $type (API Type: $apiType)');
      debugPrint('Activity ID: $activityId');
      print('Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(utf8.decode(response.bodyBytes));
        List<Question> questions = [];

        if (jsonData is List) {
          questions = jsonData
              .map((data) => Question.fromJson(data as Map<String, dynamic>))
              .toList();
        } else if (jsonData is Map) {
          questions = [Question.fromJson(jsonData as Map<String, dynamic>)];
        }

        if (questions.isEmpty) {
          throw Exception('NO_QUESTIONS_FOUND');
        }
        return questions;
      } else {
        throw Exception('API_ERROR: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching questions: $e');
      throw Exception(e.toString());
    }
  }
}

// ------------------ Хуудас ------------------
class QuestionListPage extends StatefulWidget {
  final String questionType;
  final int activityId;

  const QuestionListPage({
    super.key,
    required this.questionType,
    required this.activityId,
  });

  @override
  State<QuestionListPage> createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage>
    with TickerProviderStateMixin {
  late Future<List<Question>> futureQuestions;
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  late AnimationController _refreshController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<int, int?> selectedAnswers = {}; // questionId -> selectedAnswerId
  Map<int, List<Answer>> questionAnswers = {}; // questionId -> list of answers
  Map<int, bool?> answerResults =
      {}; // questionId -> isCorrect (null if not checked)
  Map<int, bool> questionsChecked = {}; // questionId -> isChecked
  Map<int, int?> matchingPairs = {}; // leftItemId -> rightItemId
  Map<int, bool> matchingResults = {}; // leftItemId -> isCorrect
  int currentQuestionIndex = 0; // Track current question index
  int totalScore = 0; // Track total score
  Map<int, bool> isRefreshing = {}; // Track refresh state for each answer

  @override
  void initState() {
    super.initState();
    futureQuestions = QuestionService.fetchQuestions(
      widget.questionType.trim().toLowerCase(),
      widget.activityId,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _handleAnswerSelection(int questionId, int answerId) {
    setState(() {
      selectedAnswers[questionId] = answerId;
      questionsChecked[questionId] = true;
      final answers = questionAnswers[questionId];
      if (answers != null && answers.isNotEmpty) {
        final selectedAnswer = answers.firstWhere((a) => a.id == answerId);
        final isCorrect = answerId == answers.first.id;
        answerResults[questionId] = isCorrect;
        if (isCorrect) {
          totalScore++;
        }
        // Play the answer's audio if it exists
        if (selectedAnswer.audioBase64 != null &&
            selectedAnswer.audioBase64!.isNotEmpty) {
          _playAudio(selectedAnswer.audioBase64!);
        }
      } else {
        answerResults[questionId] = false;
      }

      // Move to next question after a short delay
      Future.delayed(const Duration(milliseconds: 1000), () async {
        if (mounted) {
          final questions = await futureQuestions;
          setState(() {
            if (currentQuestionIndex < questions.length - 1) {
              currentQuestionIndex++;
            }
          });
        }
      });
    });
  }

  void _refreshAnswer(int questionId, int answerId) {
    final answers = questionAnswers[questionId];
    if (answers != null) {
      final selectedAnswer = answers.firstWhere((a) => a.id == answerId);
      if (selectedAnswer.audioBase64 != null &&
          selectedAnswer.audioBase64!.isNotEmpty) {
        _playAudio(selectedAnswer.audioBase64!);
      }
    }
  }

  void _checkAnswers() {
    setState(() {
      for (var questionId in selectedAnswers.keys) {
        final selectedAnswerId = selectedAnswers[questionId];
        if (selectedAnswerId != null) {
          // TODO: Replace with actual validation logic from backend
          // For now, we'll just mark the first answer as correct
          answerResults[questionId] =
              selectedAnswerId == questionAnswers[questionId]?.first.id;
          questionsChecked[questionId] = true;
        }
      }
    });
  }

  void _resetQuestion(int questionId) {
    setState(() {
      selectedAnswers.remove(questionId);
      answerResults.remove(questionId);
      questionsChecked[questionId] = false;
    });
  }

  Color _getAnswerColor(int questionId, int answerId) {
    final isChecked = questionsChecked[questionId] ?? false;
    if (!isChecked) {
      return selectedAnswers[questionId] == answerId
          ? const Color(0xFF2196F3) // Blue when selected but not checked
          : Colors.white.withValues(alpha: 179);
    }

    final isCorrect = answerResults[questionId] ?? false;
    if (selectedAnswers[questionId] == answerId) {
      return isCorrect
          ? const Color(0xFF4CAF50) // Green for correct answer
          : const Color(0xFFF44336); // Red for incorrect answer
    }
    return Colors.white.withValues(alpha: 179);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scaleController.dispose();
    _refreshController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<List<Answer>> fetchAnswers(int questionId) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/questions/$questionId/answers/'),
      );

      debugPrint('Answer API Response Status: ${response.statusCode}');
      debugPrint('Answer API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData =
            json.decode(utf8.decode(response.bodyBytes));
        if (jsonData.isEmpty) {
          throw Exception('Энэ асуултын хариулт олдсонгүй');
        }

        return jsonData.map((data) => Answer.fromJson(data)).toList();
      } else {
        throw Exception(
            'Хариултуудыг ачаалах үед алдаа гарлаа: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching answers: $e');
      throw Exception('Алдаа: $e');
    }
  }

  void _retry() {
    setState(() {
      futureQuestions = QuestionService.fetchQuestions(
        widget.questionType.trim().toLowerCase(),
        widget.activityId,
      );
    });
  }

  Future<void> _playAudio(String base64Audio) async {
    try {
      Uint8List audioBytes = base64Decode(base64Audio);
      await _audioPlayer.play(BytesSource(audioBytes));
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFD54F).withOpacity(0.8), // Bright yellow
              const Color(0xFFFFB74D).withOpacity(0.9), // Orange
              const Color(0xFFFF8A65).withOpacity(1.0), // Coral
              const Color(0xFFE57373).withOpacity(1.0), // Pink
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, size),
              Expanded(
                child: FutureBuilder<List<Question>>(
                  future: futureQuestions,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoading(size);
                    } else if (snapshot.hasError) {
                      return _buildError(snapshot.error.toString(), size);
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildNoData(size);
                    } else {
                      return _buildQuestionList(snapshot.data!, size);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9800).withOpacity(0.95), // Orange
            const Color(0xFFFF5722).withOpacity(0.95), // Deep Orange
            const Color(0xFFE64A19).withOpacity(0.95), // Dark Orange
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child:
                        Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Асуултууд',
                  style: TextStyle(
                    fontSize: size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(width: size.width * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(Size size) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.9),
              const Color(0xFFFFD54F).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF9800),
                      const Color(0xFFFF5722),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Асуултуудыг ачаалж байна...',
              style: TextStyle(
                fontSize: 20,
                color: const Color(0xFFFF9800),
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error, Size size) {
    final isNoQuestions =
        error.contains('NO_QUESTIONS_FOUND') || error.contains('API_ERROR');

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.95),
              const Color(0xFFFFD54F).withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF9800).withOpacity(0.2),
                    const Color(0xFFFF9800).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.sentiment_dissatisfied,
                size: 80,
                color: const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Асуулт олдсонгүй',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF9800),
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Өөр төрлийн асуулт сонгоно уу',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF9800),
                    const Color(0xFFFF5722),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Буцах',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoData(Size size) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.95),
              const Color(0xFFFFD54F).withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF9800).withOpacity(0.2),
                    const Color(0xFFFF9800).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.help_outline,
                size: 80,
                color: Color(0xFFFF9800),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Асуулт олдсонгүй',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF9800),
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Өөр төрлийн асуулт сонгоно уу',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF9800),
                    const Color(0xFFFF5722),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Буцах',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList(List<Question> questions, Size size) {
    if (currentQuestionIndex >= questions.length) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.95),
                const Color(0xFFFFD54F).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF9800).withOpacity(0.2),
                      const Color(0xFFFF9800).withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 80,
                  color: Color(0xFFFF9800),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Баяр хүргэе!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF9800),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Та бүх асуултуудад хариуллаа',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF9800).withOpacity(0.1),
                      const Color(0xFFFF9800).withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Таны нийт оноо',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalScore',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF9800),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF9800),
                      const Color(0xFFFF5722),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Буцах',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Card(
        key: ValueKey<int>(currentQuestion.id),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.95),
                const Color(0xFFFFD54F).withOpacity(0.95),
                const Color(0xFFFFB74D).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF9800),
                      const Color(0xFFFF5722),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${currentQuestionIndex + 1}',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        currentQuestion.questionText,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (currentQuestion.imageBase64 != null &&
                  currentQuestion.imageBase64!.isNotEmpty)
                Container(
                  height: 200,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF9800).withOpacity(0.1),
                        const Color(0xFFFF9800).withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF9800),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      base64Decode(currentQuestion.imageBase64!),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading question image: $error');
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sentiment_dissatisfied,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Зураг ачаалахад алдаа гарлаа',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              if (currentQuestion.audioBase64 != null &&
                  currentQuestion.audioBase64!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          const Color(0xFFFFD54F),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _playAudio(currentQuestion.audioBase64!);
                      },
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text('Аудио сонсох'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: const Color(0xFFFF9800),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        minimumSize: const Size(0, 48),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              if (currentQuestion.type == 'холбох' &&
                  currentQuestion.matchingItems != null)
                Expanded(
                  flex: 2,
                  child: _buildMatchingExercise(
                      currentQuestion.matchingItems!, size),
                )
              else
                Expanded(
                  flex: 2,
                  child: FutureBuilder<List<Answer>>(
                    future: fetchAnswers(currentQuestion.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  const Color(0xFFFFD54F).withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFF9800)),
                                  strokeWidth: 4,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Хариултуудыг ачаалж байна...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: const Color(0xFFFF9800),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  const Color(0xFFFFD54F).withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sentiment_dissatisfied,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Хариулт ачаалахад алдаа гарлаа',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  const Color(0xFFFFD54F).withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sentiment_neutral,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Хариулт олдсонгүй',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        questionAnswers[currentQuestion.id] = snapshot.data!;
                        return _buildAnswerList(
                            snapshot.data!, size, currentQuestion.id);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchingExercise(List<MatchingItem> items, Size size) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  const Color(0xFFFFD54F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Зүүн ба баруун талын зүйлсийг холбоно уу',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF9800),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: items.map((item) {
                      final isMatched = matchingPairs[item.id] != null;
                      final isCorrect = matchingResults[item.id] ?? false;

                      return Draggable<int>(
                        data: item.id,
                        feedback: Material(
                          elevation: 4,
                          child: Container(
                            width: size.width * 0.4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF9800),
                                  const Color(0xFFFF5722),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _buildMatchingItem(item, true, size),
                          ),
                        ),
                        childWhenDragging: Container(
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isMatched
                                  ? (isCorrect
                                      ? [
                                          const Color(0xFFFF9800),
                                          const Color(0xFFFF5722)
                                        ]
                                      : [
                                          const Color(0xFFF44336),
                                          const Color(0xFFD32F2F)
                                        ])
                                  : [Colors.white, const Color(0xFFFFD54F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _buildMatchingItem(item, true, size),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: items.map((item) {
                      final matchedLeftId = matchingPairs.entries
                          .firstWhere((e) => e.value == item.id,
                              orElse: () => MapEntry(-1, -1))
                          .key;
                      final isMatched = matchedLeftId != -1;
                      final isCorrect = matchingResults[matchedLeftId] ?? false;

                      return DragTarget<int>(
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            width: double.infinity,
                            height: 100,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isMatched
                                    ? (isCorrect
                                        ? [
                                            const Color(0xFFFF9800),
                                            const Color(0xFFFF5722)
                                          ]
                                        : [
                                            const Color(0xFFF44336),
                                            const Color(0xFFD32F2F)
                                          ])
                                    : [Colors.white, const Color(0xFFFFD54F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _buildMatchingItem(item, false, size),
                          );
                        },
                        onWillAccept: (int? data) => true,
                        onAccept: (int data) {
                          setState(() {
                            matchingPairs[data] = item.id;
                            // TODO: Replace with actual validation logic
                            matchingResults[data] = data == item.id;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF9800),
                  const Color(0xFFFF5722),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement matching validation
                debugPrint('Check matching answers');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                'Шалгах',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingItem(MatchingItem item, bool isLeft, Size size) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if ((isLeft ? item.leftImageBase64 : item.rightImageBase64) != null &&
              (isLeft ? item.leftImageBase64 : item.rightImageBase64)!
                  .isNotEmpty)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF9800),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    base64Decode(isLeft
                        ? item.leftImageBase64!
                        : item.rightImageBase64!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isLeft ? item.leftText : item.rightText,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFFFF9800),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerList(List<Answer> answers, Size size, int questionId) {
    final isChecked = questionsChecked[questionId] ?? false;
    final isCorrect = answerResults[questionId] ?? false;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: answers.length,
      itemBuilder: (context, index) {
        final answer = answers[index];
        final isSelected = selectedAnswers[questionId] == answer.id;
        final answerColor = _getAnswerColor(questionId, answer.id);
        final isRefreshingAnswer = isRefreshing[answer.id] ?? false;
        final hasAudio =
            answer.audioBase64 != null && answer.audioBase64!.isNotEmpty;

        return GestureDetector(
          onTap: () {
            if (hasAudio) {
              _playAudio(answer.audioBase64!);
            }
            if (isSelected) {
              _refreshAnswer(questionId, answer.id);
            } else {
              _handleAnswerSelection(questionId, answer.id);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  answerColor,
                  Color.lerp(answerColor, Colors.black, 0.1) ?? answerColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (answer.imageBase64 != null &&
                        answer.imageBase64!.isNotEmpty)
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.9),
                                  const Color(0xFFFFD54F).withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFFFF9800),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.memory(
                                base64Decode(answer.imageBase64!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('Error loading image: $error');
                                  return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.grey[200]!,
                                          Colors.grey[300]!,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Зураг ачаалахад алдаа гарлаа',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  const Color(0xFFFFD54F),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFFFF9800),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? Icon(
                                    isChecked
                                        ? (isCorrect
                                            ? Icons.check
                                            : Icons.close)
                                        : Icons.check,
                                    size: 16,
                                    color: isChecked
                                        ? (isCorrect
                                            ? const Color(0xFFFF9800)
                                            : const Color(0xFFF44336))
                                        : const Color(0xFFFF9800),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              answer.answerText,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFFFF9800),
                                shadows: isSelected
                                    ? [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.2),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasAudio)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    const Color(0xFFFFD54F),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFFFF9800),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.volume_up,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFFFF9800),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isRefreshingAnswer)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: RotationTransition(
                          turns: _refreshController,
                          child: Icon(
                            Icons.refresh,
                            color: const Color(0xFFFF9800),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerCard(Answer answer) {
    return Draggable<Answer>(
      data: Answer(
        id: answer.id,
        answerText: answer.answerText,
        imageBase64: answer.imageBase64,
        audioBase64: answer.audioBase64,
        isCorrect: answer.isCorrect,
      ),
      feedback: Material(
        elevation: 8,
        color: Colors.transparent,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: answer.imageBase64 != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(answer.imageBase64!),
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      answer.answerText,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildAnswerCard(answer),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: answer.imageBase64 != null
              ? Image.memory(
                  base64Decode(answer.imageBase64!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.error_outline, color: Colors.red),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.yellow[100],
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        answer.answerText,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// ------------------ Хариултуудын Хуудас ------------------

// ------------------ Хариултын Модел ------------------
class Answer {
  final int id;
  final String answerText;
  final String? imageBase64;
  final String? audioBase64;
  final bool isCorrect;

  Answer({
    required this.id,
    required this.answerText,
    this.imageBase64,
    this.audioBase64,
    required this.isCorrect,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] ?? 0,
      answerText: json['answer_text'] ?? 'Хариултын текст байхгүй',
      imageBase64: json['image_base64'],
      audioBase64: json['audio_base64'],
      isCorrect: json['is_correct'] ?? false,
    );
  }
}

class AnswerListPage extends StatefulWidget {
  final int questionId;
  final String questionImageBase64; // <-- add this

  const AnswerListPage({
    Key? key,
    required this.questionId,
    required this.questionImageBase64,
  }) : super(key: key);

  @override
  State<AnswerListPage> createState() => _AnswerListPageState();
}

class _AnswerListPageState extends State<AnswerListPage> {
  late Future<List<Answer>> answers;
  int? selectedAnswerId;
  bool? selectedIsCorrect;
  int totalScore = 0;
  bool isDragging = false;
  bool isCorrectAnswer = false;
  double dragOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    answers = fetchAnswers(widget.questionId);
  }

  Future<List<Answer>> fetchAnswers(int questionId) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/questions/$questionId/answers/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData =
            json.decode(utf8.decode(response.bodyBytes));
        if (jsonData.isEmpty) {
          throw Exception('Энэ асуултын хариулт олдсонгүй');
        }

        return jsonData.map((data) => Answer.fromJson(data)).toList();
      } else {
        throw Exception('Хариултуудыг ачаалах үед алдаа гарлаа');
      }
    } catch (e) {
      throw Exception('Алдаа: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Хариултаа сонгоно уу', style: TextStyle(fontSize: 24)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Answer>>(
        future: answers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Алдаа: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Хариулт олдсонгүй'));
          }

          final answerList = snapshot.data!;

          return Column(
            children: [
              const SizedBox(height: 20),
              DragTarget<Answer>(
                onWillAccept: (Answer? answer) {
                  setState(() {
                    isDragging = true;
                    isCorrectAnswer = answer?.isCorrect ?? false;
                  });
                  return true;
                },
                onAccept: (Answer answer) {
                  setState(() {
                    selectedAnswerId = answer.id;
                    selectedIsCorrect = answer.isCorrect;
                    isDragging = false;
                    if (answer.isCorrect) totalScore++;
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  Color borderColor;
                  Color backgroundColor;

                  if (isDragging) {
                    borderColor = isCorrectAnswer ? Colors.green : Colors.red;
                    backgroundColor = isCorrectAnswer
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1);
                  } else if (selectedAnswerId != null) {
                    borderColor =
                        selectedIsCorrect! ? Colors.green : Colors.red;
                    backgroundColor = selectedIsCorrect!
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1);
                  } else {
                    borderColor = Colors.deepPurple;
                    backgroundColor = Colors.grey[100]!;
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 250,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(
                        color: borderColor,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          selectedAnswerId == null
                              ? 'Зураг руу чирж тавина уу'
                              : (selectedIsCorrect == true
                                  ? 'Зөв хариулт 🎉'
                                  : 'Буруу хариулт ❌'),
                          style: TextStyle(
                            fontSize: 18,
                            color: borderColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (widget.questionImageBase64 != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              base64Decode(widget.questionImageBase64!),
                              width: 200,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported);
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: answerList.length,
                  itemBuilder: (context, index) {
                    final answer = answerList[index];
                    return Draggable<Answer>(
                      data: answer,
                      feedback: Material(
                        elevation: 8,
                        color: Colors.transparent,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: answer.imageBase64 != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    base64Decode(answer.imageBase64!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      answer.answerText,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.deepPurple,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: _buildAnswerCard(answer),
                      ),
                      child: _buildAnswerCard(answer),
                    );
                  },
                ),
              ),
              if (selectedAnswerId != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Таны нийт оноо: $totalScore',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnswerCard(Answer answer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: answer.imageBase64 != null
            ? Image.memory(
                base64Decode(answer.imageBase64!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.red),
                    ),
                  );
                },
              )
            : Container(
                color: Colors.yellow[100],
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      answer.answerText,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
