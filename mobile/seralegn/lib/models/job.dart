import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum JobStatus {
  open,
  accepted,
  inProgress,
  awaitingApproval,
  completed,
  cancelled,
}

extension JobStatusExtension on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.open:
        return 'OPEN';
      case JobStatus.accepted:
        return 'ACCEPTED';
      case JobStatus.inProgress:
        return 'IN PROGRESS';
      case JobStatus.awaitingApproval:
        return 'AWAITING APPROVAL';
      case JobStatus.completed:
        return 'COMPLETED';
      case JobStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color get color {
    switch (this) {
      case JobStatus.open:
        return AppTheme.primaryTeal;
      case JobStatus.accepted:
        return const Color(0xFFF59E0B);
      case JobStatus.inProgress:
        return const Color(0xFF6366F1);
      case JobStatus.awaitingApproval:
        return const Color(0xFF10B981);
      case JobStatus.completed:
        return const Color(0xFF10B981);
      case JobStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  Color get bgColor {
    switch (this) {
      case JobStatus.open:
        return const Color(0xFFEEF2FF);
      case JobStatus.accepted:
        return const Color(0xFFFEF3C7);
      case JobStatus.inProgress:
        return const Color(0xFFEEF2FF);
      case JobStatus.awaitingApproval:
        return const Color(0xFFD1FAE5);
      case JobStatus.completed:
        return const Color(0xFFE0F2FE);
      case JobStatus.cancelled:
        return const Color(0xFFFEE2E2);
    }
  }
}

enum JobCategory {
  plumbing,
  electrical,
  repairs,
  painting,
  cleaning,
  carpentry,
  gardening,
  moving,
}

extension JobCategoryExtension on JobCategory {
  String get nameAmharic {
    switch (this) {
      case JobCategory.plumbing:
        return 'Plumbing (የቧንቧ ሥራ)';
      case JobCategory.electrical:
        return 'Electrical (የኤሌክትሪክ ሥራ)';
      case JobCategory.repairs:
        return 'Home Repairs (የቤት ጥገና)';
      case JobCategory.painting:
        return 'Painting (የቀለም ሥራ)';
      case JobCategory.cleaning:
        return 'Deep Cleaning (የፅዳት ሥራ)';
      case JobCategory.carpentry:
        return 'Carpentry (የእንጨት ሥራ)';
      case JobCategory.gardening:
        return 'Gardening (የአትክልት ሥራ)';
      case JobCategory.moving:
        return 'Moving (የዕቃ ማጓጓዝ)';
    }
  }

  String get shortTitle {
    switch (this) {
      case JobCategory.plumbing:
        return 'PLUMBING';
      case JobCategory.electrical:
        return 'ELECTRICAL';
      case JobCategory.repairs:
        return 'REPAIRS';
      case JobCategory.painting:
        return 'PAINTING';
      case JobCategory.cleaning:
        return 'CLEANING';
      case JobCategory.carpentry:
        return 'CARPENTRY';
      case JobCategory.gardening:
        return 'GARDENING';
      case JobCategory.moving:
        return 'MOVING';
    }
  }

  String get priceRange {
    switch (this) {
      case JobCategory.plumbing:
        return '300 - 1,200 ETB';
      case JobCategory.electrical:
        return '400 - 1,500 ETB';
      case JobCategory.repairs:
        return '350 - 1,000 ETB';
      case JobCategory.painting:
        return '800 - 3,000 ETB';
      case JobCategory.cleaning:
        return '500 - 2,000 ETB';
      case JobCategory.carpentry:
        return '600 - 2,500 ETB';
      case JobCategory.gardening:
        return '400 - 1,200 ETB';
      case JobCategory.moving:
        return '1,000 - 4,000 ETB';
    }
  }

  IconData get icon {
    switch (this) {
      case JobCategory.plumbing:
        return Icons.plumbing_rounded;
      case JobCategory.electrical:
        return Icons.electrical_services_rounded;
      case JobCategory.repairs:
        return Icons.build_rounded;
      case JobCategory.painting:
        return Icons.format_paint_rounded;
      case JobCategory.cleaning:
        return Icons.cleaning_services_rounded;
      case JobCategory.carpentry:
        return Icons.chair_rounded;
      case JobCategory.gardening:
        return Icons.grass_rounded;
      case JobCategory.moving:
        return Icons.local_shipping_rounded;
    }
  }

  Color get color {
    switch (this) {
      case JobCategory.plumbing:
        return const Color(0xFF3B82F6);
      case JobCategory.electrical:
        return const Color(0xFF8B5CF6);
      case JobCategory.repairs:
        return const Color(0xFFF59E0B);
      case JobCategory.painting:
        return const Color(0xFFEC4899);
      case JobCategory.cleaning:
        return const Color(0xFF10B981);
      case JobCategory.carpentry:
        return const Color(0xFFD97706);
      case JobCategory.gardening:
        return const Color(0xFF059669);
      case JobCategory.moving:
        return const Color(0xFF6366F1);
    }
  }
}

class Job {
  final String id;
  final String title;
  final String description;
  final JobCategory category;
  final double budgetEtb;
  final String neighborhood;
  final String addressDetail;
  final double latitude;
  final double longitude;
  JobStatus status;
  final String clientName;
  final String clientPhone;
  final bool isClientVerified;
  final double distanceKm;
  final String? ratingGiven;
  final String? reviewText;
  final DateTime postedAt;
  String? workerId;
  /// Supabase UUID of the client who posted this job.
  final String? clientId;
  /// Image URLs (Supabase Storage public URLs) or local file paths.
  final List<String> imagePaths;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.budgetEtb,
    required this.neighborhood,
    required this.addressDetail,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.clientName,
    required this.clientPhone,
    this.isClientVerified = true,
    required this.distanceKm,
    this.ratingGiven,
    this.reviewText,
    required this.postedAt,
    this.workerId,
    this.clientId,
    this.imagePaths = const [],
  });

  /// Deserialize a job from a Supabase row map.
  factory Job.fromMap(Map<String, dynamic> map) {
    // Parse category from string
    final catStr = (map['category'] as String? ?? 'repairs').toLowerCase();
    final category = JobCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == catStr,
      orElse: () => JobCategory.repairs,
    );

    // Parse status from string
    final statusStr = (map['status'] as String? ?? 'open').toLowerCase();
    final JobStatus status;
    switch (statusStr) {
      case 'open':       status = JobStatus.open; break;
      case 'accepted':   status = JobStatus.accepted; break;
      case 'inprogress': status = JobStatus.inProgress; break;
      case 'awaiting_approval': status = JobStatus.awaitingApproval; break;
      case 'completed':  status = JobStatus.completed; break;
      case 'cancelled':  status = JobStatus.cancelled; break;
      default:           status = JobStatus.open;
    }

    // Parse photos array (Supabase stores as text[])
    final rawPhotos = map['photos'];
    final List<String> imagePaths = rawPhotos is List
        ? rawPhotos.map((e) => e.toString()).toList()
        : <String>[];

    return Job(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: category,
      budgetEtb: double.tryParse(map['offered_price']?.toString() ?? '0') ?? 0,
      neighborhood: map['neighborhood'] as String? ?? '',
      addressDetail: map['address_detail'] as String? ?? '',
      latitude: double.tryParse(map['location_lat']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(map['location_lng']?.toString() ?? '0') ?? 0,
      status: status,
      clientName: map['client_name'] as String? ?? 'Client',
      clientPhone: map['client_phone'] as String? ?? '',
      isClientVerified: true,
      distanceKm: 0.0, // Calculated locally after fetch
      postedAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      workerId: map['worker_id'] as String?,
      clientId: map['client_id'] as String?,
      imagePaths: imagePaths,
    );
  }

  /// Serialize to a map for inserting/updating in Supabase.
  Map<String, dynamic> toMap({String? clientId}) {
    final map = <String, dynamic>{
      'title': title,
      'category': category.name.toLowerCase(),
      'description': description,
      'offered_price': budgetEtb,
      'neighborhood': neighborhood,
      'address_detail': addressDetail,
      'location_lat': latitude,
      'location_lng': longitude,
      'status': 'open',
      'client_name': clientName,
      'client_phone': clientPhone,
      'photos': imagePaths,
    };
    if (clientId != null && clientId.trim().isNotEmpty) {
      map['client_id'] = clientId.trim();
    }
    return map;
  }

  static List<Job> getSampleJobs() {
    return [
      Job(
        id: 'job-101',
        title: 'Main Circuit Breaker Tripping Frequently',
        description:
            'When switching on water heater or oven, the main breaker trips. Need certified electrician with tester to balance load & check fuse box.',
        category: JobCategory.electrical,
        budgetEtb: 1200,
        neighborhood: 'Kazanchis',
        addressDetail: 'Near UNECA, Kirkos Tower Apt 5B',
        latitude: 9.0182,
        longitude: 38.7694,
        status: JobStatus.open,
        clientName: 'Hiwot Tadesse',
        clientPhone: '+251 922 887 123',
        isClientVerified: true,
        distanceKm: 2.3,
        postedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      Job(
        id: 'job-102',
        title: 'Deep House Cleaning for 3-Bedroom Villa',
        description:
            'Need full deep cleaning including window wiping, tile scrubbing, and kitchen grease removal before guests arrive tomorrow.',
        category: JobCategory.cleaning,
        budgetEtb: 1500,
        neighborhood: 'CMC',
        addressDetail: 'CMC Michael, Villa #42',
        latitude: 9.0234,
        longitude: 38.8123,
        status: JobStatus.open,
        clientName: 'Dawit Girma',
        clientPhone: '+251 911 445 678',
        isClientVerified: true,
        distanceKm: 6.3,
        postedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Job(
        id: 'job-103',
        title: 'Repair Breaker and Sockets',
        description:
            'Power fluctuations caused socket burning in master bedroom. Socket needs full replacement and wiring check.',
        category: JobCategory.electrical,
        budgetEtb: 850,
        neighborhood: 'Bole Atlas',
        addressDetail: 'Near Atlas Hotel, St. 14',
        latitude: 9.0083,
        longitude: 38.7831,
        status: JobStatus.completed,
        clientName: 'Solomon Ayalew',
        clientPhone: '+251 912 345 678',
        isClientVerified: true,
        distanceKm: 1.1,
        ratingGiven: '5/5',
        reviewText: 'Completed reliably',
        postedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Job(
        id: 'job-104',
        title: 'Fix Kitchen Sink Pipe Leakage',
        description:
            'Kitchen sink drainage is leaking under the cabinet. Need professional plumber to inspect traps and replace seals.',
        category: JobCategory.plumbing,
        budgetEtb: 650,
        neighborhood: 'Bole Atlas',
        addressDetail: 'Bole Atlas, House #204',
        latitude: 9.0083,
        longitude: 38.7831,
        status: JobStatus.completed,
        clientName: 'Solomon Ayalew',
        clientPhone: '+251 912 345 678',
        isClientVerified: true,
        distanceKm: 1.1,
        ratingGiven: '5/5',
        reviewText: 'Completed reliably',
        postedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Job(
        id: 'job-105',
        title: 'Interior Wall Touch-Up & Painting',
        description:
            'Living room walls need plastering and touch-up coat after water seepage repair.',
        category: JobCategory.painting,
        budgetEtb: 2200,
        neighborhood: 'Megenagna',
        addressDetail: 'Near Megenagna Square, Block B',
        latitude: 9.0205,
        longitude: 38.7891,
        status: JobStatus.open,
        clientName: 'Tigist Alemu',
        clientPhone: '+251 933 221 009',
        isClientVerified: true,
        distanceKm: 3.5,
        postedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}
