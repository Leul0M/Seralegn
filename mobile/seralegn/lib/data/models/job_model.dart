class JobModel {
  final String id;
  final String clientId;
  final String? workerId;
  final String title;
  final String category;
  final String? description;
  final double offeredPrice;
  final String
  status; // 'open', 'claimed', 'in_progress', 'pending_confirmation', 'completed', 'cancelled'
  final double? locationLat;
  final double? locationLng;
  final DateTime? createdAt;
  final DateTime? claimedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  JobModel({
    required this.id,
    required this.clientId,
    this.workerId,
    required this.title,
    required this.category,
    this.description,
    required this.offeredPrice,
    this.status = 'open',
    this.locationLat,
    this.locationLng,
    this.createdAt,
    this.claimedAt,
    this.startedAt,
    this.completedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      workerId: json['worker_id'] as String?,
      title: json['title'] as String? ?? 'Gig Service',
      category: json['category'] as String,
      description: json['description'] as String?,
      offeredPrice: (json['offered_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'open',
      locationLat: (json['location_lat'] as num?)?.toDouble(),
      locationLng: (json['location_lng'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      claimedAt: json['claimed_at'] != null
          ? DateTime.parse(json['claimed_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'worker_id': workerId,
      'title': title,
      'category': category,
      'description': description,
      'offered_price': offeredPrice,
      'status': status,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (claimedAt != null) 'claimed_at': claimedAt!.toIso8601String(),
      if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }

  JobModel copyWith({
    String? id,
    String? clientId,
    String? workerId,
    String? title,
    String? category,
    String? description,
    double? offeredPrice,
    String? status,
    double? locationLat,
    double? locationLng,
    DateTime? createdAt,
    DateTime? claimedAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      workerId: workerId ?? this.workerId,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      status: status ?? this.status,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      createdAt: createdAt ?? this.createdAt,
      claimedAt: claimedAt ?? this.claimedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
