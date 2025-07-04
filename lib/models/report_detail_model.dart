class ReportDetailModel {
  final int id;
  final String? buyerName;
  final String? farmerName;
  final String? phone;
  final String? address;
  final int? totalQuantityKg;
  final double? quantityKg;
  final int? pricePerKg;
  final int? totalPrice;
  final String? note;

  ReportDetailModel({
    required this.id,
    this.buyerName,
    this.farmerName,
    this.phone,
    this.address,
    this.totalQuantityKg,
    this.quantityKg,
    this.pricePerKg,
    this.totalPrice,
    this.note,
  });

  factory ReportDetailModel.fromJson(Map<String, dynamic> json) {
    if (json['totalQuantityKg'] == null) {
      json['totalQuantityKg'] = 0;
    }

    if (json['quantityKg'] == null) {
      json['quantityKg'] = 0;
    }

    return ReportDetailModel(
      id: json['id'],
      buyerName: json['buyerName'],
      farmerName: json['farmerName'],
      phone: json['phone'],
      address: json['address'],
      totalQuantityKg: json['totalQuantityKg'],
      quantityKg: (json['quantityKg'] as num).toDouble(),
      pricePerKg: json['pricePerKg'] ?? 0,
      totalPrice: json['totalPrice'] ?? 0,
      note: json['note'],
    );
  }
}
