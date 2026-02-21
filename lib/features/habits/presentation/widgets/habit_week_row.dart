import 'package:flutter/material.dart';

class HabitWeekRow extends StatelessWidget {
  final List<DateTime> weekDates;
  final List<DateTime> dates;
  final Function(DateTime) onTap;
  final List<int> activeWeekdays;

  const HabitWeekRow({
    super.key,
    required this.weekDates,
    required this.dates,
    required this.onTap,
    required this.activeWeekdays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = weekDates[index];
        final normalized = DateTime(date.year, date.month, date.day);

        final isActive = activeWeekdays.contains(date.weekday);

        final isCompleted = dates.any((d) =>
        d.year == normalized.year &&
            d.month == normalized.month &&
            d.day == normalized.day);

        Color color;

        if (!isActive) {
          color = Colors.grey.shade800; // 🔒 dia não ativo
        } else if (isCompleted) {
          color = Colors.green; // ✅ concluído
        } else {
          color = Colors.grey.shade300; // disponível
        }

        return GestureDetector(
          onTap: isActive ? () => onTap(date) : null,
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