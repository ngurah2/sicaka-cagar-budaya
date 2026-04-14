import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/events';
  static const String uploadUrl = 'http://127.0.0.1:8000/api/upload';

  Future<List<EventModel>> fetchEvents() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => EventModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data dari database');
    }
  }

  Future<bool> addEvent(EventModel event) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(event.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> updateEvent(int id, EventModel event) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(event.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteEvent(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }

  // FUNGSI BARU: MENGIRIM GAMBAR KE PYTHON
  Future<String?> uploadImage(XFile imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    
    // Karena Anda menggunakan Chrome (Web), file harus diubah jadi Bytes
    Uint8List byteData = await imageFile.readAsBytes();
    List<int> bytes = byteData.cast();

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: imageFile.name,
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse['image_url']; // Link gambar dari server
    }
    return null;
  }
}