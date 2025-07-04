import 'package:green_finance/data/constants/api_constants.dart';
import 'package:green_finance/data/services/api_services.dart';
import 'package:green_finance/models/report_item_model.dart';
import 'package:green_finance/models/responses/response_model.dart';
import 'package:green_finance/utils/token_helper.dart';

class IncomeRepository {
  Future<ApiService> _createApiService() async {
    final token = await getToken();
    return ApiService(token: token);
  }

  // Fetch all income report items
  Future<List<ReportItemModel>> getIncomeData(String id) async {
    final api = await _createApiService();
    final response = await api.get('$baseUrl/$incomes/all/$id');
    final data = response.data;
    print(data);
    if (response.statusCode == 200 && data['status'] == true) {
      final incomeItemsJson = data['data']['items'] as List;
      return incomeItemsJson
          .map((item) => ReportItemModel.fromJsonInput(item))
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch income data');
    }
  }

  // Create a new income report item
  Future<Map<String, dynamic>> createIncomeReport({
    required String itemId,
    required List<Map<String, dynamic>> incomesDetails,
  }) async {
    final api = await _createApiService();
    final response = await api.post(
      '$baseUrl/incomes',
      data: {
        'itemId': int.parse(itemId),
        'incomesDetails': incomesDetails,
      },
    );

    print({
      'itemId': itemId,
      'incomesDetails': incomesDetails,
    });

    final data = response.data;
    print(data);
    if (response.statusCode == 201 && data['status'] == true) {
      return {
        "status": data['status'],
        "message": data['message'],
      };
    } else {
      return {
        "status": data['status'],
        "message": data['message'],
      };
    }
  }

  // Update an existing income report item
  Future<ApiResponse> updateIncomeReport({
    required String id,
    required Map<String, dynamic> updateData,
    String? note,
  }) async {
    final api = await _createApiService();
    final response = await api.put(
      '$baseUrl/incomes/detail/$id',
      data: {
        'itemName': updateData['itemName'],
        'buyerName': updateData['buyerName'],
        'quantityKg': updateData['quantityKg'],
        'pricePerKg': updateData['pricePerKg'],
        'note': updateData['note'],
      },
    );

    print({
      'itemName': updateData['itemName'],
      'buyerName': updateData['buyerName'],
      'totalQuantityKg': updateData['quantityKg'],
      'totalPrice': updateData['pricePerKg'],
      'note': updateData['note'],
    });

    final data = response.data;
    print(data);
    if (response.statusCode == 200 && data['status'] == true) {
      return ApiResponse.fromJson(data, ReportItemModel.fromJson);
    } else {
      throw Exception(data['message'] ?? 'Failed to update income report');
    }
  }

  // Delete an income report item
  Future<bool> deleteIncomeReport(String id) async {
    final api = await _createApiService();
    final response = await api.delete('$baseUrl/incomes/$id');
    final data = response.data;

    if (data['status'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to delete income report');
    }
  }

  // Delete an income report item
  Future<bool> deleteIncomeDetailReport(String id) async {
    final api = await _createApiService();
    final response = await api.delete('$baseUrl/incomes/detail/$id');
    final data = response.data;

    if (data['status'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to delete income report');
    }
  }
}
