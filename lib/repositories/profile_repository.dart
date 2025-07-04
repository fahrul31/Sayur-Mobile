import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:green_finance/data/constants/api_constants.dart';
import 'package:green_finance/data/services/api_services.dart';
import 'package:green_finance/models/user_model.dart';
import 'package:green_finance/models/responses/response_model.dart';
import 'package:green_finance/utils/token_helper.dart';

class ProfileRepository {
  Future<ApiService> _createApiService() async {
    final token = await getToken();
    return ApiService(token: token);
  }

  /// GET /profile - Get current user profile
  Future<ApiResponse> getProfile() async {
    final api = await _createApiService();
    final response = await api.get('$baseUrl/profile');

    if (response.statusCode == 200 && response.data['status'] == true) {
      return ApiResponse.fromJson(response.data, UserModel.fromJson);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch profile');
    }
  }

  /// PUT /profile - Update name, email, photo
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    File? photoFile,
  }) async {
    final api = await _createApiService();

    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      if (photoFile != null)
        'photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
    });

    final response = await api.put('$baseUrl/profile', data: formData);

    // Pastikan response.data berupa Map
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;

      print("API updateProfile response: $data");

      final status = data['status'];
      final message = data['message'];

      return {
        "status": status,
        "message": message,
      };
    } else {
      print("⚠️ Response bukan Map<String, dynamic>: ${response.data}");
      return {
        "status": false,
        "message": 'Response tidak valid dari server',
      };
    }
  }

  /// PATCH /profile - Update password only
  Future<Map<String, dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final api = await _createApiService();

    final response = await api.patch('$baseUrl/profile', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });

    final data = response.data;
    return {
      "status": data['status'],
      "message": data['message'],
    };
  }
}
