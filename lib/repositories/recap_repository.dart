import 'package:green_finance/data/constants/api_constants.dart';
import 'package:green_finance/data/services/api_services.dart';
import 'package:green_finance/models/annual_recap_model.dart';
import 'package:green_finance/models/recap_detail_data.dart';
import 'package:green_finance/models/responses/response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecapRepository {
  late ApiService _api;

  Future<void> _createApiService() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    _api = ApiService(token: token);
  }

  Future<ApiResponse<List<AnnualRecapModel>>> fetchAnnualRecap(int year) async {
    await _createApiService();

    final res = await _api.get(
      '$baseUrl/rekaptulasi/profit',
      queryParameters: {'year': year.toString()},
    );

    if (res.statusCode == 200 && res.data['status'] == true) {
      final rawData = res.data;

      // Gunakan factory khusus yang parse list
      final apiResponse = ApiResponse.fromJsonList<AnnualRecapModel>(
        rawData,
        (json) => AnnualRecapModel.fromJson(json),
      );

      print("apiResponse: $apiResponse");

      return apiResponse;
    } else {
      throw Exception(res.data['message'] ?? 'Gagal memuat data rekapitulasi');
    }
  }

  Future<ApiResponse<RecapDetailModel>> fetchMonthlyRecap({
    required int month,
    required int year,
  }) async {
    await _createApiService();

    final res = await _api.get(
      '$baseUrl/rekaptulasi',
      queryParameters: {
        'month': month.toString(),
        'year': year.toString(),
      },
    );

    if (res.statusCode == 200 && res.data['status'] == true) {
      final apiResponse = ApiResponse<RecapDetailModel>.fromJson(
        res.data,
        (json) => RecapDetailModel.fromJson(json),
      );

      print("apiResponse: $apiResponse");
      return apiResponse;
    } else {
      throw Exception(
          res.data['message'] ?? 'Gagal memuat data rekapitulasi bulanan');
    }
  }
}
