/// Typed wrapper for FastAPI responses.
///
/// BACKEND INTEGRATION: the backend phase will finalize the JSON envelope
/// (fields like `data`, `message`, pagination cursors, ...). Repositories
/// should parse payloads through [ApiResponse.fromJson] so only this file
/// changes if the envelope evolves.
class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    this.message,
    this.statusCode = 200,
  });

  final T data;
  final String? message;
  final int statusCode;

  /// [parser] converts the raw `data` JSON into [T] (e.g. a model's fromJson).
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) parser,
  ) {
    return ApiResponse<T>(
      data: parser(json['data']),
      message: json['message'] as String?,
      statusCode: json['status_code'] as int? ?? 200,
    );
  }
}

/// Placeholder for cursor-based pagination, ready for list endpoints.
/// Not used by mocks; prepared so repositories can adopt it without UI changes.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.total,
    this.nextCursor,
  });

  final List<T> items;
  final int total;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;
}
