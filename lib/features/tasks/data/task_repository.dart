import '../domain/task.dart';
import 'task_datasource.dart';
import '../../../../core/services/notification_service.dart';

class TaskRepository {
  final TaskDatasource datasource;
  final NotificationService _notifications = NotificationService();

  TaskRepository(this.datasource);

  List<Task> getTasks() {
    return datasource.getTasks();
  }

  Future<void> addTask(Task task) async {
    await datasource.saveTask(task);
    
    // Gerencia notificações
    if (task.isNotificationEnabled && !task.isDone) {
      await _notifications.scheduleTaskNotification(task);
    } else {
      await _notifications.cancelNotification(task.id);
    }
  }

  Future<void> deleteTask(String id) async {
    await datasource.deleteTask(id);
    await _notifications.cancelNotification(id);
  }
}
