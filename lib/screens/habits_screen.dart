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
  List<DateTime> getCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));

    return List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }
  void confirmDeleteHabit(int habitIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Excluir Hábito"),
          content: const Text("Tem certeza que deseja excluir este hábito?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  habits.removeAt(habitIndex);
                  habitService.saveHabits(habits);
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );
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
                    "dates": {}
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
  void toggleDay(int habitIndex, DateTime date) {
    setState(() {
      final habit = habits[habitIndex];
      Map dates = Map<String, bool>.from(habit["dates"] ?? {});

      final key = date.toIso8601String().split("T").first;

      if (!dates.containsKey(key)) {
        dates[key] = true;
      } else if (dates[key] == true) {
        dates[key] = false;
      } else {
        dates.remove(key);
      }

      habit["dates"] = dates;
      habitService.saveHabits(habits);
    });
  }
  void showMonthlyCalendar(BuildContext context, int habitIndex) {
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
                    final date = DateTime(now.year, now.month, dayNumber);
                    final key = date.toIso8601String().split("T").first;

                    final habit = habits[habitIndex];
                    final dates = Map<String, bool>.from(habit["dates"] ?? {});
                    final status = dates[key];

                    Color color;
                    if (status == true) {
                      color = Colors.green;
                    } else if (status == false) {
                      color = Colors.grey.shade300;
                    } else {
                      color = Colors.grey.shade700;
                    }

                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: color,
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
            final dates = Map<String, bool>.from(habit["dates"] ?? {});
            final datesMap = Map<String, bool>.from(habit["dates"] ?? {});
            final weekDates = getCurrentWeek();

            int completed = 0;
            int total = 0;

            for (final date in weekDates) {
              final key = date.toIso8601String().split("T").first;

              if (datesMap.containsKey(key)) {
                total++;
                if (datesMap[key] == true) {
                  completed++;
                }
              }
            }

            final percentage = total == 0 ? 0 : (completed / total) * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        habit["name"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => confirmDeleteHabit(habitIndex),
                      ),
                    ],
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
                      showMonthlyCalendar(context, habitIndex);
                    },
                    child: HabitWeekRow(
                      weekDates: weekDates,
                      dates: dates,
                      onTap: (date) =>
                          toggleDay(habitIndex, date),
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