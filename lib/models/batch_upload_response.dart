class BatchUploadResponse {

  BatchUploadResponse({
    required this.success,
    required this.insertedCount,
    required this.failedCount,
    this.errors,
  });

  factory BatchUploadResponse.fromJson(Map<String, dynamic> json) {
    return BatchUploadResponse(
      success: json['success'] as bool,
      insertedCount: json['inserted_count'] as int,
      failedCount: json['failed_count'] as int,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
    );
  }
  final bool success;
  final int insertedCount;
  final int failedCount;
  final List<String>? errors;
}
