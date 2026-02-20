import 'package:flutter/material.dart';
import '../widgets/habit_week_row.dart';
import '../services/habit_service.dart';


class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {

  int get currentDayIndex {
    final now = DateTime.now();
    return now.weekday % 7;
  }
  final HabitService habitService = HabitService();
  List<Map> habits = [];
  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  void showAddHabitDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Novo Hábito"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Digite o nome do hábito",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;

                setState(() {
                  habits.add({
                    "name": controller.text.trim(),
                    "weekData": [null, null, null, null, null, null, null]
                  });

                  habitService.saveHabits(habits);
                });

                Navigator.pop(context);
              },
              child: const Text("Criar"),
            ),
          ],
        );
      },
    );
  }

  void loadHabits() {
    habits = habitService.getHabits();

    if (habits.isEmpty) {
      habits = [
        {
          "name": "Não beber",
          "weekData": [true, false, true, null, true, false, true]
        }
      ];
      habitService.saveHabits(habits);
    }

    setState(() {});
  }
  void toggleDay(int habitIndex, int dayIndex) {
    setState(() {
      List weekData = habits[habitIndex]["weekData"];

      if (weekData[dayIndex] == null) {
        weekData[dayIndex] = true;
      } else if (weekData[dayIndex] == true) {
        weekData[dayIndex] = false;
      } else {
        weekData[dayIndex] = null;
      }

      habits[habitIndex]["weekData"] = weekData;
      habitService.saveHabits(habits);
    });
  }
  void showMonthlyCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final now = DateTime.now();
        final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

        return Container(
          padding: const EdgeInsets.all(16),
          height: 500,
          child: Column(
            children: [
              Text(
                "${now.month}/${now.year}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: daysInMonth,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemBuilder: (context, index) {
                    final dayNumber = index + 1;

                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey.shade300,
                      ),
                      child: Center(
                        child: Text(dayNumber.toString()),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Habits")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: habits.length,
          itemBuilder: (context, habitIndex) {
            final habit = habits[habitIndex];
            final weekData = habit["weekData"].cast<bool?>();

            final validDays = weekData.where((e) => e != null);
            final completed = validDays.where((e) => e == true);
            final percentage = validDays.isEmpty
                ? 0
                : completed.length / validDays.length * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    habit["name"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

                  GestureDetector(
                    onLongPress: () {
                      showMonthlyCalendar(context);
                    },
                    child: HabitWeekRow(
                      weekData: weekData,
                      currentDayIndex: currentDayIndex,
                      onTap: (dayIndex) =>
                          toggleDay(habitIndex, dayIndex),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Assertividade: ${percentage.toStringAsFixed(0)}%",
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddHabitDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}