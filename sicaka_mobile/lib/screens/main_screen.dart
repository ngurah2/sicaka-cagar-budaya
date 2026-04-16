import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import '../models/event_model.dart';

class MainScreen extends StatefulWidget {
  // Variabel penentu status (Admin atau Tamu)
  final bool isAdmin; 
  const MainScreen({super.key, this.isAdmin = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; 

  @override
  void initState() {
    super.initState();
    // Alarm hanya menyala jika yang masuk adalah Admin
    if (widget.isAdmin) {
      _jalankanSistemAlarm();
    }
  }

  // --- KODE ALARM TETAP SAMA SEPERTI SEBELUMNYA ---
  void _jalankanSistemAlarm() async {
    final ApiService api = ApiService();
    try {
      List<EventModel> events = await api.fetchEvents();
      DateTime now = DateTime.now();
      DateTime hariIni = DateTime(now.year, now.month, now.day);
      DateTime besok = hariIni.add(const Duration(days: 1));
      List<EventModel> kegiatanMendesak = [];

      Map<String, int> kamusBulan = {
        'Januari': 1, 'Februari': 2, 'Maret': 3, 'April': 4,
        'Mei': 5, 'Juni': 6, 'Juli': 7, 'Agustus': 8,
        'September': 9, 'Oktober': 10, 'November': 11, 'Desember': 12
      };

      for (var e in events) {
        if (e.status == 'Terlaksana') continue;
        List<String> parts = e.monthYear.split(' ');
        if (parts.length >= 4) {
          int hari = int.tryParse(parts[1]) ?? 0;
          int bulan = kamusBulan[parts[2]] ?? 0;
          int tahun = int.tryParse(parts[3]) ?? 0;
          if (hari != 0 && bulan != 0 && tahun != 0) {
            DateTime tanggalKegiatan = DateTime(tahun, bulan, hari);
            if (tanggalKegiatan.isAtSameMomentAs(hariIni) || tanggalKegiatan.isAtSameMomentAs(besok)) {
              kegiatanMendesak.add(e);
            }
          }
        }
      }
      if (kegiatanMendesak.isNotEmpty && mounted) {
        _tampilkanPopUpAlarm(kegiatanMendesak);
      }
    } catch (e) {}
  }

  void _tampilkanPopUpAlarm(List<EventModel> kegiatanMendesak) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
              SizedBox(width: 8),
              Text('PENGINGAT KEGIATAN!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Terdapat kegiatan Cagar Budaya yang akan berlangsung HARI INI atau BESOK:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                ...kegiatanMendesak.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border(left: BorderSide(color: Colors.orange.shade400, width: 4)),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(e.monthYear, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        ],
                      )
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('Baik, Saya Mengerti', style: TextStyle(color: Colors.white)),
            )
          ],
        );
      }
    );
  }
  // --- BATAS KODE ALARM ---

  @override
  Widget build(BuildContext context) {
    // Memasukkan status isAdmin ke dalam halaman Kalender
    final List<Widget> screens = [
      const DashboardScreen(),
      CalendarScreen(isAdmin: widget.isAdmin), 
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SI-CAKA Badung', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          // LOGIKA TOMBOL LOGIN/LOGOUT
          if (!widget.isAdmin)
            TextButton.icon(
              onPressed: () {
                // Pergi ke halaman Login
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text('Login Admin', style: TextStyle(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Keluar',
              onPressed: () {
                // Hapus kunci (token) dan kembali jadi tamu
                ApiService.token = null;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen(isAdmin: false)));
              },
            )
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
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