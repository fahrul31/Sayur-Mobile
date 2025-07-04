import 'package:flutter/material.dart';
import 'package:green_finance/models/report_item_model.dart';
import 'package:green_finance/repositories/income_repository.dart';

class InputIncomeViewModel extends ChangeNotifier {
  final IncomeRepository incomeRepository;

  InputIncomeViewModel(this.incomeRepository);

  List<ReportItemModel> reportItems = [];
  String itemId = '';
  bool isLoading = false;
  String errorMessage = '';

  set id(String id) {
    itemId = id;
  }

  // Fetch income data from repository
  Future<void> fetchIncomeReport() async {
    isLoading = true;
    notifyListeners(); // Notify UI for loading state

    try {
      reportItems = await incomeRepository.getIncomeData(itemId);
      errorMessage = ''; // Reset error message on success
    } catch (e) {
      reportItems = [];
      errorMessage = '$e';
      debugPrint("Error fetchIncomeReport: $e");
    } finally {
      isLoading = false;
      notifyListeners(); // Notify UI after loading is complete
    }
  }

  // Create new income report
  Future<bool> createIncomeReport({
    required List<Map<String, dynamic>> incomesDetails,
  }) async {
    try {
      final response = await incomeRepository.createIncomeReport(
        itemId: itemId,
        incomesDetails: incomesDetails,
      );
      if (response['status'] == true) {
        errorMessage = ''; // Reset error message on success
        return true;
      } else {
        errorMessage = response['message'];
      }
    } catch (e) {
      errorMessage = '$e';
      debugPrint("Error createIncomeReport: $e");
    }
    return false;
  }

  // Update an existing income report
  Future<void> updateIncomeReport({
    required String id,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      await incomeRepository.updateIncomeReport(
        id: id,
        updateData: updateData,
      );
      await fetchIncomeReport(); // Refresh the list after updating
    } catch (e) {
      debugPrint("Error updateIncomeReport: $e");
    }
  }

  // Delete an income report
  Future<void> deleteIncomeReport(String id) async {
    try {
      await incomeRepository.deleteIncomeReport(id);
      await fetchIncomeReport(); // Refresh the list after deleting
    } catch (e) {
      debugPrint("Error deleteIncomeReport: $e");
    }
  }

  Future<void> deleteIncomeDetailReport(String id) async {
    isLoading = true;
    notifyListeners(); // Notify UI for loading state
    try {
      await incomeRepository.deleteIncomeDetailReport(id);
      await fetchIncomeReport();
    } catch (e) {
      debugPrint("Error deleteIncomeReport: $e");
    }
  }
}
