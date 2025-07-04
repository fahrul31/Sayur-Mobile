import 'package:flutter/material.dart';
import 'package:green_finance/models/report_item_model.dart';
import 'package:green_finance/repositories/report_repository.dart';

class ReportDetailViewModel extends ChangeNotifier {
  final ReportRepository reportRepository;

  ReportDetailViewModel(this.reportRepository);

  bool isLoading = false;

  // Gunakan hanya salah satu tergantung jenis transaksi
  ReportItemModel? detailIncomeData;
  ReportItemModel? detailExpenseData;

  Future<void> fetchDetail({
    required bool isIncome,
    required String itemId,
    required String date,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      if (isIncome) {
        detailIncomeData = await reportRepository.getIncomeDetail(itemId, date);
        print("detailIncomeData: $detailIncomeData");
        detailExpenseData = null;
      } else {
        detailExpenseData =
            await reportRepository.getExpenseDetail(itemId, date);
        print("detailExpenseData: $detailExpenseData");
        detailIncomeData = null;
      }
    } catch (e) {
      detailIncomeData = null;
      detailExpenseData = null;
      debugPrint('Error fetch detail: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
