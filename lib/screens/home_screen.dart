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

  void loadTasks() {
    tasks = taskService.getTasks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today")),
      body: tasks.isEmpty
          ? const Center(child: Text("Nenhuma tarefa hoje"))
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
    );
  }
}