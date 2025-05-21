import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'math_lesson_page.dart';
import 'mongol_lesson_page.dart';

class SubjectSelectionPage extends StatefulWidget {
  final String token;
  const SubjectSelectionPage({super.key, required this.token});

  @override
  State<SubjectSelectionPage> createState() => _SubjectSelectionPageState();
}

class _SubjectSelectionPageState extends State<SubjectSelectionPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> subjects = [];
  bool isLoading = true;
  bool hasError = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, Uint8List> _cachedIcons = {};
  Map<String, Uint8List> _cachedAudio = {};
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _prefetchData();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _prefetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/subjects/school/1/'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        for (var subject in data) {
          final iconBase64 = subject['icon_base64'] ?? '';
          final audioBase64 = subject['audio_base64'] ?? '';
          if (iconBase64.isNotEmpty) {
            _cachedIcons[subject['name']] = base64Decode(iconBase64);
          }
          if (audioBase64.isNotEmpty) {
            _cachedAudio[subject['name']] = base64Decode(audioBase64);
          }
        }
        setState(() {
          subjects = data;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8D0E7), Color(0xFFCFEFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? _buildLoading(width, height)
              : hasError
                  ? _buildError(width, height)
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.04,
                            vertical: height * 0.02,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: EdgeInsets.all(width * 0.03),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: width * 0.06,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          'Хичээл сонгох',
                          style: GoogleFonts.baloo2(
                            fontSize: width * 0.1,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.05),
                        Lottie.asset(
                          'assets/animations/an.json',
                          height: height * 0.3,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: height * 0.05),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: height * 0.02),
                                SizedBox(height: height * 0.02),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.06,
                                      vertical: height * 0.01,
                                    ),
                                    itemCount: subjects.length,
                                    itemBuilder: (context, index) {
                                      final subject = subjects[index];
                                      final name = subject['name'] ?? 'No Name';
                                      final iconBytes = _cachedIcons[name];
                                      final audioBytes = _cachedAudio[name];

                                      return GestureDetector(
                                        onTap: () async {
                                          _bounceController.forward(from: 0.9);
                                          if (audioBytes != null) {
                                            await _audioPlayer
                                                .play(BytesSource(audioBytes));
                                          }
                                          Future.delayed(
                                              const Duration(milliseconds: 300),
                                              () {
                                            navigateToSubjectPage(name);
                                          });
                                        },
                                        child: ScaleTransition(
                                          scale: _bounceController,
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                bottom: height * 0.015),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: width * 0.04,
                                              vertical: height * 0.02,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 10,
                                                  offset: const Offset(4, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(
                                                      width * 0.02),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.6),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: iconBytes != null
                                                      ? Image.memory(
                                                          iconBytes,
                                                          width: width * 0.12,
                                                          height: width * 0.12,
                                                        )
                                                      : Icon(
                                                          Icons.menu_book,
                                                          size: width * 0.12,
                                                          color: Colors.purple,
                                                        ),
                                                ),
                                                SizedBox(width: width * 0.04),
                                                Expanded(
                                                  child: Text(
                                                    name,
                                                    style: GoogleFonts.baloo2(
                                                      fontSize: width * 0.055,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.deepPurple,
                                                    ),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: width * 0.05,
                                                  color: Colors.purple,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildLoading(double width, double height) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/ani.json',
            width: width * 0.6,
            height: height * 0.3,
          ),
          SizedBox(height: height * 0.03),
          Text(
            "Хичээлүүдийг ачааллаж байна...",
            style: GoogleFonts.baloo2(
              fontSize: width * 0.055,
              color: Colors.purple[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(double width, double height) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/qw.json',
            width: width * 0.5,
            height: height * 0.3,
          ),
          SizedBox(height: height * 0.03),
          Text(
            "Алдаа гарлаа!",
            style: GoogleFonts.baloo2(
              fontSize: width * 0.06,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: height * 0.02),
          ElevatedButton(
            onPressed: _prefetchData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.08,
                vertical: height * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              "Дахин оролдох",
              style: GoogleFonts.baloo2(
                fontSize: width * 0.045,
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToSubjectPage(String subjectName) {
    if (subjectName.contains('Математик')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MathPage()));
    } else if (subjectName.contains('Монгол')) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MongolianLanguagePage(token: widget.token)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Хичээлийн хуудас байхгүй.', style: GoogleFonts.baloo2()),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
