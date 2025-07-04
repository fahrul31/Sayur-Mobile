import 'package:green_finance/models/report_detail_model.dart';

class ReportItemModel {
  final int itemId;
  final String? itemName;
  final String? itemType;
  final String? type;
  final double? totalQuantityKg;
  final int totalPrice;
  final String? note;
  final String? createdAt;
  final List<ReportDetailModel>? details;

  ReportItemModel({
    required this.itemId,
    required this.itemName,
    required this.itemType,
    this.type,
    this.totalQuantityKg,
    required this.totalPrice,
    this.note,
    this.createdAt,
    this.details,
  });

  factory ReportItemModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> detailListDynamic = json['details'] ?? [];

    final List<ReportDetailModel> detailList = detailListDynamic
        .map((e) => ReportDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (json['totalQuantityKg'] == null || json['totalQuantityKg'] == 0) {
      json['totalQuantityKg'] = 0.0;
    }
    return ReportItemModel(
      itemId: json['itemId'],
      itemName: json['itemName'],
      itemType: json['itemType'],
      type: json['type'],
      totalQuantityKg: (json['totalQuantityKg'] as num?)?.toDouble() ?? 0,
      totalPrice: json['totalPrice'] ?? 0,
      note: json['note'],
      createdAt: json['createdAt'],
      details: detailList,
    );
  }

  factory ReportItemModel.fromJsonInput(Map<String, dynamic> json) {
    final List<dynamic> detailListDynamic = json['details'] ?? [];

    final List<ReportDetailModel> detailList = detailListDynamic
        .map((e) => ReportDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (json['totalQuantityKg'] == null || json['totalQuantityKg'] == 0) {
      json['totalQuantityKg'] = 0.0;
    }
    return ReportItemModel(
      itemId: json['id'],
      itemName: json['itemName'],
      itemType: json['itemType'],
      type: json['type'],
      totalQuantityKg: (json['totalQuantityKg'] as num).toDouble(),
      totalPrice: json['totalPrice'] ?? 0,
      note: json['note'],
      createdAt: json['createdAt'],
      details: detailList,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'itemType': itemType,
        'type': type,
        'totalQuantityKg': totalQuantityKg,
        'totalPrice': totalPrice,
        'note': note,
      };

  Map<String, dynamic> toJsonInput() => {
        'id': itemId,
        'itemName': itemName,
        'itemType': itemType,
        'type': type,
        'totalQuantityKg': totalQuantityKg,
        'totalPrice': totalPrice,
        'note': note,
      };
}
