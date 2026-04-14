import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ApiService _apiService = ApiService();
  
  // Controller untuk Form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  // Controller untuk Pencarian
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";
  String _selectedStatus = 'Segera';

  // Fungsi untuk memicu refresh data
  void _refreshData() {
    setState(() {});
  }

  // Fungsi Simpan (Tambah atau Update)
  Future<void> _handleSave({int? eventId}) async {
    final eventData = EventModel(
      id: eventId,
      title: _titleController.text,
      description: _descController.text,
      monthYear: _monthController.text,
      status: _selectedStatus,
      location: _locationController.text.isEmpty ? "-" : _locationController.text,
      imageUrl: "-",
    );

    bool success;
    if (eventId == null) {
      success = await _apiService.addEvent(eventData);
    } else {
      success = await _apiService.updateEvent(eventId, eventData);
    }

    if (success) {
      _refreshData();
      if (mounted) Navigator.of(context).pop(); // Tutup Form
      if (eventId != null && mounted) Navigator.of(context).pop(); // Tutup Detail jika mode edit
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventId == null ? 'Kegiatan berhasil ditambahkan!' : 'Kegiatan berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  // Dialog Form Tambah/Edit
  void _showEventForm({EventModel? existingEvent}) {
    if (existingEvent != null) {
      _titleController.text = existingEvent.title;
      _descController.text = existingEvent.description;
      _monthController.text = existingEvent.monthYear;
      _locationController.text = existingEvent.location;
      _selectedStatus = existingEvent.status;
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
                    minLines: 3, maxLines: 6,
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Lokasi Kegiatan')),
                  const SizedBox(height: 8),
                  
                  // PERBAIKAN 2: Warna Ikon Kalender pada Form mengikuti tema Biru
                  TextField(
                    controller: _monthController,
                    readOnly: true,
                    decoration: InputDecoration(
                        labelText: 'Pilih Tanggal Kegiatan',
                        suffixIcon: Icon(Icons.calendar_month, color: Theme.of(context).primaryColor)), // <- DIUBAH
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        List<String> namaBulan = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
                        List<String> namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
                        String formattedDate = "${namaHari[pickedDate.weekday - 1]}, ${pickedDate.day} ${namaBulan[pickedDate.month - 1]} ${pickedDate.year}";
                        _monthController.text = formattedDate;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: ['Segera', 'Terlaksana'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => _selectedStatus = val!,
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
            
            // PERBAIKAN 3: Warna Tombol Simpan mengikuti tema Biru
            ElevatedButton(
              onPressed: () => _handleSave(eventId: existingEvent?.id),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor), // <- DIUBAH
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Dialog Konfirmasi Hapus
  void _confirmDelete(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kegiatan?'),
        content: Text('Apakah Anda yakin ingin menghapus kegiatan "${event.title}" secara permanen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Batal
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              // Pastikan API Service Anda sudah memiliki metode deleteEvent(int id)
              bool success = await _apiService.deleteEvent(event.id!);
              if (success) {
                _refreshData();
                if (mounted) {
                  Navigator.pop(context); // Tutup pop-up konfirmasi
                  Navigator.pop(context); // Tutup pop-up detail
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kegiatan dihapus!'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  // Dialog Detail Kegiatan
  void _showDetail(EventModel event) {
    Color statusColor = event.status == 'Terlaksana' ? Colors.lightBlue : Colors.orange;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(Icons.calendar_today, event.monthYear),
              _detailRow(Icons.location_on, event.location),
              _detailRow(Icons.info, event.status, color: statusColor),
              const Divider(height: 24),
              const Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(event.description, style: const TextStyle(height: 1.5)),
            ],
          ),
        ),
        actions: [
          // FITUR BARU: Tombol Hapus (Kiri)
          TextButton(
            onPressed: () => _confirmDelete(event), 
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
          const Spacer(), // Mendorong tombol Edit dan Tutup ke kanan
          // Tombol Edit
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup pop-up detail dulu
              _showEventForm(existingEvent: event); // Buka form edit
            }, 
            child: Text('Edit', style: TextStyle(color: Theme.of(context).primaryColor))
          ),
          // Tombol Tutup
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Tutup', style: TextStyle(color: Colors.grey))
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color))),
        ],
      ),
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
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Cari kegiatan...', border: InputBorder.none),
              onChanged: (val) => setState(() => _searchQuery = val),
            )
          : const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BIDANG CAGAR BUDAYA', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A), fontSize: 28, letterSpacing: 1.5)),
                Text('DINAS KEBUDAYAAN KABUPATEN BADUNG', style: TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: const Color(0xFF1E3A8A)),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchQuery = "";
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventForm(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _apiService.fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Belum ada kegiatan.'));

          List<EventModel> events = snapshot.data!;
          if (_searchQuery.isNotEmpty) {
            events = events.where((e) => e.title.toLowerCase().contains(_searchQuery.toLowerCase()) || e.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
          }

          // Grouping logic
          Map<String, List<EventModel>> grouped = {};
          for (var e in events) {
            List<String> parts = e.monthYear.split(' ');
            String monthYear = parts.length >= 2 ? "${parts[parts.length - 2]} ${parts[parts.length - 1]}" : e.monthYear;
            if (!grouped.containsKey(monthYear)) grouped[monthYear] = [];
            grouped[monthYear]!.add(e);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              String key = grouped.keys.elementAt(index);
              return _buildMonthSection(key, grouped[key]!);
            },
          );
        },
      ),
    );
  }

  Widget _buildMonthSection(String month, List<EventModel> events) {
    // Ambil warna utama tema
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        // PERBAIKAN 1: Warna Kotak Header Bulan mengikuti tema Biru
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05), // <- Biru transparan sangat lembut
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios, color: primaryColor, size: 18), // <- Ikon Biru
              const SizedBox(width: 8),
              Text(month, style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold)), // <- Teks Biru
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...events.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _showDetail(e),
            child: _buildEventCard(e),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildEventCard(EventModel e) {
    Color statusColor = e.status == 'Terlaksana' ? Colors.lightBlue : Colors.orange;
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: Colors.purple.shade300, width: 4))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.monthYear, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      Text(e.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(e.location, style: const TextStyle(fontSize: 13, color: Colors.grey))]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}