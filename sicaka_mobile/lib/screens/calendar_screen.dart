import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class CalendarScreen extends StatefulWidget {
  // PERUBAHAN: Menerima status Admin dari MainScreen
  final bool isAdmin; 
  const CalendarScreen({super.key, this.isAdmin = false});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ApiService _apiService = ApiService();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";
  String _selectedStatus = 'Segera';

  // VARIABEL UNTUK GAMBAR
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  String _existingImageUrl = "-";

  void _refreshData() {
    setState(() {});
  }

  Future<void> _handleSave({int? eventId}) async {
    String finalImageUrl = _existingImageUrl;

    if (_selectedImage != null) {
      String? uploadedUrl = await _apiService.uploadImage(_selectedImage!);
      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl;
      }
    }

    final eventData = EventModel(
      id: eventId,
      title: _titleController.text,
      description: _descController.text,
      monthYear: _monthController.text,
      status: _selectedStatus,
      location: _locationController.text.isEmpty ? "-" : _locationController.text,
      imageUrl: finalImageUrl, 
    );

    bool success;
    if (eventId == null) {
      success = await _apiService.addEvent(eventData);
    } else {
      success = await _apiService.updateEvent(eventId, eventData);
    }

    if (success) {
      _refreshData();
      if (mounted) {
        Navigator.of(context).pop(); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventId == null ? 'Kegiatan ditambahkan!' : 'Kegiatan diperbarui!'), 
            backgroundColor: Colors.green
          ),
        );
      }
    }
  }

  void _showEventForm({EventModel? existingEvent}) {
    if (existingEvent != null) {
      _titleController.text = existingEvent.title;
      _descController.text = existingEvent.description;
      _monthController.text = existingEvent.monthYear;
      _locationController.text = existingEvent.location;
      _selectedStatus = existingEvent.status;
      _existingImageUrl = existingEvent.imageUrl;
      _selectedImage = null;
      _selectedImageBytes = null;
    } else {
      _titleController.clear();
      _descController.clear();
      _monthController.clear();
      _locationController.clear();
      _selectedStatus = 'Segera';
      _existingImageUrl = "-";
      _selectedImage = null;
      _selectedImageBytes = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(existingEvent == null ? 'Tambah Kegiatan Baru' : 'Edit Kegiatan'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            var bytes = await image.readAsBytes();
                            setStateDialog(() {
                              _selectedImage = image;
                              _selectedImageBytes = bytes;
                            });
                          }
                        },
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                            image: _selectedImageBytes != null
                                ? DecorationImage(image: MemoryImage(_selectedImageBytes!), fit: BoxFit.cover)
                                : (_existingImageUrl != "-" 
                                    ? DecorationImage(image: NetworkImage(_existingImageUrl), fit: BoxFit.cover) 
                                    : null),
                          ),
                          child: (_selectedImageBytes == null && _existingImageUrl == "-")
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
                                    SizedBox(height: 8),
                                    Text('Ketuk untuk pilih foto kegiatan', style: TextStyle(color: Colors.grey)),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Nama Kegiatan')),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descController,
                        decoration: const InputDecoration(labelText: 'Deskripsi Singkat', alignLabelWithHint: true),
                        keyboardType: TextInputType.multiline, minLines: 3, maxLines: 6,
                      ),
                      const SizedBox(height: 8),
                      TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Lokasi Kegiatan')),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _monthController,
                        readOnly: true,
                        decoration: InputDecoration(
                            labelText: 'Pilih Tanggal Kegiatan',
                            suffixIcon: Icon(Icons.calendar_month, color: Theme.of(context).primaryColor)),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030),
                          );
                          if (pickedDate != null) {
                            List<String> namaBulan = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
                            List<String> namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
                            _monthController.text = "${namaHari[pickedDate.weekday - 1]}, ${pickedDate.day} ${namaBulan[pickedDate.month - 1]} ${pickedDate.year}";
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
                ElevatedButton(
                  onPressed: () => _handleSave(eventId: existingEvent?.id),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _confirmDelete(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kegiatan?'),
        content: Text('Apakah Anda yakin ingin menghapus kegiatan "${event.title}" secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              bool success = await _apiService.deleteEvent(event.id!);
              if (success) {
                _refreshData();
                if (mounted) {
                  Navigator.pop(context); Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kegiatan dihapus!'), backgroundColor: Colors.red));
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
              if (event.imageUrl != "-")
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      event.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Jika gambar gagal dimuat, widget ini akan hilang (tidak tampil kotak abu-abu besar)
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
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
          // PERUBAHAN: Hanya Admin yang bisa melihat tombol Hapus
          if (widget.isAdmin)
            TextButton(onPressed: () => _confirmDelete(event), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
          
          const Spacer(),
          
          // PERUBAHAN: Hanya Admin yang bisa melihat tombol Edit
          if (widget.isAdmin)
            TextButton(onPressed: () { Navigator.pop(context); _showEventForm(existingEvent: event); }, child: Text('Edit', style: TextStyle(color: Theme.of(context).primaryColor))),
          
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup', style: TextStyle(color: Colors.grey))),
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
          ? TextField(controller: _searchController, autofocus: true, decoration: const InputDecoration(hintText: 'Cari kegiatan...', border: InputBorder.none), onChanged: (val) => setState(() => _searchQuery = val))
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
            onPressed: () => setState(() { _isSearching = !_isSearching; if (!_isSearching) _searchQuery = ""; }),
          ),
        ],
      ),
      // PERUBAHAN: Tombol (+) hanya muncul jika isAdmin true
      floatingActionButton: widget.isAdmin 
        ? FloatingActionButton(
            onPressed: () => _showEventForm(),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null, 
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

          // === MULAI LOGIKA SORTIR TERBARU ===
          
          // 1. FUNGSI PINTAR UNTUK MEMBACA TANGGAL BAHASA INDONESIA
          DateTime parseDate(String dateStr) {
            Map<String, int> kamusBulan = {
              'Januari': 1, 'Februari': 2, 'Maret': 3, 'April': 4,
              'Mei': 5, 'Juni': 6, 'Juli': 7, 'Agustus': 8,
              'September': 9, 'Oktober': 10, 'November': 11, 'Desember': 12
            };
            try {
              List<String> parts = dateStr.replaceAll(',', '').split(' ');
              if (parts.length >= 4) {
                int day = int.parse(parts[1]);
                int month = kamusBulan[parts[2]] ?? 1;
                int year = int.parse(parts[3]);
                return DateTime(year, month, day);
              }
            } catch (e) {}
            return DateTime(2000); // Jika gagal baca, taruh di paling bawah
          }

          // 2. SORTIR KESELURUHAN DATA DARI TANGGAL TERBARU KE TERLAMA
          events.sort((a, b) {
            DateTime dateA = parseDate(a.monthYear);
            DateTime dateB = parseDate(b.monthYear);
            int dateComparison = dateB.compareTo(dateA); // Sortir Descending (Terbaru di atas)
            
            // Jika tanggalnya sama persis, prioritaskan data yang baru saja ditambahkan (ID terbesar)
            if (dateComparison == 0) {
              return (b.id ?? 0).compareTo(a.id ?? 0); 
            }
            return dateComparison;
          });

          // 3. KELOMPOKKAN PER BULAN (Otomatis urut karena data sudah disortir sebelumnya)
          Map<String, List<EventModel>> grouped = {};
          for (var e in events) {
            List<String> parts = e.monthYear.split(' ');
            String monthYear = parts.length >= 2 ? "${parts[parts.length - 2]} ${parts[parts.length - 1]}" : e.monthYear;
            if (!grouped.containsKey(monthYear)) grouped[monthYear] = [];
            grouped[monthYear]!.add(e);
          }
          // === BATAS LOGIKA SORTIR ===

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
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios, color: primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(month, style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...events.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(onTap: () => _showDetail(e), child: _buildEventCard(e)),
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
            Container(
              width: 80, height: 80, 
              decoration: BoxDecoration(
                color: Colors.grey.shade300, 
                borderRadius: BorderRadius.circular(8),
              ), 
              child: e.imageUrl == "-" 
                  ? const Icon(Icons.image, color: Colors.grey) 
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        e.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Jika gagal muat di list thumbnail, tampilkan icon default agar tidak abu-abu
                          return const Icon(Icons.image, color: Colors.grey);
                        },
                      ),
                    ),
            ),
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