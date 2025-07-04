import 'package:green_finance/data/constants/api_constants.dart';
import 'package:green_finance/data/services/api_services.dart';
import 'package:green_finance/models/item_model.dart';
import 'package:green_finance/utils/token_helper.dart';

class LovItemRepository {
  Future<ApiService> _createApiService() async {
    final token = await getToken();
    return ApiService(token: token);
  }

  Future<List<ItemModel>> fetchLovItems() async {
    final api = await _createApiService();
    final response = await api.get('$baseUrl/lov-items');
    final data = response.data;
    print(data);

    if (response.statusCode == 200 && data['status'] == true) {
      final List itemsJson = data['data'];
      return itemsJson.map((e) => ItemModel.fromJson(e)).toList();
    } else {
      throw Exception(data['message'] ?? 'Gagal mengambil data item LOV');
    }
  }
}
