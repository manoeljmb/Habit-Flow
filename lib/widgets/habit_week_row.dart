import 'package:flutter/material.dart';

class HabitWeekRow extends StatelessWidget {
  final List<bool?> weekData;
  final Function(int) onTap;
  final int currentDayIndex;

  const HabitWeekRow({
    super.key,
    required this.weekData,
    required this.onTap,
    required this.currentDayIndex,
  });

  Color getColor(bool? status) {
    if (status == true) return Colors.green;
    if (status == false) return Colors.grey.shade300;
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {

        return GestureDetector(
          onTap: () => onTap(index),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: getColor(weekData[index]),
              borderRadius: BorderRadius.circular(8),
              border: index == currentDayIndex
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
            ),
          ),
        );

      }),
    );
  }
}