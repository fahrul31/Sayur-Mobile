class ItemModel {
  final int id;
  final String name;
  final String type; // "VEGETABLE" atau "OTHERS"
  final String? photo;

  ItemModel({
    required this.id,
    required this.name,
    required this.type,
    this.photo,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      // 'photo' tidak dikirim sebagai JSON biasa jika berupa file → dikirim multipart nanti
    };
  }
}
