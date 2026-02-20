import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = DateFormat('EEE', 'en_US').format(now);
    final dayNumber = now.day;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            dayName,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Text(
            dayNumber.toString(),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}