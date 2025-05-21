import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';

class Lesson {
  final int id;
  final String title;
  final String? imageBase64;
  final String? audioBase64;

  Lesson({
    required this.id,
    required this.title,
    this.imageBase64,
    this.audioBase64,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      imageBase64: json['image_base64'],
      audioBase64: json['audio_base64'],
    );
  }
}

class LessonPage extends StatefulWidget {
  final int lessonGroupId;

  const LessonPage({super.key, required this.lessonGroupId});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  List<Lesson> lessons = [];
  bool isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchLessons();
  }

  Future<void> fetchLessons() async {
    final url =
        Uri.parse('http://127.0.0.1:8000/lessons/${widget.lessonGroupId}/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          lessons = data.map((json) => Lesson.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load lessons');
      }
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
    }
  }

  void playAudio(String base64Audio) async {
    final bytes = base64Decode(base64Audio);
    await _audioPlayer.play(BytesSource(bytes));
  }

  void showImageDialogWithSound(String base64Image, String? audioBase64) {
    if (audioBase64 != null) {
      playAudio(audioBase64);
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(
              base64Decode(base64Image),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isSmallScreen = width < 360;

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text(
          'Хичээлүүд',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 20 : 24,
            color: Colors.orange[900],
          ),
        ),
        backgroundColor: Colors.orange.shade100,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: Lottie.asset(
                'assets/animations/loading.json',
                width: isSmallScreen ? 100 : 150,
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.03,
                vertical: height * 0.01,
              ),
              child: GridView.builder(
                itemCount: lessons.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: width * 0.03,
                  mainAxisSpacing: height * 0.015,
                  childAspectRatio: isSmallScreen ? 0.7 : 0.8,
                ),
                itemBuilder: (context, index) {
                  final lesson = lessons[index];

                  final imageWidget = lesson.imageBase64 != null
                      ? GestureDetector(
                          onTap: () => showImageDialogWithSound(
                            lesson.imageBase64!,
                            lesson.audioBase64,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: 1.2,
                              child: Image.memory(
                                base64Decode(lesson.imageBase64!),
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: isSmallScreen ? 100 : 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.image_not_supported,
                            size: isSmallScreen ? 40 : 50,
                            color: Colors.grey[400],
                          ),
                        );

                  return Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          imageWidget,
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Flexible(
                            child: Text(
                              lesson.title,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          if (lesson.audioBase64 != null)
                            ElevatedButton(
                              onPressed: () => playAudio(lesson.audioBase64!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 6 : 8,
                                  vertical: isSmallScreen ? 4 : 6,
                                ),
                                minimumSize: Size.zero,
                              ),
                              child: Icon(
                                Icons.volume_up,
                                color: Colors.white,
                                size: isSmallScreen ? 20 : 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
