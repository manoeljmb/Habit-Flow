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
      children: List.generate(7, (index) {
        final date = weekDates[index];
        final normalized = DateTime(date.year, date.month, date.day);

        final isActive = activeWeekdays.contains(date.weekday);

        final isCompleted = isActive && dates.any((d) =>
            d.year == normalized.year &&
            d.month == normalized.month &&
            d.day == normalized.day);

        Color color;

        if (!isActive) {
          color = Colors.grey.shade800; // bloqueado
        } else if (isCompleted) {
          color = Colors.green;
        } else {
          color = Colors.grey.shade300;
        }

        return Expanded(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: isActive ? () => onTap(date) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isCompleted
                        ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: !isActive
                            ? Colors.grey.shade400
                            : isCompleted
                            ? Colors.white
                            : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}