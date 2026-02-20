import 'package:flutter/material.dart';
import '../widgets/habit_week_row.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {

  List<bool?> weekData = [
    true,
    false,
    true,
    null,
    true,
    false,
    true,
  ];
  int get currentDayIndex {
    final now = DateTime.now();
    return now.weekday % 7;
  }
  void toggleDay(int index) {
    setState(() {
      if (weekData[index] == null) {
        weekData[index] = true;
      } else if (weekData[index] == true) {
        weekData[index] = false;
      } else {
        weekData[index] = null;
      }
    });
  }

  double get percentage {
    final validDays = weekData.where((e) => e != null);
    if (validDays.isEmpty) return 0;
    final completed = validDays.where((e) => e == true);
    return completed.length / validDays.length * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Habits")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Não beber",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Sun"),
                Text("Mon"),
                Text("Tue"),
                Text("Wed"),
                Text("Thu"),
                Text("Fri"),
                Text("Sat"),
              ],
            ),
            const SizedBox(height: 8),

            HabitWeekRow(
              weekData: weekData,
              onTap: toggleDay,
              currentDayIndex: currentDayIndex,
            ),

            const SizedBox(height: 16),
            Text("Assertividade: ${percentage.toStringAsFixed(0)}%"),
          ],
        ),
      ),
    );
  }
}