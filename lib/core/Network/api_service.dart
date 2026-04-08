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
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load data: ${response.body}");
    }
  }

  /// ✅ POST (CREATE)
  Future<dynamic> post(String endpoint, {dynamic data, String? token}) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: getHeaders(token: token),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create data: ${response.body}");
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
      throw Exception("Failed to update data: ${response.body}");
    }
  }

  /// ✅ DELETE
  Future<void> delete(String endpoint, {String? token}) async {
    final response = await http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: getHeaders(token: token),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete data: ${response.body}");
    }
  }

  /// ✅ MULTIPART (Image Upload) - FIXED
  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? file,
    String fileField = "image",
    String? token,
  }) async {
    try {
      // ✅ Create proper URI
      final uri = Uri.parse("$baseUrl$endpoint");

      print("📤 Uploading to: $uri");
      print("📝 Fields: $fields");
      print("🖼️ File: ${file?.path}");

      // ✅ Create multipart request
      var request = http.MultipartRequest("POST", uri);

      // ✅ Add headers
      request.headers.addAll({
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      });

      // ✅ Add fields
      request.fields.addAll(fields);

      // ✅ Add file if exists
      if (file != null && await file.exists()) {
        final fileExtension = file.path.split('.').last.toLowerCase();
        final mimeType = _getMimeType(fileExtension);

        print("📎 Adding file: ${file.path}");
        print("🎨 MIME type: $mimeType");

        request.files.add(
          await http.MultipartFile.fromPath(
            fileField,
            file.path,
            // contentType: http_parser.MediaType.parse(mimeType), // Optional
          ),
        );
      } else if (file != null) {
        print("⚠️ File does not exist: ${file.path}");
      }

      // ✅ Send request
      print("🚀 Sending request...");
      var streamedResponse = await request.send();

      // ✅ Get response
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

  /// Helper: Get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
