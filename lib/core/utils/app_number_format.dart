class AppNumberFormat {
  static String format(int amount) {
    final negative = amount < 0;
    final digits = amount.abs().toString().split('').reversed.toList();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index != 0 && index % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[index]);
    }

    final formatted = buffer.toString().split('').reversed.join();
    return '${negative ? '-' : ''}$formatted ₫';
  }
}
