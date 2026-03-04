import 'package:intl/intl.dart';

enum AppCurrency {
  eur(symbol: '€', locale: 'de_DE', label: 'EUR', decimals: 2),
  usd(symbol: '\$', locale: 'en_US', label: 'USD', decimals: 2),
  gbp(symbol: '£', locale: 'en_GB', label: 'GBP', decimals: 2),
  jpy(symbol: '¥', locale: 'ja_JP', label: 'JPY', decimals: 0),
  chf(symbol: 'CHF', locale: 'de_CH', label: 'CHF', decimals: 2);

  final String symbol;
  final String locale;
  final String label;
  final int decimals;

  const AppCurrency({
    required this.symbol,
    required this.locale,
    required this.label,
    required this.decimals,
  });
}

class CurrencyFormatter {
  final NumberFormat _full;
  final NumberFormat _compact;

  CurrencyFormatter(AppCurrency currency)
      : _full = NumberFormat.currency(
          locale: currency.locale,
          symbol: currency.symbol,
          decimalDigits: currency.decimals,
        ),
        _compact = NumberFormat.compactCurrency(
          locale: currency.locale,
          symbol: currency.symbol,
          decimalDigits: currency.decimals == 0 ? 0 : 1,
        );

  /// Full format: €1.234.567,00
  String format(double value) => _full.format(value);

  /// Compact format: €1,2M or €420K
  String compact(double value) => _compact.format(value);

  /// Percentage: 4.0%  (currency-independent)
  static String percent(double rate) =>
      '${(rate * 100).toStringAsFixed(1)}%';
}
