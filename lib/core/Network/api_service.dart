// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:http/http.dart' as http;

// // class ApiService {
// //   final String baseUrl = " https://api.sportfinding.com";
// //   Map<String, String> getHeaders({String? token}) {
// //     return {
// //       "Content-Type": "application/json",
// //       if (token != null) "Authorization": "Bearer $token",
// //     };
// //   }

// //   /// ✅ GET
// //   Future<dynamic> get(String endpoint, {String? token}) async {
// //     final response = await http.get(
// //       Uri.parse("$baseUrl$endpoint"),
// //       headers: getHeaders(token: token),
// //     );

// //     if (response.statusCode == 200) {
// //       return jsonDecode(response.body);
// //     } else {
// //       throw Exception("Failed to load data");
// //     }
// //   }

// //   /// ✅ POST (CREATE)
// //   Future<dynamic> post(String endpoint, {dynamic data, String? token}) async {
// //     final response = await http.post(
// //       Uri.parse("$baseUrl$endpoint"),
// //       headers: getHeaders(token: token),
// //       body: jsonEncode(data),
// //     );

// //     if (response.statusCode == 201) {
// //       return jsonDecode(response.body);
// //     } else {
// //       throw Exception("Failed to create data");
// //     }
// //   }

// //   /// ✅ PUT (UPDATE)
// //   Future<dynamic> put(String endpoint, {dynamic data, String? token}) async {
// //     final response = await http.put(
// //       Uri.parse("$baseUrl$endpoint"),
// //       headers: getHeaders(token: token),
// //       body: jsonEncode(data),
// //     );

// //     if (response.statusCode == 200) {
// //       return jsonDecode(response.body);
// //     } else {
// //       throw Exception("Failed to update data");
// //     }
// //   }

// //   /// ✅ DELETE
// //   Future<void> delete(String endpoint, {String? token}) async {
// //     final response = await http.delete(
// //       Uri.parse("$baseUrl$endpoint"),
// //       headers: getHeaders(token: token),
// //     );

// //     if (response.statusCode != 200) {
// //       throw Exception("Failed to delete data");
// //     }
// //   }

// //   /// ✅ MULTIPART (Image Upload)
// //   Future<dynamic> postMultipart(
// //     String endpoint, {
// //     required Map<String, String> fields,
// //     File? file,
// //     String fileField = "image",
// //   }) async {
// //     var request = http.MultipartRequest("POST", Uri.parse("$baseUrl$endpoint"));

// //     /// 🔥 Add fields (text data)
// //     request.fields.addAll(fields);

// //     /// 🔥 Add file
// //     if (file != null) {
// //       request.files.add(
// //         await http.MultipartFile.fromPath(fileField, file.path),
// //       );
// //     }

// //     var response = await request.send();

// //     final resBody = await response.stream.bytesToString();

// //     if (response.statusCode == 200 || response.statusCode == 201) {
// //       return jsonDecode(resBody);
// //     } else {
// //       throw Exception("Image upload failed");
// //     }
// //   }
// // }
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// class ApiService {
//   /// 🔗 Base URL (Fixed: removed extra space)
//   final String baseUrl = "https://api.sportfinding.com";

//   /// 📌 Common Headers
//   Map<String, String> getHeaders({String? token, bool isMultipart = false}) {
//     final headers = <String, String>{};

//     // Do NOT set Content-Type for multipart
//     if (!isMultipart) {
//       headers["Content-Type"] = "application/json";
//       headers["Accept"] = "application/json";
//     }

//     if (token != null && token.isNotEmpty) {
//       headers["Authorization"] = "Bearer $token";
//     }

//     return headers;
//   }

//   /// 📌 Handle API Responses
//   dynamic _handleResponse(http.Response response) {
//     final statusCode = response.statusCode;
//     final responseBody = response.body.isNotEmpty
//         ? jsonDecode(response.body)
//         : null;

//     if (statusCode >= 200 && statusCode < 300) {
//       return responseBody;
//     } else {
//       throw Exception("API Error: $statusCode\nResponse: ${response.body}");
//     }
//   }

//   /// ✅ GET Request
//   Future<dynamic> get(String endpoint, {String? token}) async {
//     final response = await http.get(
//       Uri.parse("$baseUrl$endpoint"),
//       headers: getHeaders(token: token),
//     );

