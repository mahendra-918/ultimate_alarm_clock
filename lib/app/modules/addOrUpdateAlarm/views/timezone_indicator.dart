import 'package:flutter/material.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class TimezoneIndicator extends StatelessWidget {
  final String timezoneName;
  
  const TimezoneIndicator({
    Key? key,
    required this.timezoneName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: kprimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.public, size: 14, color: kprimaryColor),
          const SizedBox(width: 4),
          Text(
            timezoneName,
            style: const TextStyle(
              fontSize: 12,
              color: kprimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 