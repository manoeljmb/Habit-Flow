import 'task_datasource.dart';

class TaskRepository {
  final TaskDatasource datasource;

  TaskRepository(this.datasource);

  List<Map> getTasks() {
    return datasource.getTasks();
  }

  void saveTasks(List<Map> tasks) {
    datasource.saveTasks(tasks);
  }
}