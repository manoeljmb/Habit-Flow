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

  Color getCategoryColor(String category) {
    switch (category) {
      case "Work":
        return Colors.blue;
      case "Study":
        return Colors.purple;
      case "Health":
        return Colors.green;
      default:
        return Colors.grey;
    }
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

    double progress = 0;

    if (filteredTasks.isNotEmpty) {
      final done =
          filteredTasks.where((t) => t["completed"] == true).length;
      progress = done / filteredTasks.length;
    }

    return Scaffold(

      body: Column(
        children: [

          Container(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Título
                Text(
                  "Today",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 6),

                // Data
                Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 16),

                // Navegação elegante
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = DateTime.now();
                        });
                      },
                      child: const Text("Voltar para Hoje"),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${(progress * 100).toInt()}% concluído",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),

              ],
            ),
          ),
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
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shadowColor: Colors.black.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [

                          // Categoria color dot
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: getCategoryColor(task["category"]),
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Texto
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task["title"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    decoration: task["completed"]
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  task["category"],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: getCategoryColor(
                                        task["category"]),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Checkbox
                          Transform.scale(
                            scale: 1.2,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Checkbox(
                                key: ValueKey(task["completed"]),
                                value: task["completed"],
                                onChanged: (value) {
                                  setState(() {
                                    task["completed"] = value;
                                    taskService.saveTasks(tasks);
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
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
