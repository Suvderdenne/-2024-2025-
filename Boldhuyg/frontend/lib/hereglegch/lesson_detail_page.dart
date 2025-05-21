import 'package:flutter/material.dart';

class LessonDetailPage extends StatelessWidget {
  final String lessonTitle;

  const LessonDetailPage({super.key, required this.lessonTitle});

  @override
  Widget build(BuildContext context) {
    // Дэлгэцийн хэмжээ авах
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Responsive хувьсагчууд
    final double titleFontSize = width * 0.07;
    final double textFontSize = width * 0.05;
    final double buttonPadding = width * 0.1;
    final double buttonHeight = height * 0.07;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lessonTitle,
          style: TextStyle(fontSize: width * 0.05),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
        child: Column(
          children: [
            // Хичээлийн нэр
            Text(
              lessonTitle,
              style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: height * 0.03),

            // Хичээлийн тайлбар
            Text(
              'Энд хичээлийн дэлгэрэнгүй тайлбар орно.',
              style: TextStyle(fontSize: textFontSize),
              textAlign: TextAlign.center,
            ),
            Spacer(),

            // Дасгал хийх товч
            ElevatedButton(
              onPressed: () {
                // Дасгал, тест хийх хуудсанд холбож өгч болно
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: buttonPadding, vertical: buttonHeight),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Дасгал хийх', style: TextStyle(fontSize: width * 0.05)),
            ),
          ],
        ),
      ),
    );
  }
}
