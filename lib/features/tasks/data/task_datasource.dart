import 'package:hive/hive.dart';

class TaskDatasource {
  final Box box = Hive.box('tasksBox');

  List<Map> getTasks() {
    return box.get('tasks', defaultValue: []).cast<Map>();
  }

  void saveTasks(List<Map> tasks) {
    box.put('tasks', tasks);
  }
}