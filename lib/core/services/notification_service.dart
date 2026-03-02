import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../features/tasks/domain/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (!task.isNotificationEnabled || task.date.isBefore(DateTime.now())) {
      return;
    }

    final int minutesBefore = task.reminderMinutesBefore ?? 0;
    final scheduledDate = task.date.subtract(Duration(minutes: minutesBefore));

    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      task.id.hashCode,
      'HabitFlow: ${task.title}',
      'Sua tarefa está prestes a começar!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Lembretes de Tarefas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }
}
