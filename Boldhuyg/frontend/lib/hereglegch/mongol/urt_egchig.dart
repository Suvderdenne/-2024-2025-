import 'package:flutter/material.dart';

class UrtEgshigDolooPage extends StatelessWidget {
  const UrtEgshigDolooPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Урт эгшиг долоо"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[100]!, Colors.amber[300]!, Colors.deepOrange[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/urt_egshig.jpg', width: 550), // Хүүхэлдэйн зураг
              SizedBox(height: 20),
              Text(
                "Урт эгшгийг хамтдаа сурцгаая!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              SizedBox(height: 30),
              buildOptionButton(context, "📖 Сурах", Colors.blue),
              buildOptionButton(context, "🔗 Холбох", Colors.green),
              buildOptionButton(context, "✅ Бататгах", Colors.purple),
              buildOptionButton(context, "🎵 Дуу", Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOptionButton(BuildContext context, String text, Color color) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Material(
        color: Colors.transparent,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: InkWell(
            onTap: () {
              // Навигац эсвэл логик оруулж болно
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
