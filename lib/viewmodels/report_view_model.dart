import 'package:flutter/material.dart';
import 'package:green_finance/models/report_item_model.dart';
import 'package:green_finance/repositories/report_repository.dart';

class ReportViewModel extends ChangeNotifier {
  final ReportRepository reportRepository;

  ReportViewModel(this.reportRepository);

  bool isLoading = false;
  bool isPemasukan = true;
  Map<String, List<ReportItemModel>> reportItems = {
    'vegetables': [],
    'others': [],
  };

  Future<void> fetchData(String date) async {
    isLoading = true;
    notifyListeners();

    try {
      reportItems = isPemasukan
          ? await reportRepository.fetchIncomes(date)
          : await reportRepository.fetchExpenses(date);

      reportItems = {
        'vegetables': reportItems['VEGETABLE']!,
        'others': reportItems['OTHER']!,
      };
    } catch (e) {
      reportItems = {
        'vegetables': [],
        'others': [],
      };
      debugPrint('Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleTab(bool isIncome, String date) {
    isPemasukan = isIncome;
    fetchData(date);
  }
}
