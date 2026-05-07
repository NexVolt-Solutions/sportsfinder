import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sport_finding/core/Network/api_service.dart';

class ChatUploadRepository {
  ChatUploadRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  /// Uploads a chat attachment and returns a public URL.
  ///
  /// Backend contract can evolve; we try common response keys: `url`, `media_url`,
  /// `file_url`, `path`.
  ///
  /// Configure endpoint via `--dart-define=CHAT_UPLOAD_ENDPOINT=/api/v1/...`
  static const String _endpoint = String.fromEnvironment(
    'CHAT_UPLOAD_ENDPOINT',
    defaultValue: '/api/v1/uploads',
  );

  Future<String> upload({
    required String fileField,
    required String fileName,
    File? file,
    List<int>? bytes,
    Map<String, String>? fields,
  }) async {
    if (fileName.trim().isEmpty) {
      throw Exception('Missing attachment file name');
    }
    if (!kIsWeb && file == null) {
      throw Exception('Missing attachment file');
    }
    if (kIsWeb && (bytes == null || bytes.isEmpty)) {
      throw Exception('Missing attachment bytes');
    }

    final res = await _apiService.postMultipart(
      _endpoint,
      fields: fields ?? const <String, String>{},
      file: file,
      fileBytes: bytes,
      fileName: fileName,
      fileField: fileField,
    );

    final url = (res['url'] ??
            res['media_url'] ??
            res['file_url'] ??
            res['path'] ??
            '')
        .toString()
        .trim();
    if (url.isEmpty) {
      throw Exception('Upload succeeded but no url returned');
    }
    return url;
  }
}

