import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text(
        //   'Word Search Journey',
        //   style: TextStyle(
        //     fontWeight: FontWeight.w500, // Жинг бага зэрэг өөрчлөх
        //   ),
        // ),
        centerTitle: true, // Title-ийг төвд байрлуулах
        elevation: 0, // AppBar-ийн сүүдрийг арилгах
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0), // Icon-ыг бага зэрэг зайдуулах
            child: IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              splashRadius: 25, // Splash effect-ийн хэмжээг багасгах
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Нэмэлт padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Хүүхдүүдийг төвд байрлуулах
            children: [
              Text(
                'Word Search',
                style: TextStyle(
                  fontSize: 32, // Бага зэрэг томруулсан
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800], // Өнгөнд бага зэрэг өөрчлөлт
                  letterSpacing: 1.2, // Үсгүүдийн хоорондын зайг нэмэх
                  shadows: [ // Нэмэлт сүүдэр
                    Shadow(
                      blurRadius: 3,
                      color: Colors.grey.withOpacity(0.3),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center, // Текстийг төвд байрлуулах
              ),
              Text(
                'Journey',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey[600],
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/language');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Бага зэрэг дугуй хэлбэртэй
                  ),
                  elevation: 5,
                  backgroundColor: Colors.blue[600], // Өнгөнд бага зэрэг өөрчлөлт
                ),
                child: const Text(
                  'PLAY',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Find the hidden words!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}