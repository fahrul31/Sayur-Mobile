class AnnualRecapModel {
  final String? date;
  final String? month;
  final int expense;
  final int income;
  final int net;

  AnnualRecapModel({
    this.date,
    this.month,
    required this.expense,
    required this.income,
    required this.net,
  });

  factory AnnualRecapModel.fromJson(Map<String, dynamic> json) {
    return AnnualRecapModel(
      date: json['date'],
      month: json['month'],
      expense: json['expense'],
      income: json['income'],
      net: json['net'],
    );
  }
}
