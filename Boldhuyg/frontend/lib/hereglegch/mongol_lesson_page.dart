import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'lesson.dart'; // 👈 LessonPage импортоор оруулна
import 'activity_list_page.dart';

class MongolianLanguagePage extends StatefulWidget {
  final String token;

  // Конструктор параметртэй
  const MongolianLanguagePage({super.key, required this.token});

  @override
  State<MongolianLanguagePage> createState() => _MongolianLanguagePageState();
}

class _MongolianLanguagePageState extends State<MongolianLanguagePage>
    with TickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> lessons;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  late AnimationController _colorController;

  @override
  void initState() {
    super.initState();
    lessons = fetchLessons();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _colorController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scaleController.dispose();
    _colorController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // New method to handle "Шалгах" (Check) button action
  void checkLesson(int lessonGroupId) {
    // Navigate to ActivityListPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityListPage(lessonGroupId: lessonGroupId),
      ),
    );
  }

  // Fetch lesson data from the API
  Future<List<Map<String, dynamic>>> fetchLessons() async {
    try {
      final response = await http
          .get(Uri.parse('http://127.0.0.1:8000/api/lesson-groups/subject/2/'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }

  void playBase64Audio(String base64String) async {
    try {
      Uint8List audioBytes = base64Decode(base64String);
      await _audioPlayer.play(BytesSource(audioBytes));
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: DotsPainter(
                color: Colors.orange[200]!,
                dotRadius: 3,
                spacing: 30,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange[300]!,
                      Colors.purple[300]!,
                      Colors.blue[300]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange[300]!.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: AppBar(
                  title: AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceController.value * 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Монгол хэл",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: lessons,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(seconds: 2),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: 1.0 + (value * 0.2),
                                  child: CircularProgressIndicator(
                                    color: Colors.orange[800],
                                    strokeWidth: 4,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Хичээлүүд ачаалж байна...",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sentiment_dissatisfied,
                              size: 80,
                              color: Colors.orange[800],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Алдаа гарлаа: ${snapshot.error}",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.orange[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  lessons = fetchLessons();
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(
                                "Дахин оролдох",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[300],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sentiment_neutral,
                              size: 80,
                              color: Colors.orange[800],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Хичээл олдсонгүй",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final lessonItems = snapshot.data!;

                    final desiredOrder = [
                      'Эгшиг долоо',
                      'Урт эгшиг долоо',
                      'Хос эгшиг',
                      'Нэг дүгээр шатны гийгүүлэгч',
                      'Хоёр дугаар шатны гийгүүлэгч',
                      'Минутын уншлага',
                      'Цээж бичиг',
                    ];

                    lessonItems.sort((a, b) {
                      int indexA = desiredOrder.indexOf(a['name']);
                      int indexB = desiredOrder.indexOf(b['name']);
                      if (indexA == -1) indexA = desiredOrder.length;
                      if (indexB == -1) indexB = desiredOrder.length;
                      return indexA.compareTo(indexB);
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: lessonItems.length,
                      itemBuilder: (context, index) {
                        final lesson = lessonItems[index];
                        final name = lesson['name'];
                        final imageBase64 = lesson['image_base64'];
                        final lessonGroupId = lesson['id'];
                        final audioBase64 = lesson['audio_base64'];

                        Uint8List imageBytes = base64Decode(imageBase64);

                        return GestureDetector(
                          onTap: () {
                            if (audioBase64 != null) {
                              playBase64Audio(audioBase64);
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LessonPage(lessonGroupId: lessonGroupId),
                              ),
                            );
                          },
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration:
                                Duration(milliseconds: 500 + (index * 100)),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange[100]!.withOpacity(0.9),
                                      Colors.purple[100]!.withOpacity(0.9),
                                      Colors.blue[100]!.withOpacity(0.9),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.orange[200]!.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Opacity(
                                        opacity: 0.1,
                                        child: CustomPaint(
                                          painter: DotsPainter(
                                            color: Colors.orange[900]!,
                                            dotRadius: 2,
                                            spacing: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.orange[300]!,
                                                  Colors.purple[300]!,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    offset: const Offset(1, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.orange[300]!
                                                        .withOpacity(0.3),
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: AspectRatio(
                                                aspectRatio: 1.8,
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Image.memory(
                                                      imageBytes,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors.transparent,
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.1),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              checkLesson(lessonGroupId);
                                            },
                                            icon: const Icon(Icons.check,
                                                size: 20),
                                            label: Text(
                                              "Шалгах",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors
                                                  .orange[300]!
                                                  .withOpacity(0.9),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              elevation: 2,
                                              minimumSize: Size.zero,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DotsPainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  DotsPainter({
    required this.color,
    required this.dotRadius,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
