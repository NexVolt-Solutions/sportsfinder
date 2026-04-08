import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = " https://api.sportfinding.com";
  Map<String, String> getHeaders({String? token}) {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// ✅ GET
  Future<dynamic> get(String endpoint, {String? token}) async {
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data");
    }
  }

  /// ✅ POST (CREATE)
  Future<dynamic> post(String endpoint, {dynamic data, String? token}) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: getHeaders(token: token),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create data");
    }
  }

  /// ✅ PUT (UPDATE)
  Future<dynamic> put(String endpoint, {dynamic data, String? token}) async {
    final response = await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: getHeaders(token: token),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update data");
    }
  }

  /// ✅ DELETE
  Future<void> delete(String endpoint, {String? token}) async {
    final response = await http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: getHeaders(token: token),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete data");
    }
  }

  /// ✅ MULTIPART (Image Upload)
  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? file,
    String fileField = "image",
  }) async {
    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl$endpoint"));

    /// 🔥 Add fields (text data)
    request.fields.addAll(fields);

    /// 🔥 Add file
    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );
    }

    var response = await request.send();

    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(resBody);
    } else {
      throw Exception("Image upload failed");
    }
  }
}
