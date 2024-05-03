import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_nodejs/dashboard.dart';
import 'package:todo_nodejs/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  runApp(MyApp(token: token ?? ""));
}

class MyApp extends StatelessWidget {
  final String token;

  const MyApp({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = token.isNotEmpty && !JwtDecoder.isExpired(token);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? DashBoard(token: token) : LoginPage(),
    );
  }
}
