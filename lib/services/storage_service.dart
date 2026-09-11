import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/supabase/supabase_config.dart';

/// Storage Service using Supabase Storage Buckets
class StorageService {
  final SupabaseClient _client;
  final Uuid _uuid = const Uuid();

  StorageService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  /// Upload user profile avatar
  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    try {
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'users/$userId/$fileName';

      await _client.storage.from('avatars').upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      return _client.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      debugPrint('StorageService.uploadAvatar error: $e');
      rethrow;
    }
  }

  /// Upload chat media attachment
  Future<String> uploadChatAttachment({
    required String bookingId,
    required File file,
    required String fileType,
    Function(double progress)? onProgress,
  }) async {
    try {
      final extension = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$extension';
      final path = '$bookingId/$fileName';

      onProgress?.call(0.5);

      await _client.storage.from('chat-attachments').upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      onProgress?.call(1.0);
      return _client.storage.from('chat-attachments').getPublicUrl(path);
    } catch (e) {
      debugPrint('StorageService.uploadChatAttachment error: $e');
      rethrow;
    }
  }

  /// Upload review photo
  Future<String> uploadReviewPhoto({
    required String photographerId,
    required File file,
  }) async {
    try {
      final extension = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$extension';
      final path = '$photographerId/$fileName';

      await _client.storage.from('portfolios').upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      return _client.storage.from('portfolios').getPublicUrl(path);
    } catch (e) {
      debugPrint('StorageService.uploadReviewPhoto error: $e');
      rethrow;
    }
  }

  /// Upload portfolio media directly from device (Photo / Video / Reel)
  Future<String> uploadPortfolioMedia({
    required String photographerId,
    required String filePath,
    Uint8List? fileBytes,
    String? originalFileName,
    String? mimeType,
  }) async {
    try {
      final ext = originalFileName != null && originalFileName.contains('.')
          ? originalFileName.split('.').last
          : (filePath.contains('.') ? filePath.split('.').last : 'jpg');
      final fileName = 'portfolio_${_uuid.v4()}.$ext';
      final path = '$photographerId/$fileName';

      if (kIsWeb && fileBytes != null) {
        await _client.storage.from('portfolios').uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: mimeType,
          ),
        );
      } else {
        final file = File(filePath);
        await _client.storage.from('portfolios').upload(
          path,
          file,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
            contentType: mimeType,
          ),
        );
      }

      return _client.storage.from('portfolios').getPublicUrl(path);
    } catch (e) {
      debugPrint('StorageService.uploadPortfolioMedia error: $e');
      rethrow;
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
