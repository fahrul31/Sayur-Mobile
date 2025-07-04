class UserModel {
  final int id;
  final String name;
  final String email;
  final String? token; // hanya digunakan saat login
  final String? photo; // hanya ada di profile

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '', // safe fallback
      email: json['email'] ?? '',
      token: json['token'], // nullable
      photo: json['photo'], // nullable
    );
  }
}
