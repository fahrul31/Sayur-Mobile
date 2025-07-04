import 'dart:io';
import 'package:flutter/material.dart';
import 'package:green_finance/models/user_model.dart';
import 'package:green_finance/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository profileRepository;

  ProfileViewModel(this.profileRepository);

  UserModel? user;
  bool isLoading = false;
  String successMessage = '';

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    _setLoading(true);
    try {
      final response = await profileRepository.getProfile();
      if (response.status) {
        user = response.data;
        errorMessage = '';
      } else {
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = 'Gagal memuat profil: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    File? photo,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await profileRepository.updateProfile(
        name: name,
        email: email,
        photoFile: photo,
      );
      if (response['status'] == true) {
        await fetchProfile();
        successMessage = response['message'] ?? 'Profil berhasil diperbarui';
        errorMessage = ''; // reset error
        return {
          'status': true,
          'message': response["message"],
        };
      }
      errorMessage = response['message']?.toString().trim().isNotEmpty == true
          ? response['message']
          : 'Terjadi kesalahan saat memperbarui profil';
      notifyListeners();
      return {
        'status': false,
        'message': response["message"],
      };
    } catch (e) {
      errorMessage = 'Gagal memperbarui profil: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
    return {
      'status': false,
      'message': errorMessage,
    };
  }

  Future<Map<String, dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await profileRepository.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      print(
          'API updatePassword response: ${response["message"]}'); // ✅ Debug log

      if (response['status'] == true) {
        successMessage = response['message'] ?? 'Profil berhasil diperbarui';
        return {
          'status': true,
          'message': response["message"],
        };
      }
      errorMessage = response['message']?.toString().trim().isNotEmpty == true
          ? response['message']
          : 'Terjadi kesalahan saat memperbarui profil';
      notifyListeners();
      return {
        'status': false,
        'message': response["message"],
      };
    } catch (e) {
      errorMessage = 'Gagal memperbarui profil: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
    return {
      'status': false,
      'message': errorMessage,
    };
  }

  void _setLoading(bool value) {
    isLoading = value;
    errorMessage = '';
    successMessage = '';
    notifyListeners();
  }
}
