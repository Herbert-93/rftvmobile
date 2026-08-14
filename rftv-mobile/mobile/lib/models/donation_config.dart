class PaymentMethod {
  final String id;
  final String name;
  final String sub;
  final String color; // hex string, e.g. "#FFC700"
  final bool enabled;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.sub,
    required this.color,
    required this.enabled,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        sub: json['sub'] as String? ?? '',
        color: json['color'] as String? ?? '#0A2E44',
        enabled: json['enabled'] as bool? ?? true,
      );
}

class DonationConfig {
  final List<int> presetAmounts;
  final String currency;
  final List<PaymentMethod> paymentMethods;

  DonationConfig({
    required this.presetAmounts,
    required this.currency,
    required this.paymentMethods,
  });

  factory DonationConfig.fromJson(Map<String, dynamic> json) => DonationConfig(
        presetAmounts: (json['presetAmounts'] as List? ?? [])
            .map((e) => (e as num).toInt())
            .toList(),
        currency: json['currency'] as String? ?? 'UGX',
        paymentMethods: (json['paymentMethods'] as List? ?? [])
            .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
