class ClientModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final DateTime? createdAt;

  ClientModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  ClientModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
