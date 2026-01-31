/// Settings model for app configuration
class AppSettings {
  final String id;
  final String key;
  final String value;
  final String? description;
  final DateTime updatedAt;

  AppSettings({
    required this.id,
    required this.key,
    required this.value,
    this.description,
    required this.updatedAt,
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] as String,
      key: map['key'] as String,
      value: map['value'] as String,
      description: map['description'] as String?,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'description': description,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Business settings configuration
class BusinessSettings {
  final String businessName;
  final String? businessAddress;
  final String? businessPhone;
  final String? businessEmail;
  final String? businessLogo;
  final String currency;
  final String currencySymbol;
  final double taxRate;
  final bool enableTax;
  final bool enableDelivery;
  final double defaultDeliveryFee;

  BusinessSettings({
    required this.businessName,
    this.businessAddress,
    this.businessPhone,
    this.businessEmail,
    this.businessLogo,
    this.currency = 'XAF',
    this.currencySymbol = 'FCFA',
    this.taxRate = 0.0,
    this.enableTax = false,
    this.enableDelivery = true,
    this.defaultDeliveryFee = 0.0,
  });

  factory BusinessSettings.fromSettingsList(List<AppSettings> settings) {
    String getValue(String key, String defaultValue) {
      return settings.where((s) => s.key == key).firstOrNull?.value ??
          defaultValue;
    }

    return BusinessSettings(
      businessName: getValue('business_name', 'Kioske'),
      businessAddress: getValue('business_address', ''),
      businessPhone: getValue('business_phone', ''),
      businessEmail: getValue('business_email', ''),
      businessLogo: getValue('business_logo', ''),
      currency: getValue('currency', 'XAF'),
      currencySymbol: getValue('currency_symbol', 'FCFA'),
      taxRate: double.tryParse(getValue('tax_rate', '0')) ?? 0.0,
      enableTax: getValue('enable_tax', 'false') == 'true',
      enableDelivery: getValue('enable_delivery', 'true') == 'true',
      defaultDeliveryFee:
          double.tryParse(getValue('default_delivery_fee', '0')) ?? 0.0,
    );
  }

  List<AppSettings> toSettingsList() {
    final now = DateTime.now();
    return [
      AppSettings(
        id: 'business_name',
        key: 'business_name',
        value: businessName,
        updatedAt: now,
      ),
      AppSettings(
        id: 'business_address',
        key: 'business_address',
        value: businessAddress ?? '',
        updatedAt: now,
      ),
      AppSettings(
        id: 'business_phone',
        key: 'business_phone',
        value: businessPhone ?? '',
        updatedAt: now,
      ),
      AppSettings(
        id: 'business_email',
        key: 'business_email',
        value: businessEmail ?? '',
        updatedAt: now,
      ),
      AppSettings(
        id: 'business_logo',
        key: 'business_logo',
        value: businessLogo ?? '',
        updatedAt: now,
      ),
      AppSettings(
        id: 'currency',
        key: 'currency',
        value: currency,
        updatedAt: now,
      ),
      AppSettings(
        id: 'currency_symbol',
        key: 'currency_symbol',
        value: currencySymbol,
        updatedAt: now,
      ),
      AppSettings(
        id: 'tax_rate',
        key: 'tax_rate',
        value: taxRate.toString(),
        updatedAt: now,
      ),
      AppSettings(
        id: 'enable_tax',
        key: 'enable_tax',
        value: enableTax.toString(),
        updatedAt: now,
      ),
      AppSettings(
        id: 'enable_delivery',
        key: 'enable_delivery',
        value: enableDelivery.toString(),
        updatedAt: now,
      ),
      AppSettings(
        id: 'default_delivery_fee',
        key: 'default_delivery_fee',
        value: defaultDeliveryFee.toString(),
        updatedAt: now,
      ),
    ];
  }
}
