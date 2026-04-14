import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      home: const CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  // Untuk Fitur Pencarian
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";

  String _selectedStatus = 'Segera';

  Future<List<dynamic>> fetchEvents() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/events'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data dari database');
    }
  }

  // Fungsi Tambah ATAU Edit (Digabung)
  Future<void> saveEvent({int? eventId}) async {
    final url = eventId == null 
        ? 'http://127.0.0.1:8000/api/events' 
        : 'http://127.0.0.1:8000/api/events/$eventId';
        
    final response = eventId == null
        ? await http.post(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "title": _titleController.text,
              "description": _descController.text,
              "month_year": _monthController.text,
              "status": _selectedStatus,
              "location": _locationController.text.isEmpty ? "-" : _locationController.text,
              "image_url": "-"
            }),
          )
        : await http.put(
            Uri.parse(url),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "title": _titleController.text,
              "description": _descController.text,
              "month_year": _monthController.text,
              "status": _selectedStatus,
              "location": _locationController.text.isEmpty ? "-" : _locationController.text,
              "image_url": "-"
            }),
          );

    if (response.statusCode == 200) {
      setState(() {}); 
      if (mounted) Navigator.of(context).pop(); // Tutup Form
      if (eventId != null && mounted) Navigator.of(context).pop(); // Tutup pop-up detail jika mode edit
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(eventId == null ? 'Kegiatan ditambahkan!' : 'Kegiatan diperbarui!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  // Memunculkan Pop Up Form (Bisa untuk Tambah Baru / Edit yang lama)
  void _showAddDialog({Map<String, dynamic>? existingEvent}) {
    // Jika mode edit, isi kotak teks dengan data lama
    if (existingEvent != null) {
      _titleController.text = existingEvent['title'];
      _descController.text = existingEvent['description'];
      _monthController.text = existingEvent['month_year'];
      _locationController.text = existingEvent['location'] ?? '';
      _selectedStatus = existingEvent['status'];
    } else {
      _titleController.clear();
      _descController.clear();
      _monthController.clear();
      _locationController.clear();
      _selectedStatus = 'Segera';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingEvent == null ? 'Tambah Kegiatan Baru' : 'Edit Kegiatan'),
          content: SizedBox(
            width: 400, 
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Nama Kegiatan')),
                  const SizedBox(height: 8),
                  
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Deskripsi Singkat', alignLabelWithHint: true),
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 3, maxLines: 6,
                  ),
                  const SizedBox(height: 8),

                  TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Lokasi Kegiatan (Contoh: Pura Besakih)')),
                  const SizedBox(height: 8),
                  
                  TextField(
                    controller: _monthController, readOnly: true,
                    decoration: const InputDecoration(labelText: 'Pilih Tanggal Kegiatan', suffixIcon: Icon(Icons.calendar_month, color: Colors.red)),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (pickedDate != null) {
                        List<String> namaBulan = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
                        List<String> namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
                        
                        // FORMAT TANGGAL DETAIL DENGAN HARI
                        String hari = namaHari[pickedDate.weekday - 1];
                        String formattedDate = "$hari, ${pickedDate.day} ${namaBulan[pickedDate.month - 1]} ${pickedDate.year}";
                        _monthController.text = formattedDate;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status Pelaksanaan'),
                    items: ['Segera', 'Terlaksana'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                    onChanged: (newValue) => setState(() => _selectedStatus = newValue!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () => saveEvent(eventId: existingEvent?['id']),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Pop Up untuk melihat detail saat kartu diklik
  void _showDetailDialog(Map<String, dynamic> event) {
    Color statusColor = event['status'] == 'Terlaksana' ? Colors.lightBlue : Colors.orange;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(event['month_year'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Expanded(child: Text(event['location'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info, size: 16, color: statusColor),
                    const SizedBox(width: 8),
                    Text(event['status'], style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                  ],
                ),
                const Divider(height: 24),
                const Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(event['description'], style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _showAddDialog(existingEvent: event), // Tombol Edit
              child: const Text('Edit Kegiatan', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              decoration: const InputDecoration(hintText: 'Cari kegiatan...', border: InputBorder.none),
              onChanged: (value) => setState(() => _searchQuery = value),
            )
          : const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BIDANG CAGAR BUDAYA', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A), fontSize: 28, letterSpacing: 1.5)),
                Text('DINAS KEBUDAYAAN KABUPATEN BADUNG', style: TextStyle(fontSize: 14, color: Colors.black87, letterSpacing: 0.5)),
              ],
            ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.red, size: 28),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = "";
                }
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.red));
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Belum ada kegiatan. Klik tombol + di bawah untuk menambah.'));

          List<dynamic> events = snapshot.data!;

          // FITUR PENCARIAN
          if (_searchQuery.isNotEmpty) {
            events = events.where((event) => 
              event['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
              event['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
            ).toList();
          }

          // GROUPING PINTAR UNTUK HEADER
          Map<String, List<dynamic>> groupedEvents = {};
          for (var event in events) {
            String fullDate = event['month_year'] ?? '';
            List<String> parts = fullDate.split(' ');
            
            // Mengambil 2 kata terakhir (Bulan dan Tahun) untuk Header Merah
            String groupMonth = fullDate; 
            if (parts.length >= 2) groupMonth = "${parts[parts.length - 2]} ${parts[parts.length - 1]}";

            if (!groupedEvents.containsKey(groupMonth)) groupedEvents[groupMonth] = [];
            groupedEvents[groupMonth]!.add(event); 
          }

          if (groupedEvents.isEmpty) return const Center(child: Text('Kegiatan tidak ditemukan.'));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: groupedEvents.length,
            itemBuilder: (context, index) {
              String monthKey = groupedEvents.keys.elementAt(index);
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildMonthSection(monthKey, groupedEvents[monthKey]!),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMonthSection(String month, List<dynamic> eventsInMonth) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_back_ios, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Text(month, style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...eventsInMonth.map((event) {
          Color statusColor = event['status'] == 'Terlaksana' ? Colors.lightBlue : Colors.orange;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GestureDetector(
              onTap: () => _showDetailDialog(event), // KARTU SEKARANG BISA DIKLIK!
              child: _buildEventCard(event['month_year'], event['title'], event['location'], event['status'], statusColor),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEventCard(String fullDate, String title, String? location, String status, Color statusColor) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: Colors.purple.shade300, width: 4))),
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                  const Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Menampilkan Lokasi di Kartu
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(location ?? '-', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}