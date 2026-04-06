import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://localhost:8000";

  /// ✅ GET
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse("$baseUrl$endpoint"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data");
    }
  }

  /// ✅ POST (CREATE)
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  /// ✅ PUT (UPDATE)
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    final response = await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update data");
    }
  }

  /// ✅ DELETE
  Future<void> delete(String endpoint) async {
    final response = await http.delete(Uri.parse("$baseUrl$endpoint"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete data");
    }
  }

  /// ✅ MULTIPART (Image Upload)
  Future<void> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? file,
    String fileField = "avatar",
  }) async {
    var uri = Uri.parse("$baseUrl$endpoint");

    var request = http.MultipartRequest("POST", uri);

    // Add fields
    request.fields.addAll(fields);

    // Add file
    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );
    }

    var response = await request.send();

    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Success: $responseBody");
    } else {
      throw Exception("Error: $responseBody");
    }
  }
}
