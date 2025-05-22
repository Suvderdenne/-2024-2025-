import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(VollMediaApp());
}

class VollMediaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VollMedia',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        primarySwatch: Colors.deepPurple,
        cardColor: Colors.white,
        textTheme: GoogleFonts.notoSansTextTheme(
          Theme.of(context).textTheme.copyWith(
                bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
                bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
              ),
        ),
      ),
      home: NewsFeedPage(),
    );
  }
}

class NewsFeedPage extends StatelessWidget {
  final List<Map<String, String>> articles = [
    {
      'title':
          'Монголын Волейболын Холбооны ✨ ГЭРЭЛ ТҮГЭЭ ✨ уриа дор гурван сарын турш үргэлжилсэн Үндэсний Дээд Лиг 2024-2025 улирал ийнхүү өндөрлөлөө.',
      'image': 'assets/volleyball_finals.jpg',
      'time': '15 өдрийн өмнө'
    },
    {
      'title':
          '“Монголын волейболын тамирчдын холбоо”-г Монголын волейболын холбооноос албан ёсоор батламжлалаа.',
      'image': 'assets/volleyball_players.jpg',
      'time': '20 өдрийн өмнө'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VollMedia'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          var article = articles[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title']!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      article['image']!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    article['time']!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Мэдээ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_volleyball), label: 'Тэмцээн'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профайл'),
        ],
      ),
    );
  }
}
