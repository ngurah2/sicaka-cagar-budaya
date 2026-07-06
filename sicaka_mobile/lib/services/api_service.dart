import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';

class ApiService {
  // Alamat Vercel
  static const String _serverUrl = 'https://sicaka-cagar-budaya.vercel.app/api';
  
  static const String baseUrl = '$_serverUrl/events';
  static const String uploadUrl = '$_serverUrl/upload';
  static const String loginUrl = '$_serverUrl/login';

  static String? token;

  // 1. FUNGSI LOGIN
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        token = data['token']; 
        return true;
      }
    } catch (e) {
      print("Error Login: $e");
    }
    return false;
  }

  // 2. FUNGSI MENGAMBIL DATA (Diperkuat agar tidak crash)
  Future<List<EventModel>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      // Jika status bukan 200, kembalikan list kosong daripada mencoba decode data rusak
      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.map((item) => EventModel.fromJson(item)).toList();
        }
      }
      return []; 
    } catch (e) {
      print("Error Fetching: $e");
      return []; 
    }
  }

  // 3. FUNGSI TAMBAH DATA
  Future<bool> addEvent(EventModel event) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode(event.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. FUNGSI UBAH DATA
  Future<bool> updateEvent(int id, EventModel event) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode(event.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 5. FUNGSI HAPUS DATA
  Future<bool> deleteEvent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          "Authorization": "Bearer $token"
        }
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 6. FUNGSI UPLOAD GAMBAR
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      request.headers.addAll({
        "Authorization": "Bearer $token" 
      });

      Uint8List byteData = await imageFile.readAsBytes();
      
      request.files.add(http.MultipartFile.fromBytes(
        'file', byteData, filename: imageFile.name,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['image_url']; 
      }
    } catch (e) {
      print("Error Upload: $e");
    }
    return null;
  }
}