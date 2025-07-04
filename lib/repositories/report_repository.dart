import 'package:green_finance/data/constants/api_constants.dart';
import 'package:green_finance/data/services/api_services.dart';
import 'package:green_finance/models/report_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportRepository {
  late ApiService _api;

  Future<void> _createApiService() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    _api = ApiService(token: token);
  }

  Future<Map<String, List<ReportItemModel>>> fetchExpenses(String date) async {
    await _createApiService();

    final res = await _api.get(
      '$baseUrl/$expenses',
      queryParameters: {'date': date},
    );

    if (res.statusCode == 200 && res.data['status'] == true) {
      final List<dynamic> rawData = res.data['data'];

      final List<ReportItemModel> items =
          rawData.map((item) => ReportItemModel.fromJson(item)).toList();

      // Bagi menjadi VEGETABLE dan OTHER
      final vegetable = items.where((e) => e.itemType == 'VEGETABLE').toList();
      final other = items.where((e) => e.itemType == 'OTHER').toList();

      return {
        'VEGETABLE': vegetable,
        'OTHER': other,
      };
    } else {
      throw Exception(res.data['message'] ?? 'Gagal memuat data pengeluaran');
    }
  }

  Future<Map<String, List<ReportItemModel>>> fetchIncomes(String date) async {
    await _createApiService();
    print('$baseUrl/$incomes');
    final res = await _api.get(
      '$baseUrl/$incomes',
      queryParameters: {'date': date},
    );

    if (res.statusCode == 200 && res.data['status'] == true) {
      final List<dynamic> rawData = res.data['data'];

      final List<ReportItemModel> items =
          rawData.map((item) => ReportItemModel.fromJson(item)).toList();

      // Bagi menjadi VEGETABLE dan OTHER
      final vegetable = items.where((e) => e.itemType == 'VEGETABLE').toList();
      final other = items.where((e) => e.itemType == 'OTHER').toList();

      return {
        'VEGETABLE': vegetable,
        'OTHER': other,
      };
    } else {
      throw Exception(res.data['message'] ?? 'Gagal memuat data pemasukan');
    }
  }

  Future<ReportItemModel> getIncomeDetail(
    String itemId,
    String date,
  ) async {
    await _createApiService();
    print('$baseUrl/$incomes/$itemId');
    final res = await _api.get(
      '$baseUrl/$incomes/$itemId',
      queryParameters: {'date': date},
    );

    if (res.statusCode == 200 && res.data['status'] == true) {
      final rawData = res.data['data'];
      print(rawData);

      final ReportItemModel detailItems = ReportItemModel.fromJson(rawData);
      // print("detailItems: $detailItems");
      return detailItems;
    } else {
      throw Exception(res.data['message'] ?? 'Gagal memuat data pemasukan');
    }
  }

  Future<ReportItemModel> getExpenseDetail(
    String itemId,
    String date,
  ) async {
    await _createApiService();
    print('$baseUrl/$expenses/$itemId');
    final res = await _api.get(
      '$baseUrl/$expenses/$itemId',
      queryParameters: {'date': date},
    );

    if (res.statusCode == 200 && res.data['status'] == true) {
      final rawData = res.data['data'];
      print(rawData);

      final ReportItemModel detailItems = ReportItemModel.fromJson(rawData);

      return detailItems;
    } else {
      throw Exception(res.data['message'] ?? 'Gagal memuat data pemasukan');
    }
  }
}
