import 'package:flutter/material.dart';
import '../widgets/calendar_header.dart';
import '../services/task_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService taskService = TaskService();
  List<Map> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  List<Map> getTodayTasks() {
    final today = DateTime.now();

    return tasks.where((task) {
      final taskDate = DateTime.parse(task["date"]);

      return taskDate.year == today.year &&
          taskDate.month == today.month &&
          taskDate.day == today.day;
    }).toList();
  }

  void showAddTaskDialog() {
    final titleController = TextEditingController();
    String selectedCategory = "General";
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nova Tarefa"),
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
                    items: ["General", "Work", "Study", "Health"]
                        .map(
                          (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
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
                        child: const Text("Selecionar Data"),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;

                final newTask = {
                  "id": DateTime.now().toIso8601String(),
                  "title": titleController.text.trim(),
                  "category": selectedCategory,
                  "date": selectedDate.toIso8601String(),
                  "completed": false,
                };

                setState(() {
                  tasks.add(newTask);
                  taskService.saveTasks(tasks);
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
  void loadTasks() {
    tasks = taskService.getTasks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final todayTasks = getTodayTasks();
    return Scaffold(

      appBar: AppBar(title: const Text("Today")),
      body: todayTasks.isEmpty
          ?   const Center(child: Text("Nenhuma tarefa hoje"))
          : ListView.builder(
        itemCount: todayTasks.length,
        itemBuilder: (context, index) {
          final task = todayTasks[index];

          return Dismissible(
            key: Key(task["id"]),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              setState(() {
                tasks.removeWhere((t) => t["id"] == task["id"]);
                taskService.saveTasks(tasks);
              });
            },
            child: ListTile(
              title: Text(task["title"]),
              subtitle: Text(task["category"]),
              trailing: Checkbox(
                value: task["completed"],
                onChanged: (value) {
                  setState(() {
                    task["completed"] = value;
                    taskService.saveTasks(tasks);
                  });
                },
              ),
            ),
          );
        },

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add),
      ),

    );

  }
}
