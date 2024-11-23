import 'package:chating_application_2024/src/screens/Chat.dart';
import 'package:chating_application_2024/src/screens/Home.dart';
import 'package:chating_application_2024/src/screens/Login.dart';
import 'package:chating_application_2024/src/screens/Register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/chat': (context) => ChatScreen(),
      },
    );
  }
}
