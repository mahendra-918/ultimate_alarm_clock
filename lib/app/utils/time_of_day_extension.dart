import 'package:flutter/material.dart';

/// Extension methods for TimeOfDay class
extension TimeOfDayExtension on TimeOfDay {
  /// Converts a TimeOfDay to a DateTime with today's date
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
  }
}
