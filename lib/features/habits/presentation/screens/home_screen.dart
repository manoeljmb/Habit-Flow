import 'package:flutter/material.dart';
import '../../../tasks/data/task_repository.dart';
import '../../../tasks/data/task_datasource.dart';
import 'package:habitflow/features/habits/domain/habit.dart';
import 'package:habitflow/features/tasks/domain/task.dart';
import 'package:habitflow/core/constants/task_categories.dart';
import 'package:habitflow/widgets/progress_ring.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
            existingTask == null ? "Nova Tarefa" : "Editar Tarefa",
          ),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Digite a tarefa",
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
                      Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
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
                        const Text("Selecionar Data"),
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
              child: const Text("Cancelar"),
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
                    ? "Criar"
                    : "Salvar",
              ),
            ),
          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskDialog(),
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Color(0xFFE3F2ED),
              Color(0xFFF4F7F6),
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

                  Text(
                    "Today",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      IconButton(
                        icon: Icon(Icons.chevron_left,
                            color: Colors.grey.shade700),
                        onPressed: () {
                          setState(() {
                            selectedDate =
                                selectedDate.subtract(const Duration(days: 1));
                          });
                        },
                      ),

                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor:
                          Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedDate = DateTime.now();
                          });
                        },
                        child: const Text("Hoje"),
                      ),

                      IconButton(
                        icon: Icon(Icons.chevron_right,
                            color: Colors.grey.shade700),
                        onPressed: () {
                          setState(() {
                            selectedDate =
                                selectedDate.add(const Duration(days: 1));
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🔹 PROGRESS CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Progresso do dia",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ProgressRing(
                        percentage: progress * 100,
                        size: 110,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${(progress * 100).toInt()}% concluído",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 LISTA
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt,
                        size: 60, color: Colors.grey.shade400),
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
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await taskRepository.deleteTask(task.id);
        loadTasks();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, 15),
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
