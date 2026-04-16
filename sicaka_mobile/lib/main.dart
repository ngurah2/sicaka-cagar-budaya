import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Panggil layar login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SI-CAKA - Dinas Kebudayaan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A), // Biru Instansi
        fontFamily: 'Roboto', // Font formal
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      // PERUBAHAN: Layar pertama yang dibuka adalah LoginScreen
      home: const LoginScreen(), 
    );
  }
}