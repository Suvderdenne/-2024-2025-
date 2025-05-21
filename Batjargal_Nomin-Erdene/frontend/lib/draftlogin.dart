// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:ebook_app/pages/home/home.dart';
// import 'package:ebook_app/signup.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import './config.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   Future<void> login() async {
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       showSnackbar("Имэйл болон нууц үгээ оруулна уу!");
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl + 'user/'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'action': "login",
//           'email': email,
//           'password': hashPassword(password),
//         }),
//       );

//       print(response.body);

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData["resultCode"] == 200) {
//           String? rawCookie = response.headers['set-cookie'];
//           if (rawCookie != null) {
//             String sessionCookie = rawCookie.split(';')[0];
//             await saveSessionCookie(sessionCookie);
//             print("Session cookie хадгалагдсан: $sessionCookie");
//           }

//           // Хэрэглэгчийн мэдээллийг хадгалах
//           final user = responseData["data"][0];
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setInt('userid', user["userid"]);
//           await prefs.setString('username', user["username"]);
//           await prefs.setString('email', user["email"]);

//           // Амжилттай нэвтэрсэн тул Home рүү шилжих
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomePage()),
//           );
//         } else {
//           showSnackbar("Нэвтрэхэд алдаа гарлаа: ${responseData["resultMessage"]}");
//         }
//       } else {
//         showSnackbar("1Серверээс алдаатай хариу ирлээ (${response.statusCode})");
//       }
//     } catch (e) {
//       showSnackbar("Сервертэй холбогдож чадсангүй! Алдаа: $e");
//       print(e);
//     }
//   }

//   // showSnackbar функц
//   void showSnackbar(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/login.jpeg'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 30),
//             child: Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(height: 20),
//                   buildTextField("Имэйл", Icons.email, false, _emailController),
//                   SizedBox(height: 10),
//                   buildTextField(
//                     "Нууц үг",
//                     Icons.lock,
//                     true,
//                     _passwordController,
//                   ),
//                   SizedBox(height: 10),
//                   buildGradientButton(context),
//                   SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SignupPage(),
//                             ),
//                           );
//                         },
//                         child: Text(
//                           "Бүртгүүлэх",
//                           style: TextStyle(
//                             color: Colors.black87,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTextField(
//     String label,
//     IconData icon,
//     bool isPassword,
//     TextEditingController controller,
//   ) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.grey),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   Widget buildGradientButton(BuildContext context) {
//     return GestureDetector(
//       onTap: login,
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 15),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.red, Colors.deepPurple],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Center(
//           child: Text(
//             "Нэвтрэх",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
