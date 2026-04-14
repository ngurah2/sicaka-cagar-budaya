import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart'; // Import screen yang baru dibuat

void main() {
  runApp(const SiCakaApp());
}

class SiCakaApp extends StatelessWidget {
  const SiCakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SI-CAKA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const CalendarScreen(), // Memanggil layar utama
    );
  }
}