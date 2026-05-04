import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show VoidCallback, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';

class ApiService {
  final String baseUrl = "https://api.sportfinding.com";
  static VoidCallback? onUnauthorized;
  static bool _isUnauthorizedHandlingInProgress = false;
  Future<bool>? _refreshInFlight;

  /// Retrieve stored access token from SharedPreferences
  Future<String?> _getStoredToken() async {
    try {
      return await AppPreferences.getAccessToken();
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

  bool _isUnauthorized(http.Response response) => response.statusCode == 401;

  Future<void> _handleRefreshFailure() async {
    await AppPreferences.clearAuthSession();
    if (_isUnauthorizedHandlingInProgress) return;
    _isUnauthorizedHandlingInProgress = true;
    try {
      onUnauthorized?.call();
    } finally {
      // Allow future auth-expiry cycles to trigger redirect again.
      _isUnauthorizedHandlingInProgress = false;
    }
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    _refreshInFlight = () async {
      final refreshToken = await AppPreferences.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _handleRefreshFailure();
        return false;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/auth/refresh"),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(<String, dynamic>{
          "refresh_token": refreshToken,
        }),
      );

      if (response.statusCode != 200) {
        await _handleRefreshFailure();
        return false;
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        await _handleRefreshFailure();
        return false;
      }
      final map = Map<String, dynamic>.from(decoded);
      final accessToken = (map["access_token"] ?? "").toString();
      final newRefreshToken =
          (map["refresh_token"] ?? refreshToken).toString();
      final tokenType = (map["token_type"] ?? "bearer").toString();

      if (accessToken.isEmpty) {
        await _handleRefreshFailure();
        return false;
      }

      await AppPreferences.saveAuthTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        tokenType: tokenType,
      );
      return true;
    }();

    try {
      return await _refreshInFlight!;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<http.Response> _sendWithAutoRefresh({
    required Future<http.Response> Function(String? token) send,
    String? token,
  }) async {
    final firstResponse = await send(token);
    if (!_isUnauthorized(firstResponse)) {
      return firstResponse;
    }

    final refreshed = await _refreshAccessToken();
    if (!refreshed) {
      return firstResponse;
    }

    final retriedToken = token ?? await AppPreferences.getAccessToken();
    return send(retriedToken);
  }

  /// ✅ GET
  Future<dynamic> get(String endpoint, {String? token}) async {
    final url = "$baseUrl$endpoint";
    final response = await _sendWithAutoRefresh(
      token: token,
      send: (resolvedToken) async {
        final headers = await getHeaders(token: resolvedToken);
        return http.get(Uri.parse(url), headers: headers);
      },
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
    final response = await _sendWithAutoRefresh(
      token: token,
      send: (resolvedToken) async {
        final headers = await getHeaders(token: resolvedToken);
        return http.post(
          Uri.parse(url),
          headers: headers,
          body: data != null ? jsonEncode(data) : null,
        );
      },
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
    final response = await _sendWithAutoRefresh(
      token: token,
      send: (resolvedToken) async {
        final headers = await getHeaders(token: resolvedToken);
        return http.put(
          Uri.parse(url),
          headers: headers,
          body: data != null ? jsonEncode(data) : null,
        );
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update data: ${response.body}");
    }
  }

  /// ✅ PATCH
  Future<dynamic> patch(String endpoint, {dynamic data, String? token}) async {
    final url = "$baseUrl$endpoint";
    final response = await _sendWithAutoRefresh(
      token: token,
      send: (resolvedToken) async {
        final headers = await getHeaders(token: resolvedToken);
        return http.patch(
          Uri.parse(url),
          headers: headers,
          body: data != null ? jsonEncode(data) : null,
        );
      },
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
      final response = await _sendWithAutoRefresh(
        token: token,
        send: (resolvedToken) async {
          final headers = await getHeaders(token: resolvedToken);
          headers.remove("Content-Type");

          final request = http.MultipartRequest("PUT", uri);
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
                  contentType: MediaType('image', mimeType),
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
                contentType: MediaType('image', mimeType),
              ),
            );
          }

          final streamedResponse = await request.send();
          return http.Response.fromStream(streamedResponse);
        },
      );

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
  // Future<dynamic> delete(String endpoint, {String? token}) async {
  //   final url = "$baseUrl$endpoint";
  //   final headers = await getHeaders(token: token);

  //   final response = await http.delete(Uri.parse(url), headers: headers);

  //   if (response.statusCode != 200) {
  //     throw Exception("Failed to delete data: ${response.body}");
  //   }
  // }

  /// ✅ DELETE (optional JSON body — e.g. FCM device deactivation)
  Future<dynamic> delete(
    String endpoint, {
    String? token,
    Map<String, dynamic>? data,
  }) async {
    final url = "$baseUrl$endpoint";
    final response = await _sendWithAutoRefresh(
      token: token,
      send: (resolvedToken) async {
        final headers = await getHeaders(token: resolvedToken);
        return http.delete(
          Uri.parse(url),
          headers: headers,
          body: data != null ? jsonEncode(data) : null,
        );
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
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
      final response = await _sendWithAutoRefresh(
        token: token,
        send: (resolvedToken) async {
          final headers = await getHeaders(token: resolvedToken);
          final request = http.MultipartRequest("POST", uri);
          request.headers.addAll(headers);
          request.fields.addAll(fields);

          if (!kIsWeb && file != null) {
            if (await file.exists()) {
              final ext = file.path.split('.').last.toLowerCase();
              request.files.add(
                await http.MultipartFile.fromPath(
                  fileField,
                  file.path,
                  contentType: MediaType(
                    'image',
                    ext == 'jpg' ? 'jpeg' : ext,
                  ),
                ),
              );
            }
          } else if (kIsWeb && fileBytes != null && fileName != null) {
            final ext = fileName.split('.').last.toLowerCase();
            request.files.add(
              http.MultipartFile.fromBytes(
                fileField,
                fileBytes,
                filename: fileName,
                contentType: MediaType(
                  'image',
                  ext == 'jpg' ? 'jpeg' : ext,
                ),
              ),
            );
          }

          final streamedResponse = await request.send();
          return http.Response.fromStream(streamedResponse);
        },
      );

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
