import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';

class ApiService {
  // URL sudah disesuaikan dengan IP Lokal Laptop Anda untuk Demo Publik
  static const String baseUrl = 'http://172.18.199.85:8000/api/events';
  static const String uploadUrl = 'http://172.18.199.85:8000/api/upload';
  static const String loginUrl = 'http://172.18.199.85:8000/api/login';

  // VARIABEL PENYIMPAN KUNCI RAHASIA (TOKEN)
  static String? token;

  // 1. FUNGSI LOGIN
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      token = data['token']; // Simpan kunci ke dalam memori aplikasi
      return true;
    }
    return false;
  }

  // 2. FUNGSI MENGAMBIL DATA (TIDAK PERLU KUNCI - PUBLIK)
  Future<List<EventModel>> fetchEvents() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => EventModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data dari database');
    }
  }

  // 3. FUNGSI TAMBAH DATA (WAJIB KUNCI)
  Future<bool> addEvent(EventModel event) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token" // Sisipkan Kunci
      },
      body: json.encode(event.toJson()),
    );
    return response.statusCode == 200;
  }

  // 4. FUNGSI UBAH DATA (WAJIB KUNCI)
  Future<bool> updateEvent(int id, EventModel event) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token" // Sisipkan Kunci
      },
      body: json.encode(event.toJson()),
    );
    return response.statusCode == 200;
  }

  // 5. FUNGSI HAPUS DATA (WAJIB KUNCI)
  Future<bool> deleteEvent(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        "Authorization": "Bearer $token" // Sisipkan Kunci
      }
    );
    return response.statusCode == 200;
  }

  // 6. FUNGSI UPLOAD GAMBAR (WAJIB KUNCI)
  Future<String?> uploadImage(XFile imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    
    // Sisipkan Kunci di Header Multipart
    request.headers.addAll({
      "Authorization": "Bearer $token" 
    });

    Uint8List byteData = await imageFile.readAsBytes();
    List<int> bytes = byteData.cast();

    request.files.add(http.MultipartFile.fromBytes(
      'file', bytes, filename: imageFile.name,
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse['image_url']; 
    }
    return null;
  }
}