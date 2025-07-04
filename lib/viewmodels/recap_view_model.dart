import 'package:flutter/material.dart'; // nanti buat file ini berisi RecapDetailData & SummaryPerDay
import 'package:green_finance/models/recap_detail_data.dart';
import 'package:green_finance/repositories/recap_repository.dart';

class RecapDetailViewModel extends ChangeNotifier {
  final RecapRepository recapRepository;

  RecapDetailViewModel(this.recapRepository);

  bool isLoading = false;

  RecapDetailModel? recapDetailData;

  Future<void> fetchRecapDetail({
    required int month,
    required int year,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await recapRepository.fetchMonthlyRecap(
        month: month,
        year: year,
      );

      print("response: $response");

      if (response.status) {
        recapDetailData = response.data;
      } else {
        recapDetailData = null;
        throw Exception(response.message);
      }
    } catch (e) {
      recapDetailData = null;
      debugPrint('Error fetch recap detail: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
