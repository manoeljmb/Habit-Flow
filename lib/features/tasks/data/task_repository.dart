import '../domain/task.dart';
import 'task_datasource.dart';

class TaskRepository {
  final TaskDatasource datasource;

  TaskRepository(this.datasource);

  List<Task> getTasks() {
    return datasource.getTasks();
  }

  Future<void> addTask(Task task) {
    return datasource.saveTask(task);
  }

  Future<void> deleteTask(String id) {
    return datasource.deleteTask(id);
  }
}