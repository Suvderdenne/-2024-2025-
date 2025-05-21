import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveSessionCookie(String cookie) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('session_cookie', cookie);
}

Future<String?> getSessionCookie() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('session_cookie');
}

Future<void> clearSessionCookie() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('session_cookie');
}

Future<void> logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs
      .clear(); // session_cookie, userid, username, email бүгдийг арилгана
}

Future<bool> isLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('session_cookie') != null;
}

String baseUrl = "http://172.20.10.5:8000/";

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = md5.convert(bytes);
  return digest.toString();
}
