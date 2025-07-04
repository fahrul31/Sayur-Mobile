import 'package:flutter/material.dart';
import 'package:green_finance/repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'package:green_finance/models/responses/response_model.dart';
import 'package:green_finance/utils/token_helper.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository authRepository;

  AuthViewModel(this.authRepository);

  bool isLoading = false;
  String? errorMessage;
  UserModel? currentUser;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final ApiResponse response = await authRepository.login(
        email: email,
        password: password,
      );

      if (response.status && response.data?.token != null) {
        currentUser = response.data;
        await saveToken(currentUser!.token!, const Duration(hours: 12));

        return true;
      } else {
        errorMessage = response.message;
        return false;
      }
    } catch (e) {
      errorMessage = 'Gagal login: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final ApiResponse response = await authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      if (response.status) {
        return true;
      } else {
        errorMessage = response.message;
        return false;
      }
    } catch (e) {
      errorMessage = 'Gagal login: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
