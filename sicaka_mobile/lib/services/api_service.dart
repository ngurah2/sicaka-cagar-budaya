import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/events';

  // GET: Mengambil semua event
  Future<List<EventModel>> fetchEvents() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => EventModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data dari database');
    }
  }

  // POST: Menambah event baru
  Future<bool> addEvent(EventModel event) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(event.toJson()),
    );
    return response.statusCode == 200;
  }

  // PUT: Mengupdate event
  Future<bool> updateEvent(int id, EventModel event) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(event.toJson()),
    );
    return response.statusCode == 200;
  }
  // DELETE: Menghapus event
  Future<bool> deleteEvent(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );
    return response.statusCode == 200;
  }
}