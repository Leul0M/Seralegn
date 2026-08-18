class WorkerModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String faydaNumber;
  final bool faydaVerified;
  final DateTime trialEndsAt;
  final DateTime? subscriptionExpiresAt;
  final int flagCount;
  final bool isSuspended;
  final DateTime? createdAt;

  WorkerModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.faydaNumber,
    this.faydaVerified = false,
    required this.trialEndsAt,
    this.subscriptionExpiresAt,
    this.flagCount = 0,
    this.isSuspended = false,
    this.createdAt,
  });

  int get daysLeft {
    final now = DateTime.now();
    final trialDays = trialEndsAt.difference(now).inDays;
    final subDays = subscriptionExpiresAt != null
        ? subscriptionExpiresAt!.difference(now).inDays
        : 0;
    
    // GREATEST equivalent
    final trialVal = trialDays > 0 ? trialDays : 0;
    final subVal = subDays > 0 ? subDays : 0;
    
    // If trial is still active, or subscription is active, return the max days left
    return trialVal > subVal ? trialVal : subVal;
  }

  bool get isSubscriptionActive {
    return daysLeft > 0;
  }

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      faydaNumber: json['fayda_number'] as String,
      faydaVerified: json['fayda_verified'] as bool? ?? false,
      trialEndsAt: DateTime.parse(json['trial_ends_at'] as String),
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
      flagCount: json['flag_count'] as int? ?? 0,
      isSuspended: json['is_suspended'] as bool? ?? false,
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
      'fayda_number': faydaNumber,
      'fayda_verified': faydaVerified,
      'trial_ends_at': trialEndsAt.toIso8601String(),
      if (subscriptionExpiresAt != null)
        'subscription_expires_at': subscriptionExpiresAt!.toIso8601String(),
      'flag_count': flagCount,
      'is_suspended': isSuspended,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  WorkerModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? faydaNumber,
    bool? faydaVerified,
    DateTime? trialEndsAt,
    DateTime? subscriptionExpiresAt,
    int? flagCount,
    bool? isSuspended,
    DateTime? createdAt,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      faydaNumber: faydaNumber ?? this.faydaNumber,
      faydaVerified: faydaVerified ?? this.faydaVerified,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      flagCount: flagCount ?? this.flagCount,
      isSuspended: isSuspended ?? this.isSuspended,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
