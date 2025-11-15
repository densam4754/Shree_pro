/// Global number and currency formatting utilities
class NumberFormatter {
  /// Format a number with thousands separators (commas)
  /// [number] - The number to format
  /// [decimalPlaces] - Number of decimal places (default: 2)
  static String formatNumberWithCommas(double number, {int decimalPlaces = 2}) {
    final parts = number.toStringAsFixed(decimalPlaces).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';
    
    String formatted = '';
    for (int i = integerPart.length - 1; i >= 0; i--) {
      formatted = integerPart[i] + formatted;
      if ((integerPart.length - i) % 3 == 0 && i != 0) {
        formatted = ',' + formatted;
      }
    }
    
    return decimalPart.isNotEmpty ? '$formatted.$decimalPart' : formatted;
  }

  /// Format a number with thousands separators, no decimal places
  static String formatNumberWithCommasNoDecimal(double number) {
    final integerPart = number.toStringAsFixed(0);
    
    String formatted = '';
    for (int i = integerPart.length - 1; i >= 0; i--) {
      formatted = integerPart[i] + formatted;
      if ((integerPart.length - i) % 3 == 0 && i != 0) {
        formatted = ',' + formatted;
      }
    }
    
    return formatted;
  }

  /// Format currency with thousands separators
  /// Supports M (million) and K (thousand) abbreviations
  static String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${formatNumberWithCommas(amount / 1000000)}M';
    } else if (amount >= 1000) {
      return '\$${formatNumberWithCommas(amount / 1000, decimalPlaces: 1)}K';
    } else {
      return '\$${formatNumberWithCommas(amount)}';
    }
  }

  /// Format currency in compact form (no decimals for M/K)
  static String formatCurrencyCompact(double amount) {
    if (amount >= 1000000) {
      return '\$${formatNumberWithCommas(amount / 1000000, decimalPlaces: 1)}M';
    } else if (amount >= 1000) {
      return '\$${formatNumberWithCommasNoDecimal(amount / 1000)}K';
    } else {
      return '\$${formatNumberWithCommasNoDecimal(amount)}';
    }
  }

  /// Format currency in full form (always shows decimals)
  static String formatCurrencyFull(double amount) {
    return '\$${formatNumberWithCommas(amount, decimalPlaces: 2)}';
  }

  /// Format fuel volume with thousands separators
  static String formatFuel(double liters) {
    return '${formatNumberWithCommasNoDecimal(liters)}L';
  }

  /// Format volume with one decimal place and thousands separators
  static String formatVolume(double volume) {
    return '${formatNumberWithCommas(volume, decimalPlaces: 1)}L';
  }

  /// Format price with thousands separators
  static String formatPrice(double price) {
    return '\$${formatNumberWithCommas(price, decimalPlaces: 2)}';
  }
}

