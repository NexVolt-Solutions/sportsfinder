import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://api.sportfinding.com";

  /// Retrieve stored access token from SharedPreferences
  Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        return null;
      }
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Build headers with optional token
  /// If no token is provided, tries to retrieve it from SharedPreferences
  Future<Map<String, String>> getHeaders({String? token}) async {
    final finalToken = token ?? await _getStoredToken();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (finalToken != null) "Authorization": "Bearer $finalToken",
    };
  }

  /// ✅ GET
  Future<dynamic> get(String endpoint, {String? token}) async {
    final url = "$baseUrl$endpoint";
    final headers = await getHeaders(token: token);

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data: ${response.body}");
    }
  }

  /// ✅ POST
  Future<dynamic> post(String endpoint, {dynamic data, String? token}) async {
    final url = "$baseUrl$endpoint";
    final headers = await getHeaders(token: token);

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: data != null ? jsonEncode(data) : null,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create data: ${response.body}");
    }
  }

  /// ✅ PUT
  Future<dynamic> put(String endpoint, {dynamic data, String? token}) async {
    final url = "$baseUrl$endpoint";
    final headers = await getHeaders(token: token);

    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: data != null ? jsonEncode(data) : null,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update data: ${response.body}");
    }
  }

  /// ✅ PUT MULTIPART (Profile Update with optional image)
  Future<Map<String, dynamic>> putMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? file,
    List<int>? fileBytes,
    String? fileName,
    String fileField = "avatar",
    String? token,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl$endpoint");
      final headers = await getHeaders(token: token);

      headers.remove("Content-Type");

      var request = http.MultipartRequest("PUT", uri);
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (!kIsWeb && file != null) {
        if (await file.exists()) {
          final ext = file.path.split('.').last.toLowerCase();
          final mimeType = ext == 'jpg' ? 'jpeg' : ext;
          request.files.add(
            await http.MultipartFile.fromPath(
              fileField,
              file.path,
              contentType: http.MediaType('image', mimeType),
            ),
          );
        }
      } else if (kIsWeb && fileBytes != null && fileName != null) {
        final ext = fileName.split('.').last.toLowerCase();
        final mimeType = ext == 'jpg' ? 'jpeg' : ext;
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName,
            contentType: http.MediaType('image', mimeType),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to update: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ DELETE
  Future<dynamic> delete(String endpoint, {String? token}) async {
    final url = "$baseUrl$endpoint";
    final headers = await getHeaders(token: token);

    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      throw Exception("Failed to delete data: ${response.body}");
    }
  }

  /// ✅ MULTIPART (Image Upload) - FIXED
  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? file,
    List<int>? fileBytes,
    String? fileName,
    String fileField = "image",
    String? token,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl$endpoint");
      final headers = await getHeaders(token: token);

      var request = http.MultipartRequest("POST", uri);

      request.headers.addAll(headers);

      request.fields.addAll(fields);

      // ✅ Mobile: File object
      if (!kIsWeb && file != null) {
        if (await file.exists()) {
          final ext = file.path.split('.').last.toLowerCase();
          request.files.add(
            await http.MultipartFile.fromPath(
              fileField,
              file.path,
              contentType: http.MediaType(
                'image',
                ext == 'jpg' ? 'jpeg' : ext,
              ), // ✅ FIXED
            ),
          );
        }
      }
      // ✅ Web: bytes
      else if (kIsWeb && fileBytes != null && fileName != null) {
        final ext = fileName.split('.').last.toLowerCase();
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName,
            contentType: http.MediaType(
              'image',
              ext == 'jpg' ? 'jpeg' : ext,
            ), // ✅ FIXED
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Upload failed: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
