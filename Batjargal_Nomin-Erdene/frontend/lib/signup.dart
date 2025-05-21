import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './config.dart';
import './main.dart';
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController fnameController = TextEditingController(); // Нэр
  final TextEditingController lnameController = TextEditingController(); // Овог

  bool isPasswordVisible = false;
  Future<bool> verifyCode(String code, String email) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + 'user/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"action": "token", 'email': email, 'token': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['resultCode'] == 201;
      }
    } catch (e) {
      showAlert(context, 'Алдаа: $e');
    }
    return false;
  }

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      showAlert(context, 'Нууц үг таарахгүй байна!');
      return;
    }

    try {
      final hashedPassword = hashPassword(passwordController.text);
      final response = await http.post(
        Uri.parse(baseUrl + 'user/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': "register",
          'username': usernameController.text,
          'email': emailController.text,
          'password': hashedPassword,
        }),
      );

      // Хариу авах
      if (response.statusCode == 200) {
        final successData = jsonDecode(response.body);
        if (successData['resultCode'] == 201) {
          showVerificationDialog(context, emailController.text);
        } else {
          showAlert(context, successData['resultMessage']);
        }
      } else {
        // Серверээс 200-с бусад код ирвэл
        showAlert(context, 'Сервертэй холбогдож чадсангүй.');
      }
    } catch (e) {
      showAlert(context, 'Алдаа гарлаа: $e');
    }
  }

  void showAlert(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage, style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 201, 200, 200),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void showVerificationDialog(BuildContext context, String email) {
    TextEditingController verificationCodeController = TextEditingController();
    int remainingTime = 120;

    Timer? timer;
    void startTimer() {
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          t.cancel();
          Navigator.pop(context);
        }
      });
    }

    startTimer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Код'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$email хаяг руу илгээлээ.'),
                  TextField(
                    controller: verificationCodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Код'),
                  ),
                  // SizedBox(height: 10),
                  // Text(
                  //   'Үлдсэн хугацаа: $remainingTime сек',
                  //   style: TextStyle(color: Colors.red),
                  // ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(context);
                  },
                  child: Text('Цуцлах'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String code = verificationCodeController.text.trim();
                    if (code.isNotEmpty) {
                      bool isValid = await verifyCode(code, email);
                      if (isValid) {
                        timer?.cancel();
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      } else {
                        showAlert(context, 'Буруу код. Дахин оролдоно уу!');
                      }
                    }
                  },
                  child: Text('Шалгах'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/loginn.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Signup form
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Бүртгүүлэх',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: usernameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Нэр',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Имэйл',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Нууц үг',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Нууц үгээ давтах',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 156, 179, 238),
                              Color.fromARGB(255, 17, 79, 203),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: 150,
                          height: 35,
                          alignment: Alignment.center,
                          child: Text(
                            'Бүртгүүлэх',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        'Нэвтрэх',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:ebook_app/login.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   _SignupPageState createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController =
//       TextEditingController();

//   String hashPassword(String password) {
//     final bytes = utf8.encode(password);
//     final digest = md5.convert(bytes);
//     return digest.toString();
//   }

//   // Flutter signup page нь бүх оролтыг стандарт байдлаар илгээнэ
//   Future<void> registerUser() async {
//     if (passwordController.text != confirmPasswordController.text) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Нууц үг таарахгүй байна!')));
//       return;
//     }

//     final response = await http.post(
//       Uri.parse('http://127.0.0.1:8000/register/'),
//       headers: {'Content-Type': 'application/json; charset=UTF-8'},
//       body: jsonEncode({
//         'username': usernameController.text,
//         'email': emailController.text,
//         'password': passwordController.text, // Plain text password
//       }),
//     );

//     if (response.statusCode == 201) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Амжилттай бүртгэгдлээ!')));
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => LoginPage()),
//       );
//     } else {
//       var data = jsonDecode(response.body);
//       String errorMessage = data['error'] ?? 'Бүртгэл амжилтгүй';
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(errorMessage)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             TextField(
//               controller: usernameController,
//               decoration: InputDecoration(labelText: 'Хэрэглэгчийн нэр'),
//             ),
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(labelText: 'Имэйл'),
//             ),
//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: InputDecoration(labelText: 'Нууц үг'),
//             ),
//             TextField(
//               controller: confirmPasswordController,
//               obscureText: true,
//               decoration: InputDecoration(labelText: 'Нууц үг давтах'),
//             ),
//             ElevatedButton(onPressed: registerUser, child: Text('Бүртгүүлэх')),
//           ],
//         ),
//       ),
//     );
//   }
// }
