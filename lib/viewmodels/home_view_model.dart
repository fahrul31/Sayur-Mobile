import 'package:flutter/material.dart';
import 'package:green_finance/models/annual_recap_model.dart';
import 'package:green_finance/repositories/recap_repository.dart';
import 'package:green_finance/models/responses/response_model.dart';

class HomeViewModel extends ChangeNotifier {
  final RecapRepository recapRepository;

  HomeViewModel(this.recapRepository);

  List<AnnualRecapModel> recaps = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchAnnualRecap(int year) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final ApiResponse<List<AnnualRecapModel>> response =
          await recapRepository.fetchAnnualRecap(year);

      if (response.status) {
        recaps = response.data ?? [];
      } else {
        recaps = [];
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = 'Gagal memuat data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
