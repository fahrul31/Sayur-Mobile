import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final Dio _dio;

  ApiService({String? token})
      : _dio = Dio(BaseOptions(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            return status != null && status < 500;
          },
        )) {
    if (token != null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Bearer $token';
            return handler.next(options);
          },
        ),
      );
    }
  }

  Future<Response> get(String url,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Response> post(String url, {dynamic data}) async {
    try {
      final response = await _dio.post(url, data: data);
      return response;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Response> put(String url, {dynamic data}) async {
    try {
      final response = await _dio.put(url, data: data);
      return response;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Response> patch(String url, {dynamic data}) async {
    try {
      final response = await _dio.patch(url, data: data);
      return response;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Response> delete(String url) async {
    try {
      final response = await _dio.delete(url);
      return response;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Response> postMultipart(
    String url, {
    required Map<String, dynamic> fields,
    required String fileKey,
    required String filePath,
  }) async {
    try {
      final mimeType = _getMimeType(filePath); // Tambahan

      final formData = FormData.fromMap({
        ...fields,
        fileKey: await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
          contentType: MediaType.parse(mimeType), // ✅ Tambahkan ini
        ),
      });

      final response = await _dio.post(url, data: formData);
      return response;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Future<Response> putMultipart(
    String url, {
    required Map<String, dynamic> fields,
    required String fileKey,
    required String filePath,
  }) async {
    try {
      final mimeType = _getMimeType(filePath);

      final formData = FormData.fromMap({
        ...fields,
        fileKey: await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      });

      final response = await _dio.put(url, data: formData);
      return response;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  Response _handleDioException(DioException e) {
    if (e.response != null) {
      // ✅ Tetap kembalikan response dari server walau status 400
      return e.response!;
    } else {
      // ❌ Tidak ada response (misal: timeout, tidak ada koneksi)
      throw Exception('Tidak dapat terhubung ke server: ${e.message}');
    }
  }

  //handle type image
  String _getMimeType(String path) {
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream'; // default aman
  }
}
