import 'package:green_finance/models/annual_recap_model.dart';

class RecapDetailModel {
  final List<AnnualRecapModel> summaryPerDay;
  final int totalExpense;
  final int totalIncome;
  final int totalNet;

  RecapDetailModel({
    required this.summaryPerDay,
    required this.totalExpense,
    required this.totalIncome,
    required this.totalNet,
  });

  factory RecapDetailModel.fromJson(Map<String, dynamic> json) {
    return RecapDetailModel(
      summaryPerDay: (json['summaryPerDay'] as List)
          .map((e) => AnnualRecapModel.fromJson(e))
          .toList(),
      totalExpense: json['totalExpense'],
      totalIncome: json['totalIncome'],
      totalNet: json['totalNet'],
    );
  }
}
