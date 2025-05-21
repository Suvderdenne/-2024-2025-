import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'select_service.dart'; // Import the SelectServicePage (where the user selects the service)
import 'login.dart'; // Import the LoginPage for redirect when not logged in

class BookingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(
          255, 235, 233, 252), // Light purple background for the whole page
      body: Center(
        child: Container(
          height: 550,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 218, 175, 249),
                Color.fromARGB(255, 174, 129, 234),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 3,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Цаг захиалах хэсэгт тавтай морил',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 98, 24, 158),
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center, // Centering the title text
                ),
                SizedBox(height: 20),
                Text(
                  'Захиалсан цагаа өөрчлөх шаардлагатай бол урьдчилан мэдэгдэнэ үү. Хэрэв таны хүссэн цаг идэвхгүй буюу бүх цаг дууссан бол боломжтой цагийг сонгох. Тухайн үйлчилгээний талаар урьдчилан мэдээлэл авах. Захиалсан цагийнхаа хугацааг алдахгүйгээр ирэх, эсвэл 3-4 цагийн өмнө мэдэгдэх, хожимдвол захиалсан цаг хүчингүй болохыг анхаарна уу.',
                  textAlign: TextAlign.justify, // Justifying the paragraph text
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontFamily: 'Roboto',
                  ),
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      // Буцах moved to the left
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color.fromARGB(255, 98, 24, 158),
                        minimumSize: Size(100, 50),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Буцах',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 98, 24, 158),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      // Цаг захиалах moved to the right
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? accessToken = prefs.getString('access_token');

                        if (accessToken != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectServicePage()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 50),
                        backgroundColor: Color.fromARGB(255, 98, 24, 158),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Цаг захиалах',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
