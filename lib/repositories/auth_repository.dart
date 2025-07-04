import 'package:green_finance/data/constants/api_constants.dart';
import 'package:green_finance/data/services/api_services.dart';
import 'package:green_finance/models/responses/response_model.dart';
import 'package:green_finance/models/user_model.dart';

class AuthRepository {
  final ApiService _api = ApiService();

  Future<ApiResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _api.post('$baseUrl/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });

    if (response.statusCode == 201 && response.data['status'] == true) {
      return ApiResponse.fromJson(response.data, UserModel.fromJson);
    } else {
      return ApiResponse.fromJson(response.data, (_) => null);
    }
  }

  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('$baseUrl/login', data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200 && response.data['status'] == true) {
      return ApiResponse.fromJson(response.data, UserModel.fromJson);
    } else {
      return ApiResponse.fromJson(response.data, (_) => null);
    }
  }
}
