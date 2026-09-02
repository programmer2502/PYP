class DeliverableFileModel {
  final String id;
  final String bookingId;
  final String fileName;
  final String fileUrl;
  final String fileType; // 'image', 'video', 'raw', 'zip'
  final int fileSizeBytes;
  final String? thumbnailUrl;
  final DateTime uploadedAt;

  DeliverableFileModel({
    required this.id,
    required this.bookingId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.fileSizeBytes = 0,
    this.thumbnailUrl,
    required this.uploadedAt,
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory DeliverableFileModel.fromMap(Map<String, dynamic> data, {String? id, String? bookingId}) {
    return DeliverableFileModel(
      id: id ?? data['id']?.toString() ?? '',
      bookingId: bookingId ?? data['booking_id']?.toString() ?? data['bookingId']?.toString() ?? '',
      fileName: data['file_name'] ?? data['fileName'] ?? 'file',
      fileUrl: data['file_url'] ?? data['fileUrl'] ?? '',
      fileType: data['file_type'] ?? data['fileType'] ?? 'image',
      fileSizeBytes: (data['file_size'] as num?)?.toInt() ?? (data['fileSizeBytes'] as num?)?.toInt() ?? 0,
      thumbnailUrl: data['thumbnail_url'] ?? data['thumbnailUrl'],
      uploadedAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now() 
          : (data['uploadedAt'] != null ? DateTime.tryParse(data['uploadedAt'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'booking_id': bookingId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSizeBytes,
      'created_at': uploadedAt.toIso8601String(),
    };
  }
}
