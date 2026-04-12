// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// class ApiService {
//   final String baseUrl = "https://api.sportfinding.com";
//   Map<String, String> getHeaders({String? token}) {
//     return {
//       "Content-Type": "application/json",
//       if (token != null) "Authorization": "Bearer $token",
//     };
//   }

//   /// ✅ GET
//   Future<dynamic> get(String endpoint, {String? token}) async {
//     final response = await http.get(
//       Uri.parse("$baseUrl$endpoint"),
//       headers: getHeaders(token: token),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception("Failed to load data");
//     }
//   }

//   /// ✅ POST (CREATE)
//   Future<dynamic> post(String endpoint, {dynamic data, String? token}) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl$endpoint"),
//       headers: getHeaders(token: token),
//       body: jsonEncode(data),
//     );

//     if (response.statusCode == 201) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception("Failed to create data");
//     }
//   }

//   /// ✅ PUT (UPDATE)
//   Future<dynamic> put(String endpoint, {dynamic data, String? token}) async {
//     final response = await http.put(
//       Uri.parse("$baseUrl$endpoint"),
//       headers: getHeaders(token: token),
//       body: jsonEncode(data),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception("Failed to update data");
//     }
//   }

//   /// ✅ DELETE
//   Future<void> delete(String endpoint, {String? token}) async {
//     final response = await http.delete(
//       Uri.parse("$baseUrl$endpoint"),
//       headers: getHeaders(token: token),
//     );

//     if (response.statusCode != 200) {
//       throw Exception("Failed to delete data");
//     }
//   }

//   /// ✅ MULTIPART (Image Upload)
//   Future<dynamic> postMultipart(
//     String endpoint, {
//     required Map<String, String> fields,
//     File? file,
//     String fileField = "image",
//   }) async {
//     var request = http.MultipartRequest("POST", Uri.parse("$baseUrl$endpoint"));

//     /// 🔥 Add fields (text data)
//     request.fields.addAll(fields);

//     /// 🔥 Add file
//     if (file != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath(fileField, file.path),
//       );
//     }

//     var response = await request.send();

//     final resBody = await response.stream.bytesToString();

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return jsonDecode(resBody);
//     } else {
//       throw Exception("Image upload failed");
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://api.sportfinding.com";

  Map<String, String> getHeaders({String? token}) {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// ✅ GET
  Future<dynamic> get(String endpoint, {String? token}) async {
    final url = "$baseUrl$endpoint";
    final response = await http.get(
      Uri.parse(url),
      headers: getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data: ${response.body}");
    }
  }

  /// ✅ POST
  Future<dynamic> post(String endpoint, {dynamic data, String? token}) async {
    final url = "$baseUrl$endpoint";
    final response = await http.post(
      Uri.parse(url),
      headers: getHeaders(token: token),
      body: data != null ? jsonEncode(data) : null,
    );
    print("Url: $url");
    print("Headers: ${response.headers}");
    print("Request: ${response.request}");
    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create data: ${response.body}");
    }
  }

  /// ✅ PUT
  Future<dynamic> put(String endpoint, {dynamic data, String? token}) async {
    final url = "$baseUrl$endpoint";
    final response = await http.put(
      Uri.parse(url),
      headers: getHeaders(token: token),
      body: data != null ? jsonEncode(data) : null,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update data: ${response.body}");
    }
  }

  /// ✅ DELETE
  Future<dynamic> delete(String endpoint, {String? token}) async {
    final url = "$baseUrl$endpoint";
    final response = await http.delete(
      Uri.parse(url),
      headers: getHeaders(token: token),
    );

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

      print("📤 Uploading to: $uri");
      print("📝 Fields: $fields");

      var request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      });

      request.fields.addAll(fields);

      // ✅ Mobile: File object
      if (!kIsWeb && file != null) {
        if (await file.exists()) {
          final ext = file.path.split('.').last.toLowerCase();
          print("📎 Adding file (mobile): ${file.path}");
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
        } else {
          print("⚠️ File does not exist: ${file.path}");
        }
      }
      // ✅ Web: bytes
      else if (kIsWeb && fileBytes != null && fileName != null) {
        final ext = fileName.split('.').last.toLowerCase();
        print("📎 Adding file (web): $fileName");
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

      print("🚀 Sending request...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📥 Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Upload failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error in postMultipart: $e");
      rethrow;
    }
  }
}
