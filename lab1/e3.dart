String formatPrice(
  double amount, {
  String currency = 'MDL',
  int decimals = 2,
}) {
  return '${amount.toStringAsFixed(decimals)} $currency';
}

void main() {
  print(formatPrice(12.5));
  print(formatPrice(12.5, currency: 'MDL'));
  print(formatPrice(99.999, currency: 'EUR'));
  print(formatPrice(7.5, currency: 'USD', decimals: 1));
}