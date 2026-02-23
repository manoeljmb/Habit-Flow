import 'package:flutter/material.dart';
import '../../../../widgets/pulsing_fab.dart';
import '../../data/habit_datasource.dart';
import '../../data/habit_repository.dart';
import '../widgets/habit_week_row.dart';
import 'package:habitflow/features/habits/domain/habit.dart';


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
  final HabitRepository habitRepository =
  HabitRepository(HabitDatasource());
  List<Habit> habits = [];
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
  Map<String, int> calculateStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) {
      return {
        "current": 0,
        "best": 0,
      };
    }

    // Normalizar datas (remover hora)
    final dates = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    int bestStreak = 0;
    int tempStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;

      if (diff == 1) {
        tempStreak++;
      } else {
        if (tempStreak > bestStreak) {
          bestStreak = tempStreak;
        }
        tempStreak = 1;
      }
    }

    if (tempStreak > bestStreak) {
      bestStreak = tempStreak;
    }

    // calcular streak atual
    int currentStreak = 0;
    DateTime checkDate = DateTime.now();
    checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

    while (true) {
      final exists = dates.any((d) =>
      d.year == checkDate.year &&
          d.month == checkDate.month &&
          d.day == checkDate.day);

      if (exists) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return {
      "current": currentStreak,
      "best": bestStreak,
    };
  }
  double calculateMonthlyAccuracy(Habit habit, DateTime month) {
    int completed = 0;
    int total = 0;

    final year = month.year;
    final monthNumber = month.month;

    final daysInMonth = DateTime(year, monthNumber + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, monthNumber, day);

      final isActive = habit.activeWeekdays.contains(date.weekday);
      if (!isActive) continue;

      total++;

      final exists = habit.completedDates.any((d) =>
      d.year == date.year &&
          d.month == date.month &&
          d.day == date.day);

      if (exists) {
        completed++;
      }
    }

    if (total == 0) return 0;
    return (completed / total) * 100;
  }
  double calculateYearlyAccuracy(Habit habit, int year) {
    int completed = 0;
    int total = 0;

    for (int month = 1; month <= 12; month++) {
      final daysInMonth = DateTime(year, month + 1, 0).day;

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(year, month, day);

        final isActive = habit.activeWeekdays.contains(date.weekday);
        if (!isActive) continue;

        total++;

        final exists = habit.completedDates.any((d) =>
        d.year == date.year &&
            d.month == date.month &&
            d.day == date.day);

        if (exists) {
          completed++;
        }
      }
    }

    if (total == 0) return 0;
    return (completed / total) * 100;
  }
  void confirmDeleteHabit(int habitIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Habit"),
          content: const Text("Are you sure you want to break this habit?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final habit = habits[habitIndex];

                await habitRepository.deleteHabit(habit.id);
                loadHabits();

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void showAddHabitDialog() {
    final TextEditingController controller = TextEditingController();
    List<int> selectedDays = [1, 2, 3, 4, 5, 6, 7];
    String selectedCategory = "Health";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Habit"),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Enter the name of the habit.",
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: [
                      "Health",
                      "Fitness",
                      "Study",
                      "Work",
                      "Spiritual",
                      "Reading",
                      "Productivity",
                      "Finance",
                      "Mindset",
                      "Diet",
                    ].map(
                          (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    ).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Days of the week",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final isSelected = selectedDays.contains(day);

                      return ChoiceChip(
                        label: Text(
                          ["S", "M", "T", "W", "T", "F", "S"][index],
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setModalState(() {
                            if (isSelected) {
                              selectedDays.remove(day);
                            } else {
                              selectedDays.add(day);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                final newHabit = Habit(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: controller.text.trim(),
                  completedDates: [],
                  activeWeekdays: selectedDays,
                  category: selectedCategory,
                );

                await habitRepository.addHabit(newHabit);
                await loadHabits();

                Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadHabits() async {
    habits = habitRepository.getHabits();



    setState(() {});
  }
  Future<void> toggleDay(int habitIndex, DateTime date) async {
    final habit = habits[habitIndex];

    // 🔒 BLOCK INACTIVE DAYS
    if (!habit.activeWeekdays.contains(date.weekday)) {
      return;
    }

    final dateOnly = DateTime(date.year, date.month, date.day);

    List<DateTime> updatedDates = List.from(habit.completedDates);

    final exists = updatedDates.any((d) =>
    d.year == dateOnly.year &&
        d.month == dateOnly.month &&
        d.day == dateOnly.day);

    if (exists) {
      updatedDates.removeWhere((d) =>
      d.year == dateOnly.year &&
          d.month == dateOnly.month &&
          d.day == dateOnly.day);
    } else {
      updatedDates.add(dateOnly);
    }

    final updatedHabit = habit.copyWith(
      completedDates: updatedDates,
    );

    await habitRepository.addHabit(updatedHabit);
    loadHabits();
  }
  Color getHabitCategoryColor(String category) {
    switch (category) {
      case "Health":
        return Colors.green;
      case "Fitness":
        return Colors.teal;
      case "Study":
        return Colors.purple;
      case "Work":
        return Colors.blue;
      case "Finance":
        return Colors.orange;
      case "Spiritual":
        return Colors.brown;
      case "Reading":
        return Colors.indigo;
      case "Productivity":
        return Colors.cyan;
      case "Mindset":
        return Colors.lime;
      case "Diet":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
  void showMonthlyCalendar(BuildContext context, int habitIndex) {

    DateTime current = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setModalState) {

            int year = current.year;
            int month = current.month;

            final monthNames = [
              "January","February","March","April","May","June",
              "July","August","September","October","November","December"
            ];

            final habit = habits[habitIndex];
            final dates = habit.completedDates;

            final daysInMonth = DateUtils.getDaysInMonth(year, month);
            final firstDay = DateTime(year, month, 1);
            final startingWeekday = firstDay.weekday % 7;

            List<Widget> dayWidgets = [];

            for (int i = 0; i < startingWeekday; i++) {
              dayWidgets.add(const SizedBox());
            }

            for (int day = 1; day <= daysInMonth; day++) {
              final date = DateTime(year, month, day);

              final isActive =
              habit.activeWeekdays.contains(date.weekday);

              final isCompleted = dates.any((d) =>
              d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day);

              Color color;

              if (!isActive) {
                color = Colors.grey.shade800;
              } else if (isCompleted) {
                color = Colors.green;
              } else {
                color = Colors.red.withOpacity(0.6);
              }

              dayWidgets.add(
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: color,
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(20),
              height: 500,
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setModalState(() {
                            current = DateTime(year, month - 1);
                          });
                        },
                      ),

                      Text(
                        "${monthNames[month - 1]} $year",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setModalState(() {
                            current = DateTime(year, month + 1);
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Row(
                    children: [
                      Expanded(child: Center(child: Text("Su"))),
                      Expanded(child: Center(child: Text("Mo"))),
                      Expanded(child: Center(child: Text("Tu"))),
                      Expanded(child: Center(child: Text("We"))),
                      Expanded(child: Center(child: Text("Th"))),
                      Expanded(child: Center(child: Text("Fr"))),
                      Expanded(child: Center(child: Text("Sa"))),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: dayWidgets,
                    ),
                  ),
                ],
              ),
            );
          },
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
        child: habits.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.repeat,
                size: 60,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              const Text(
                "No habits yet",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: showAddHabitDialog,
                child: const Text("Create your first habit"),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: habits.length,
          itemBuilder: (context, habitIndex) {
            final habit = habits[habitIndex];
            final dates = habit.completedDates;

            final streakData = calculateStreak(dates);
            final monthlyAccuracy =
            calculateMonthlyAccuracy(habit, DateTime.now());

            final yearlyAccuracy =
            calculateYearlyAccuracy(habit, DateTime.now().year);

            final weekDates = getCurrentWeek();

            int completed = 0;
            int total = 0;

            for (final date in weekDates) {
              final normalized = DateTime(date.year, date.month, date.day);
              final isActive =
              habit.activeWeekdays.contains(date.weekday);

              if (!isActive) continue;

              total++;

              final exists = dates.any((d) =>
              d.year == normalized.year &&
                  d.month == normalized.month &&
                  d.day == normalized.day);

              if (exists) completed++;
            }

            final percentage =
            total == 0 ? 0 : (completed / total) * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: getHabitCategoryColor(habit.category)
                      .withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: getHabitCategoryColor(habit.category)
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        habit.title,
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
                    children: const [
                      Expanded(child: Center(child: Text("Sun"))),
                      Expanded(child: Center(child: Text("Mon"))),
                      Expanded(child: Center(child: Text("Tue"))),
                      Expanded(child: Center(child: Text("Wed"))),
                      Expanded(child: Center(child: Text("Thu"))),
                      Expanded(child: Center(child: Text("Fri"))),
                      Expanded(child: Center(child: Text("Sat"))),
                    ],
                  ),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onLongPress: () {
                      showMonthlyCalendar(context, habitIndex);
                    },
                    child: HabitWeekRow(
                      weekDates: weekDates,
                      dates: habit.completedDates,
                      activeWeekdays: habit.activeWeekdays,
                      onTap: (date) => toggleDay(habitIndex, date),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // 🔥 Main indicator (without "Assertiveness" text)
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${percentage.toStringAsFixed(0)}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      // 📅 Calendar (opens monthly modal)
                      IconButton(
                        icon: const Icon(Icons.calendar_month_outlined),
                        onPressed: () {
                          showMonthlyCalendar(context, habitIndex);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "🔥 Current: ${streakData["current"]} days | 🏆 Best: ${streakData["best"]} days",
                  ),
                ],
              ),
            ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: PulsingFAB(
        onTap: showAddHabitDialog,
      ),
    );
  }
}