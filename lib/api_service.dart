import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<Map<String, String>> _headers() async {
    return {
      'Content-Type': 'application/json',
    };
  }

  Future<List<dynamic>> getData(String endpoint) async {
    final res = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) return json.decode(res.body);
    throw Exception('GET failed: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> postData(String endpoint, Map data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _headers(),
      body: json.encode(data),
    );
    if (res.statusCode == 200 || res.statusCode == 201) return json.decode(res.body);
    throw Exception('POST failed: ${res.statusCode}');
  }

  Future<void> deleteData(String endpoint) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: await _headers(),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('DELETE failed: ${res.statusCode}');
    }
  }
}