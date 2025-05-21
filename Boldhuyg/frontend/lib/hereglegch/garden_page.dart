import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

import 'tsetserleg/amitan.dart';
import 'tsetserleg/duu.dart';
import 'tsetserleg/durs.dart';
import 'tsetserleg/colors_page.dart';
import 'tsetserleg/ulger.dart'; // ✅ Энэ файл доор нь оруулсан байгаа
import 'tsetserleg/math.dart';
import 'activity_list_page.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> with TickerProviderStateMixin {
  List<dynamic> lessons = [];
  final AudioPlayer audioPlayer = AudioPlayer();
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  late AnimationController _colorController;

  @override
  void initState() {
    super.initState();
    fetchLessons();
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _colorController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _bounceController.dispose();
    _scaleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> fetchLessons() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/subjects/school/2/'));

    if (response.statusCode == 200) {
      setState(() {
        lessons = json.decode(utf8.decode(response.bodyBytes));
        lessons.sort((a, b) {
          if (a['name'] == 'Тоо') return 1;
          if (b['name'] == 'Тоо') return -1;
          if (a['name'] == 'Үлгэр') return 1;
          if (b['name'] == 'Үлгэр') return -1;
          return a['name'].compareTo(b['name']);
        });
      });
    } else {
      throw Exception('Error fetching data from API');
    }
  }

  Future<void> _playBase64Audio(String base64Audio) async {
    try {
      final bytes = base64Decode(base64Audio);
      await audioPlayer.stop();
      await audioPlayer.play(BytesSource(bytes), volume: 1.0);
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  Color _getCardColor(String title) {
    switch (title) {
      case 'Амьтан':
        return Color(0xFFFFB74D); // Brighter Orange
      case 'Дуу':
        return Color(0xFF4DB6AC); // Brighter Teal
      case 'Дүрс':
        return Color(0xFFE57373); // Brighter Pink
      case 'Өнгө':
        return Color(0xFFBA68C8); // Brighter Purple
      case 'Үлгэр':
        return Color(0xFF81C784); // Brighter Green
      case 'Тоо':
        return Color(0xFF64B5F6); // Brighter Blue
      default:
        return Color(0xFF90A4AE); // Brighter Grey
    }
  }

  Color _getCardGradientColor(String title) {
    switch (title) {
      case 'Амьтан':
        return Color(0xFFFFA726); // Even Brighter Orange
      case 'Дуу':
        return Color(0xFF26A69A); // Even Brighter Teal
      case 'Дүрс':
        return Color(0xFFEF5350); // Even Brighter Pink
      case 'Өнгө':
        return Color(0xFFAB47BC); // Even Brighter Purple
      case 'Үлгэр':
        return Color(0xFF66BB6A); // Even Brighter Green
      case 'Тоо':
        return Color(0xFF42A5F5); // Even Brighter Blue
      default:
        return Color(0xFF78909C); // Even Brighter Grey
    }
  }

  IconData _getLessonIcon(String title) {
    switch (title) {
      case 'Амьтан':
        return Icons.pets;
      case 'Дуу':
        return Icons.music_note;
      case 'Дүрс':
        return Icons.category;
      case 'Өнгө':
        return Icons.palette;
      case 'Үлгэр':
        return Icons.book;
      case 'Тоо':
        return Icons.calculate;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityListPage(lessonGroupId: 2),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                Colors.purple.shade700,
                Colors.pink.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.quiz,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                Colors.purple.shade700,
                Colors.pink.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceController.value * 4),
                  child: Icon(Icons.school, size: 32, color: Colors.white),
                );
              },
            ),
            SizedBox(width: 12),
            Text(
              'Цэцэрлэг',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade50,
                Colors.purple.shade50,
                Colors.pink.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.02,
            ),
            child: lessons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _bounceController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _bounceController.value * 10),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.deepPurple,
                                      Colors.purple.shade700,
                                      Colors.pink.shade600,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.school,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Хичээлүүдийг ачааллаж байна...',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    itemCount: lessons.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: width * 0.04,
                      mainAxisSpacing: width * 0.04,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final lesson = lessons[index];
                      final String title = lesson['name'] ?? 'Хичээл байхгүй';
                      final String? iconBase64 = lesson['icon_base64'];
                      final String? audioBase64 = lesson['audio_base64'];

                      return GestureDetector(
                        onTap: () {
                          if (audioBase64 != null) {
                            _playBase64Audio(audioBase64);
                          }

                          if (title == 'Амьтан') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AnimalPage()));
                          } else if (title == 'Дуу') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MusicPage()));
                          } else if (title == 'Дүрс') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShapesPage()));
                          } else if (title == 'Өнгө') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ColorsPage(subjectId: lesson['id']),
                                ));
                          } else if (title == 'Үлгэр') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FairyTalePage(subjectId: lesson['id']),
                                ));
                          } else if (title == 'Тоо') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MathAnimalPage(subjectId: lesson['id']),
                                ));
                          }
                        },
                        child: TweenAnimationBuilder(
                          duration: Duration(milliseconds: 300),
                          tween: Tween<double>(begin: 0.8, end: 1.0),
                          builder: (context, double scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _getCardColor(title),
                                    _getCardGradientColor(title),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        _getCardColor(title).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: width * 0.28,
                                    height: width * 0.28,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: iconBase64 != null
                                        ? ClipOval(
                                            child: Image.memory(
                                              base64Decode(iconBase64),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            _getLessonIcon(title),
                                            size: width * 0.18,
                                            color: _getCardGradientColor(title),
                                          ),
                                  ),
                                  SizedBox(height: height * 0.02),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: width * 0.05,
                                        color: _getCardGradientColor(title),
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class LessonDetailPage extends StatelessWidget {
  final String lessonTitle;
  const LessonDetailPage({super.key, required this.lessonTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          lessonTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 10,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Дэлгэрэнгүй хичээл: $lessonTitle',
            style: TextStyle(
                fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
