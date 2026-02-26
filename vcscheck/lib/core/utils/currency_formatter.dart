import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _full = NumberFormat.currency(locale: 'de_DE', symbol: '€');
  static final _compact =
      NumberFormat.compactCurrency(locale: 'de_DE', symbol: '€', decimalDigits: 1);

  /// Full format: €1.234.567,00
  static String format(double value) => _full.format(value);

  /// Compact format: €1,2M or €420K
  static String compact(double value) => _compact.format(value);

  /// Percentage: 4.0%
  static String percent(double rate) =>
      '${(rate * 100).toStringAsFixed(1)}%';
}
