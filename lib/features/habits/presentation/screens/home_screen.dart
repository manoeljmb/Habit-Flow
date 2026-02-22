import 'package:flutter/material.dart';
import '../../../tasks/data/task_repository.dart';
import '../../../tasks/data/task_datasource.dart';
import 'package:habitflow/features/habits/domain/habit.dart';
import 'package:habitflow/features/tasks/domain/task.dart';
import 'package:habitflow/core/constants/task_categories.dart';
import 'package:habitflow/widgets/progress_ring.dart';
import '/../widgets/pulsing_fab.dart';

import 'package:habitflow/core/theme/theme_controller.dart';

class HomeScreen extends StatefulWidget {
  final ThemeController themeController;

  const HomeScreen({
    super.key,
    required this.themeController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final taskRepository =
  TaskRepository(TaskDatasource());

  DateTime selectedDate = DateTime.now();
  List<Habit> habits = [];
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Color getCategoryColor(String category) {
    final match = taskCategories
        .firstWhere(
          (c) => c.name == category,
      orElse: () => taskCategories.first,
    );

    return match.color;
  }

  List<Task> getTasksForSelectedDate() {
    return tasks.where((task) {
      final taskDate = task.date;

      return taskDate.year == selectedDate.year &&
          taskDate.month == selectedDate.month &&
          taskDate.day == selectedDate.day;
    }).toList();
  }

  void showTaskDialog({Task? existingTask}) {
    final titleController =
    TextEditingController(text: existingTask?.title ?? "");

    String selectedCategory =
        existingTask?.category ?? "General";

    DateTime selectedDate =
        existingTask?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existingTask == null ? "New Task" : "Edit Task",
          ),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Type the task",
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: taskCategories
                        .map(
                          (category) => DropdownMenuItem(
                        value: category.name,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(category.name),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => showPlannerCalendar(context),
                        child: Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked =
                          await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child:
                        const Text("Select date"),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                if (existingTask == null) {
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    date: selectedDate,
                    isDone: false,
                    category: selectedCategory,
                  );

                  await taskRepository.addTask(newTask);
                } else {
                  final updatedTask = existingTask.copyWith(
                    title: titleController.text.trim(),
                    category: selectedCategory,
                    date: selectedDate,
                  );

                  await taskRepository.addTask(updatedTask);
                }

                loadTasks();
                Navigator.pop(context);
              },
              child: Text(
                existingTask == null
                    ? "Create"
                    : "Save",
              ),
            ),
          ],
        );
      },
    );
  }

  void showPlannerCalendar(BuildContext context) {
    DateTime tempDate = selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final daysInMonth =
            DateUtils.getDaysInMonth(tempDate.year, tempDate.month);

            return Container(
              padding: const EdgeInsets.all(20),
              height: 500,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [

                  // 🔹 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setModalState(() {
                            tempDate = DateTime(
                              tempDate.year,
                              tempDate.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        "${tempDate.month}/${tempDate.year}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setModalState(() {
                            tempDate = DateTime(
                              tempDate.year,
                              tempDate.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🔹 GRID
                  Expanded(
                    child: GridView.builder(
                      itemCount: daysInMonth,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                      ),
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final date =
                        DateTime(tempDate.year, tempDate.month, day);

                        final hasTask = tasks.any((task) =>
                        task.date.year == date.year &&
                            task.date.month == date.month &&
                            task.date.day == date.day);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: hasTask
                                  ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3)
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(day.toString()),
                            ),
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
      },
    );
  }
  void loadTasks() {
    tasks = taskRepository.getTasks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = getTasksForSelectedDate();

    double progress = 0;

    if (filteredTasks.isNotEmpty) {
      final done = filteredTasks.where((t) => t.isDone).length;
      progress = done / filteredTasks.length;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: PulsingFAB(
        onTap: () => showTaskDialog(),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.3,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
              const Color(0xFF1A1F2C),
              const Color(0xFF0F1320),
            ]
                : [
              const Color(0xFFE3F2ED),
              const Color(0xFFF4F7F6),
            ],
          ),
        ),
        child: Column(
          children: [

            // 🔹 HEADER PREMIUM
            Container(
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        "Today",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                      Row(
                        children: [
                          const Icon(Icons.dark_mode, size: 18),
                          GestureDetector(
                            onTap: () {
                              final isDark =
                                  widget.themeController.themeMode == ThemeMode.dark;

                              widget.themeController.setTheme(
                                isDark ? ThemeMode.light : ThemeMode.dark,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                              width: 64,
                              height: 34,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: widget.themeController.themeMode == ThemeMode.dark
                                    ? const Color(0xFF1E1E1E)
                                    : const Color(0xFF6FCF97),
                                border: Border.all(
                                  color: widget.themeController.themeMode == ThemeMode.dark
                                      ? Colors.grey.shade700
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutCubic,
                                alignment:
                                widget.themeController.themeMode == ThemeMode.dark
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Icon(Icons.light_mode, size: 18),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  GestureDetector(
                    onTap: () => showPlannerCalendar(context),
                    child: Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NavButton(
                        icon: Icons.chevron_left,
                        onTap: () {
                          setState(() {
                            selectedDate =
                                selectedDate.subtract(const Duration(days: 1));
                          });
                        },
                      ),

                      _TodayButton(
                        onTap: () {
                          setState(() {
                            selectedDate = DateTime.now();
                          });
                        },
                      ),

                      _NavButton(
                        icon: Icons.chevron_right,
                        onTap: () {
                          setState(() {
                            selectedDate =
                                selectedDate.add(const Duration(days: 1));
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
      // 🔹 LISTA
      Expanded(
        child: filteredTasks.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 60,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                "Nenhuma tarefa para este dia",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return buildPremiumTaskCard(task);
          },
        ),
      ),
    ],
      ),
    ),
    );
  }
  Widget buildPremiumTaskCard(Task task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      onDismissed: (_) async {
        await taskRepository.deleteTask(task.id);
        loadTasks();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: getCategoryColor(task.category).withOpacity(0.08),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: getCategoryColor(task.category).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [

            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: getCategoryColor(task.category),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    task.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: getCategoryColor(task.category),
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: Icon(
                task.isDone
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,

                color: task.isDone
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade400,
              ),
              onPressed: () async {
                final updatedTask = task.copyWith(
                  isDone: !task.isDone,
                );

                await taskRepository.addTask(updatedTask);
                loadTasks();
              },
            ),
          ],
        ),
      ),
    );
  }
}
Color getTaskCategoryColor(String category) {
  switch (category) {
    case "General":
      return Colors.grey;
    case "Health":
      return Colors.green;
    case "Coding":
      return Colors.blue;
    case "Social":
      return Colors.teal;
    case "Study":
      return Colors.purple;
    case "Work":
      return Colors.indigo;
    default:
      return Colors.grey;
  }
}

class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2C2C2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Icon(
          widget.icon,
          size: 20,
          color: isDark
              ? Colors.white
              : Colors.black87,
        ),
      ),
    );
  }
}

class _TodayButton extends StatefulWidget {
  final VoidCallback onTap;

  const _TodayButton({required this.onTap});

  @override
  State<_TodayButton> createState() => _TodayButtonState();
}

class _TodayButtonState extends State<_TodayButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF3A3A3C)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08),
          ),
        ),
        child: Text(
          "Today",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isDark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
    );
  }
}
