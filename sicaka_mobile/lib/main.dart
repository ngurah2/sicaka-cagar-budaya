import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- Library Font Baru
import 'screens/calendar_screen.dart';
import 'screens/dashboard_screen.dart';

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
        // 1. SKEMA WARNA BARU (Biru & Emas)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Biru Tua
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFD4AF37), // Emas
        ),
        useMaterial3: true,
        
        // 2. FONT POPPINS UNTUK SELURUH APLIKASI
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        
        // 3. MEMBERSIHKAN APPBAR
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent, // Mencegah warna berubah saat di-scroll
          elevation: 0,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CalendarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF1E3A8A), // Tombol navigasi aktif berwarna Biru Tua
        unselectedItemColor: Colors.grey.shade400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Kalender',
          ),
        ],
      ),
    );
  }
}