import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sport_finding/core/Network/api_service.dart';

class ChatAttachmentUploadResult {
  const ChatAttachmentUploadResult({
    required this.mediaUrl,
    this.mimeType,
    this.fileName,
    this.sizeBytes,
  });

  final String mediaUrl;
  final String? mimeType;
  final String? fileName;
  final int? sizeBytes;
}

class ChatUploadRepository {
  ChatUploadRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

 
  Future<ChatAttachmentUploadResult> uploadDirectChatAttachment({
    required String targetUserId,
    required String fileName,
    File? file,
    List<int>? bytes,
  }) async {
    final trimmedTargetUserId = targetUserId.trim();
    if (trimmedTargetUserId.isEmpty) {
      throw Exception('Missing target user id');
    }
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
      '/api/v1/users/$trimmedTargetUserId/attachments',
      fields: const <String, String>{},
      file: file,
      fileBytes: bytes,
      fileName: fileName,
      fileField: 'file',
    );

    final mediaUrl = (res['media_url'] ?? '').toString().trim();
    if (mediaUrl.isEmpty) {
      throw Exception('Upload succeeded but no url returned');
    }

    final mimeType = res['mime_type']?.toString().trim();
    final returnedName = res['file_name']?.toString().trim();
    final sizeBytes = res['size_bytes'] is num
        ? (res['size_bytes'] as num).toInt()
        : int.tryParse('${res['size_bytes'] ?? ''}');

    return ChatAttachmentUploadResult(
      mediaUrl: mediaUrl,
      mimeType: (mimeType ?? '').isEmpty ? null : mimeType,
      fileName: (returnedName ?? '').isEmpty ? null : returnedName,
      sizeBytes: sizeBytes,
    );
  }
}

