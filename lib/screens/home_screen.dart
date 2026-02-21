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

  DateTime selectedDate = DateTime.now();
  List<Map> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  List<Map> getTasksForSelectedDate() {
    return tasks.where((task) {
      final taskDate = DateTime.parse(task["date"]);

      return taskDate.year == selectedDate.year &&
          taskDate.month == selectedDate.month &&
          taskDate.day == selectedDate.day;
    }).toList();
  }

  void showTaskDialog({Map? existingTask}) {
    final titleController =
    TextEditingController(text: existingTask?["title"] ?? "");

    String selectedCategory =
        existingTask?["category"] ?? "General";

    DateTime selectedDate = existingTask != null
        ? DateTime.parse(existingTask["date"])
        : DateTime.now();

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
              onPressed: () {
                if (titleController.text.trim().isEmpty)
                  return;

                if (existingTask == null) {
                  // CRIAR
                  final newTask = {
                    "id":
                    DateTime.now().toIso8601String(),
                    "title":
                    titleController.text.trim(),
                    "category": selectedCategory,
                    "date":
                    selectedDate.toIso8601String(),
                    "completed": false,
                  };

                  tasks.add(newTask);
                } else {
                  // EDITAR
                  existingTask["title"] =
                      titleController.text.trim();
                  existingTask["category"] =
                      selectedCategory;
                  existingTask["date"] =
                      selectedDate.toIso8601String();
                }

                taskService.saveTasks(tasks);
                setState(() {});
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
    tasks = taskService.getTasks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = getTasksForSelectedDate();
    return Scaffold(

      appBar: AppBar(title: const Text("Today")),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedDate =
                          selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                ),

                Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      selectedDate =
                          selectedDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(child: Text("Nenhuma tarefa"))
                : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];

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
                      tasks.removeWhere(
                              (t) => t["id"] == task["id"]);
                      taskService.saveTasks(tasks);
                    });
                  },
                  child: ListTile(
                    onTap: () => showTaskDialog(existingTask: task),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskDialog(),
        child: const Icon(Icons.add),
      ),

    );

  }
}
