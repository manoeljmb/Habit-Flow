import 'package:hive/hive.dart';
import '../domain/task.dart';

class TaskDatasource {
  final Box<Task> box = Hive.box<Task>('tasksBox');

  List<Task> getTasks() {
    return box.values.toList();
  }

  Future<void> saveTask(Task task) async {
    await box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await box.delete(id);
  }
}