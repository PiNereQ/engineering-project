import 'dart:ui';

/// Helper to check if a number is integer
bool isInteger(num number) => 
    number == number.toInt();

/// Helper to parse double from dynamic type (double, int, String)
double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

/// Helper to parse number from dynamic type (handles both num and String)
  double parseNum(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

/// Helper to parse int from dynamic type (String, int, double)
int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Helper to parse bool from dynamic type (bool, int, String)
bool parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return false;
}

/// Helper to parse color from hex string
Color parseColor(String? hexColor) {
  if (hexColor == null || hexColor.isEmpty) return Color(0xFF000000);
  
  try {
    String hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  } catch (e) {
    return Color(0xFF000000);
  }
}


/// Helper to format date to string "dd.mm.yyyy"
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day.$month.$year r.';
}

/// Helper to format time (hh:mm) in local timezone
String formatTimeLocal(DateTime time) {
  final local = time.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return "$h:$m";
}

// Helper to format price from smallest currency unit to string with 2 decimals
String formatPrice(int amountInSmallestUnit) {
  final double amount = amountInSmallestUnit / 100.0;
  if (amount == amount.toInt()) {
    return amount.toInt().toString();
  }
  return amount.toStringAsFixed(2).replaceAll('.', ',');
}

/// Helper to format reduction text
String formatReduction(double reduction, bool isPercentage) {
  if (isPercentage) {
    if (isInteger(reduction)) {
      return '${reduction.toInt()}%';
    }
    return '${reduction.toString().replaceAll('.', ',')}%';
  } else {
    if (isInteger(reduction)) {
      return '${reduction.toInt()} zł';
    }
    return '${reduction.toStringAsFixed(2).replaceAll('.', ',')} zł';
  }
}

/// Helper to format number without trailing .0 and with comma as decimal separator
String formatNumber(num value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toString().replaceAll('.', ',');
}

/// Helper to format chat coupon title
String formatChatCouponTitle({
  required num reduction,
  required bool isPercentage,
  required String shopName,
}) {
  final value = formatNumber(reduction);

  return isPercentage
      ? "-$value% • $shopName"
      : "-$value zł • $shopName";
}