//     return _handleResponse(response);
//   }

//   /// ✅ POST Request (CREATE)
//   Future<dynamic> post(String endpoint, {dynamic data, String? token}) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl$endpoint"),
//       headers: getHeaders(token: token),
//       body: data != null ? jsonEncode(data) : null,
//     );

//     return _handleResponse(response);
//   }

//   /// ✅ PUT Request (UPDATE)
//   Future<dynamic> put(String endpoint, {dynamic data, String? token}) async {
//     final response = await http.put(
//       Uri.parse("$baseUrl$endpoint"),
//       headers: getHeaders(token: token),
//       body: data != null ? jsonEncode(data) : null,
//     );

//     return _handleResponse(response);
//   }

//   /// ✅ DELETE Request
//   Future<dynamic> delete(String endpoint, {String? token}) async {
//     final response = await http.delete(
//       Uri.parse("$baseUrl$endpoint"),
//       headers: getHeaders(token: token),
//     );

//     return _handleResponse(response);
//   }

//   /// ✅ MULTIPART POST (Image/File Upload)
//   Future<dynamic> postMultipart(
//     String endpoint, {
//     required Map<String, String> fields,
//     File? file,
//     String fileField = "image",
//     String? token,
//   }) async {
//     final uri = Uri.parse("$baseUrl$endpoint");

//     final request = http.MultipartRequest("POST", uri);

//     // Add headers (without Content-Type)
//     request.headers.addAll(getHeaders(token: token, isMultipart: true));

//     // Add text fields
//     request.fields.addAll(fields);

//     // Add file
//     if (file != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath(fileField, file.path),
//       );
//     }

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     return _handleResponse(response);
//   }
// }
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://api.sportfinding.com";

  Map<String, String> getHeaders({String? token, bool isMultipart = false}) {
    final headers = <String, String>{};

    if (!isMultipart) {
      headers["Content-Type"] = "application/json";
      headers["Accept"] = "application/json";
    }

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else {
      throw Exception("API Error: $statusCode\nResponse: ${response.body}");
    }
  }

  /// ✅ GET
  Future<dynamic> get(String endpoint, {String? token}) async {
    final url = "$baseUrl$endpoint";
    final response = await http.get(
      Uri.parse(url),
      headers: getHeaders(token: token),
    );
    print("Url: $url");
    print("Headers: ${response.headers}");
    print("Request: ${response.request}");
    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");
    return _handleResponse(response);
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

    return _handleResponse(response);
  }

  /// ✅ PUT
  Future<dynamic> put(String endpoint, {dynamic data, String? token}) async {
    final url = "$baseUrl$endpoint";
    final response = await http.put(
      Uri.parse(url),
      headers: getHeaders(token: token),
      body: data != null ? jsonEncode(data) : null,
    );
    print("Url: $url");
    print("Headers: ${response.headers}");
    print("Request: ${response.request}");
    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");
    return _handleResponse(response);
  }

  /// ✅ DELETE
  Future<dynamic> delete(String endpoint, {String? token}) async {
    final url = "$baseUrl$endpoint";
    final response = await http.delete(
      Uri.parse(url),
      headers: getHeaders(token: token),
    );
    print("Url: $url");
    print("Headers: ${response.headers}");
    print("Request: ${response.request}");
    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");
    return _handleResponse(response);
  }

  /// ✅ MULTIPART - Works on Web (Chrome) AND Mobile
  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    String? filePath, // 📱 Mobile only
    List<int>? fileBytes, // 🌐 Web only
    String? fileName, // 🌐 Web only
    String fileField = "image",
    String? token,
  }) async {
    final url = "$baseUrl$endpoint";
    final uri = Uri.parse(url);
    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll(getHeaders(token: token, isMultipart: true));
    request.fields.addAll(fields);

    if (kIsWeb) {
      // 🌐 WEB - use bytes (no dart:io)
      if (fileBytes != null && fileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: fileName,
          ),
        );
      }
    } else {
      // 📱 MOBILE - use file path
      if (filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, filePath),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print("Url: $url");
    print("Headers: ${request.headers}");
    print("Request: ${request.files}");
    print("Status Code: ${request.fields}");
    print("Body: ${request.contentLength}");

    return _handleResponse(response);
  }
}
