class BatchUploadResponse {
  final bool success;
  final int insertedCount;
  final int failedCount;
  final List<String>? errors;

  BatchUploadResponse({
    required this.success,
    required this.insertedCount,
    required this.failedCount,
    this.errors,
  });

  factory BatchUploadResponse.fromJson(Map<String, dynamic> json) {
    return BatchUploadResponse(
      success: json['success'],
      insertedCount: json['inserted_count'],
      failedCount: json['failed_count'],
      errors: json['errors']?.cast<String>(),
    );
  }
}
