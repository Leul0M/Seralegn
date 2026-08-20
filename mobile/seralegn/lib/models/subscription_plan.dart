class SubscriptionPlan {
  final String id;
  final String title;
  final int durationDays;
  final double priceEtb;
  final bool isPopular;
  final String subtitle;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.durationDays,
    required this.priceEtb,
    this.isPopular = false,
    required this.subtitle,
    required this.features,
  });

  static List<SubscriptionPlan> defaultPlans = const [
    SubscriptionPlan(
      id: 'weekly',
      title: 'Weekly Pass',
      durationDays: 7,
      priceEtb: 150,
      subtitle: '7 Days Unlimited Access',
      features: [
        'Unlimited job claims',
        'Direct client phone access',
        'Basic search listing',
      ],
    ),
    SubscriptionPlan(
      id: 'monthly',
      title: 'Monthly Pro',
      durationDays: 30,
      priceEtb: 450,
      isPopular: true,
      subtitle: '30 Days Unlimited Access',
      features: [
        'Unlimited job claims',
        '0% platform commission',
        'Top of Marketplace search',
        '24/7 Priority Addis Support',
        'SMS job dispatch alerts',
      ],
    ),
    SubscriptionPlan(
      id: 'quarterly',
      title: 'Quarterly Master',
      durationDays: 90,
      priceEtb: 1200,
      subtitle: '90 Days Unlimited Access',
      features: [
        'Unlimited job claims',
        '0% platform commission',
        'Featured verified worker badge',
        'Priority SMS & push alerts',
        'Dedicated account manager',
      ],
    ),
  ];
}

enum PaymentMethod {
  telebirr,
  cbeBirr,
  chapaCard,
}

extension PaymentMethodExtension on PaymentMethod {
  String get title {
    switch (this) {
      case PaymentMethod.telebirr:
        return 'Telebirr';
      case PaymentMethod.cbeBirr:
        return 'CBE Birr';
      case PaymentMethod.chapaCard:
        return 'Chapa Card';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.telebirr:
        return 'Ethio Telecom';
      case PaymentMethod.cbeBirr:
        return 'Commercial Bank';
      case PaymentMethod.chapaCard:
        return 'Visa/Mastercard';
    }
  }
}
