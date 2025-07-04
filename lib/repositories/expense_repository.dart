import 'package:green_finance/data/constants/api_constants.dart';
import 'package:green_finance/data/services/api_services.dart';
import 'package:green_finance/models/report_item_model.dart';
import 'package:green_finance/models/responses/response_model.dart';
import 'package:green_finance/utils/token_helper.dart';

class ExpenseRepository {
  Future<ApiService> _createApiService() async {
    final token = await getToken();
    return ApiService(token: token);
  }

  // Fetch all Expense report items
  Future<List<ReportItemModel>> getExpenseData(String id) async {
    final api = await _createApiService();
    final response = await api.get('$baseUrl/$expenses/all/$id');
    print('$baseUrl/$expenses/all/$id');
    final data = response.data;
    print(data);
    if (response.statusCode == 200 && data['status'] == true) {
      final ExpenseItemsJson = data['data']['items'] as List;
      return ExpenseItemsJson.map((item) => ReportItemModel.fromJsonInput(item))
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch Expense data');
    }
  }

  // Create a new Expense report item
  Future<Map<String, dynamic>> createExpenseVegetableReport({
    required String itemId,
    required String type,
    required List<Map<String, dynamic>> vegetableDetails,
  }) async {
    final api = await _createApiService();
    final response = await api.post(
      '$baseUrl/Expenses',
      data: {
        'itemId': int.parse(itemId),
        'type': type,
        'vegetableDetails': vegetableDetails,
      },
    );

    print({
      'itemId': itemId,
      'type': type,
      'vegetableDetails': vegetableDetails,
    });

    final data = response.data;
    print(data);
    return {
      "status": data['status'],
      "message": data['message'],
    };
  }

  // Create a new Expense report item
  Future<Map<String, dynamic>> createExpenseOtherReport({
    required String itemId,
    required String type,
    required Map<String, dynamic> otherDetails,
  }) async {
    final api = await _createApiService();
    final response = await api.post(
      '$baseUrl/Expenses',
      data: {
        'itemId': int.parse(itemId),
        'type': type,
        if (otherDetails['note'] != null) 'note': otherDetails['note'],
        'total': otherDetails['total'],
      },
    );

    print({
      'itemId': int.parse(itemId),
      'type': type,
      'note': otherDetails['note'],
      'total': otherDetails['total'],
    });

    final data = response.data;
    print(data);

    return {
      "status": data['status'],
      "message": data['message'],
    };
  }

  // Update an existing Expense report item
  Future<ApiResponse> updateExpenseReport({
    required String id,
    required Map<String, dynamic> updateData,
    String? note,
  }) async {
    final api = await _createApiService();
    final response = await api.put(
      '$baseUrl/expenses/$id',
      data: {
        'farmerName': updateData['farmerName'],
        'phone': updateData['phone'],
        'address': updateData['address'],
        'quantityKg': updateData['quantityKg'],
        'pricePerKg': updateData['pricePerKg']
      },
    );

    print({
      'id': id,
      'farmerName': updateData['farmerName'],
      'phone': updateData['phone'],
      'address': updateData['address'],
      'totalQuantityKg': updateData['quantityKg'],
      'totalPrice': updateData['pricePerKg'],
    });

    final data = response.data;
    print(data);
    if (response.statusCode == 200 && data['status'] == true) {
      return ApiResponse.fromJson(data, ReportItemModel.fromJson);
    } else {
      throw Exception(data['message'] ?? 'Failed to update Expense report');
    }
  }

  // Delete an Expense report item
  Future<bool> deleteExpenseReport(String id) async {
    final api = await _createApiService();
    final response = await api.delete('$baseUrl/Expenses/$id');
    final data = response.data;

    if (data['status'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to delete Expense report');
    }
  }

  // Delete an Expense report item
  Future<bool> deleteExpenseDetailReport(String id) async {
    final api = await _createApiService();
    final response = await api.delete('$baseUrl/expenses/detail/$id');
    final data = response.data;

    if (data['status'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to delete Expense report');
    }
  }
}
