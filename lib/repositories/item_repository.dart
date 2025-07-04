import 'package:green_finance/data/constants/api_constants.dart';
import 'package:green_finance/data/services/api_services.dart';
import 'package:green_finance/models/item_model.dart';
import 'package:green_finance/models/responses/response_model.dart';
import 'package:green_finance/utils/token_helper.dart';

class ItemRepository {
  Future<ApiService> _createApiService() async {
    final token = await getToken();
    return ApiService(token: token);
  }

  Future<ApiResponse> createItemWithPhoto({
    required String name,
    required String type,
    required String photoPath,
  }) async {
    final api = await _createApiService();
    final response = await api.postMultipart(
      '$baseUrl/$items',
      fields: {'name': name, 'type': type},
      fileKey: 'photo',
      filePath: photoPath,
    );

    final data = response.data;
    if (response.statusCode == 201 && data['status'] == true) {
      return ApiResponse.fromJson(data, ItemModel.fromJson);
    } else {
      throw Exception(data['message'] ?? 'Gagal menambahkan item');
    }
  }

  Future<ApiResponse> updateItemWithPhoto({
    required int id,
    required String name,
    required String type,
    required String photoPath,
  }) async {
    final api = await _createApiService();
    final response = await api.putMultipart(
      '$baseUrl/$items/$id',
      fields: {'name': name, 'type': type},
      fileKey: 'photo',
      filePath: photoPath,
    );

    final data = response.data;
    if (response.statusCode == 200 && data['status'] == true) {
      return ApiResponse.fromJson(data, ItemModel.fromJson);
    } else {
      throw Exception(data['message'] ?? 'Gagal menambahkan item');
    }
  }

  Future<Map<String, List<ItemModel>>> getItems() async {
    final api = await _createApiService();
    final response = await api.get('$baseUrl/$items');
    final data = response.data;
    if (response.statusCode == 200 && data['status'] == true) {
      final vegetablesJson = data['data']['vegetables'] as List;
      final othersJson = data['data']['others'] as List;

      final vegetables =
          vegetablesJson.map((e) => ItemModel.fromJson(e)).toList();
      final others = othersJson.map((e) => ItemModel.fromJson(e)).toList();
      return {
        'vegetables': vegetables,
        'others': others,
      };
    } else {
      throw Exception(data['message'] ?? 'Gagal mengambil item');
    }
  }

  Future<ApiResponse> updateItem(
      int id, Map<String, dynamic> fieldsToUpdate) async {
    final api = await _createApiService();
    final response = await api.put('$baseUrl/$items/$id', data: fieldsToUpdate);
    final data = response.data;

    if (data['status'] == true) {
      return ApiResponse.fromJson(data, ItemModel.fromJson);
    } else {
      throw Exception(data['message'] ?? 'Gagal mengupdate item');
    }
  }

  Future<bool> deleteItem(int id) async {
    final api = await _createApiService();
    final response = await api.delete('$baseUrl/$items/$id');
    final data = response.data;
    print(data);

    if (data['status'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Gagal menghapus item');
    }
  }
}
