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
  void showAddTaskDialog() {
    final titleController = TextEditingController();
    String selectedCategory = "General";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nova Tarefa"),
          content: Column(
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
                  selectedCategory = value!;
                },
              ),
            ],
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
                  "date": DateTime.now().toIso8601String(),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Today")),
      body: tasks.isEmpty
          ?   const Center(child: Text("Nenhuma tarefa hoje"))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return ListTile(
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
