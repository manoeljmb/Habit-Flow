import 'package:flutter/material.dart';

class HabitWeekRow extends StatelessWidget {
  final List<DateTime> weekDates;
  final Map<String, bool> dates;
  final Function(DateTime) onTap;

  const HabitWeekRow({
    super.key,
    required this.weekDates,
    required this.dates,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {

        final date = weekDates[index];
        final key = date.toIso8601String().split("T").first;
        final status = dates[key];

        Color color;
        if (status == true) {
          color = Colors.green;
        } else if (status == false) {
          color = Colors.grey.shade300;
        } else {
          color = Colors.grey.shade700;
        }

        return GestureDetector(
          onTap: () => onTap(date),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }),
    );
  }
}