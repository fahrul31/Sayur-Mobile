import 'package:flutter/material.dart';
import 'package:green_finance/models/report_item_model.dart';
import 'package:green_finance/repositories/Expense_repository.dart';

class InputExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository expenseRepository;

  InputExpenseViewModel(this.expenseRepository);

  List<ReportItemModel> reportItems = [];
  String itemId = '';
  bool isLoading = false;
  String _type = '';
  String errorMessage = '';
  bool isUpdating = false;

  set id(String id) {
    itemId = id;
    notifyListeners();
  }

  set type(String type) {
    _type = type;
    notifyListeners();
  }

  String get type => _type;

  // Fetch Expense data from repository
  Future<void> fetchExpenseReport() async {
    isLoading = true;
    notifyListeners(); // Notify UI for loading state

    try {
      reportItems = await expenseRepository.getExpenseData(itemId);
      errorMessage = ''; // Reset error message on success
      print("reportItems: $reportItems");
    } catch (e) {
      reportItems = [];
      errorMessage = 'Failed to fetch Expense data: $e';
      debugPrint("Error fetchExpenseReport: $e");
    } finally {
      isLoading = false;
      notifyListeners(); // Notify UI after loading is complete
    }
  }

  // Create new Expense report
  Future<bool> createExpenseVegetableReport({
    required List<Map<String, dynamic>> expensesDetails,
  }) async {
    try {
      final response = await expenseRepository.createExpenseVegetableReport(
        itemId: itemId,
        type: _type,
        vegetableDetails: expensesDetails,
      );

      if (response['status'] == true) {
        errorMessage = ''; // Reset error message on success
        return true;
      } else {
        errorMessage = response['message'];
        print("errorMessage: $errorMessage");
      }
    } catch (e) {
      debugPrint("Error createExpenseReport: $e");
    }
    return false;
  }

  Future<bool> createExpenseOtherReport({
    required Map<String, dynamic> expensesDetails,
  }) async {
    try {
      final response = await expenseRepository.createExpenseOtherReport(
        itemId: itemId,
        type: _type,
        otherDetails: expensesDetails,
      );

      if (response['status'] == true) {
        errorMessage = ''; // Reset error message on success
        return true;
      } else {
        errorMessage = response['message'];
      }
    } catch (e) {
      debugPrint("Error createExpenseReport: $e");
    }
    return false;
  }

  // Update an existing Expense report
  Future<void> updateExpenseReport({
    required String id,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      await expenseRepository.updateExpenseReport(
        id: id,
        updateData: updateData,
      );
      await fetchExpenseReport(); // Refresh the list after updating
    } catch (e) {
      debugPrint("Error updateExpenseReport: $e");
    }
  }

  // Update an existing Expense report
  Future<void> deleteExpenseDetailReport({
    required String id,
  }) async {
    isLoading = true;
    notifyListeners(); // Notify UI for loading state
    try {
      await expenseRepository.deleteExpenseDetailReport(id);
      await fetchExpenseReport(); // Refresh the list after updating
    } catch (e) {
      debugPrint("Error updateExpenseReport: $e");
    }
  }

  // Delete an Expense report

  Future<void> deleteExpenseReport(String id) async {
    try {
      await expenseRepository.deleteExpenseReport(id);
      await fetchExpenseReport(); // Refresh the list after deleting
    } catch (e) {
      debugPrint("Error deleteExpenseReport: $e");
    }
  }
}
