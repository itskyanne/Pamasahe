class CurrencyFormat {
  static String format(double amount) {
    return '₱${amount.toStringAsFixed(2)}';
  }
}
