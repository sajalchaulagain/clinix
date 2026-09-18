import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/config/app_config.dart';
import 'api_exception.dart';

/// Thin wrapper over [Dio] that centralises:
///   * base URL + timeouts (from [AppConfig]),
///   * auth token attachment (Firebase ID token, injected via [tokenProvider]),
///   * consistent error mapping to user-safe exceptions.
///
/// UI code must NEVER touch Dio directly — it depends on repositories, and
/// repositories use this client. While `USE_MOCK_DATA=true`, repositories do
/// not call this client at all.
class ApiClient {
  ApiClient({String? authToken}) : _authToken = authToken {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Attach the Firebase ID token so the FastAPI backend can verify it
          // (firebase-admin on the server side). Never store backend secrets here.
          final token = _authToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Current Firebase ID token, provided by the auth layer upon login.
  final String? _authToken;
  late final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _guard(() => _dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return _guard(() => _dio.post<T>(path, data: data));
  }

  Future<Response<T>> put<T>(String path, {Object? data}) {
    return _guard(() => _dio.put<T>(path, data: data));
  }

  Future<Response<T>> delete<T>(String path) {
    return _guard(() => _dio.delete<T>(path));
  }

  /// Uploads one or more images as multipart form data.
  ///
  /// Prepared for the medicine scanner. The backend will receive the files
  /// under the [fieldName] multipart key together with optional [fields].
  Future<Response<T>> uploadImages<T>(
    String path, {
    required List<XFile> images,
    String fieldName = 'images',
    Map<String, String>? fields,
  }) async {
    final formData = FormData();
    if (fields != null) formData.fields.addAll(fields.entries.map((e) => MapEntry(e.key, e.value)));
    for (final image in images) {
      formData.files.add(
        MapEntry(
          fieldName,
          await MultipartFile.fromFile(image.path, filename: image.name),
        ),
      );
    }
    return _guard(() => _dio.post<T>(path, data: formData));
  }

  /// Wraps a Dio call and normalises any error into an [AppException].
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (error) {
      throw ApiErrorMapper.map(error);
    }
  }
}
