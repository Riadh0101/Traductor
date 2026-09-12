class SubscriptionPlan {
  final String id;
  final String title;
  final String priceString;
  final String subPriceString;
  final String? badge;
  final bool isPopular;
  final bool isLifetime;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.priceString,
    required this.subPriceString,
    this.badge,
    this.isPopular = false,
    this.isLifetime = false,
  });

  static const List<SubscriptionPlan> defaultPlans = [
    SubscriptionPlan(
      id: 'traductor_pro_annual',
      title: 'Annual Plan (سنوي)',
      priceString: r'$19.99 / year',
      subPriceString: r'Just $1.66/month (3 days free trial)',
      badge: 'Best Value • Save 50%',
      isPopular: true,
      isLifetime: false,
    ),
    SubscriptionPlan(
      id: 'traductor_pro_monthly',
      title: 'Monthly Plan (شهري)',
      priceString: r'$2.99 / month',
      subPriceString: 'Flexible, cancel anytime',
      isPopular: false,
      isLifetime: false,
    ),
    SubscriptionPlan(
      id: 'traductor_pro_lifetime',
      title: 'Lifetime Access (مدى الحياة)',
      priceString: r'$29.99 one-time',
      subPriceString: 'Pay once, unlock forever',
      badge: 'One-Time Payment',
      isPopular: false,
      isLifetime: true,
    ),
  ];
}
