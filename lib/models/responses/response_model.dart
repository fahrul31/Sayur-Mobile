class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  // Ini static method, bukan factory
  static ApiResponse<List<T>> fromJsonList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    List<T> listData = [];
    if (json['data'] != null) {
      final rawList = json['data'] as List;
      listData =
          rawList.map((e) => fromJsonT(e as Map<String, dynamic>)).toList();
    }

    return ApiResponse<List<T>>(
      status: json['status'],
      message: json['message'],
      data: listData,
    );
  }
}
