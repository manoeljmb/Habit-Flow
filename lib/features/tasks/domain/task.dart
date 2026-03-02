import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final bool isDone;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final bool isNotificationEnabled;

  @HiveField(6)
  final int? reminderMinutesBefore;

  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.isDone,
    required this.category,
    this.isNotificationEnabled = false,
    this.reminderMinutesBefore,
  });

  Task copyWith({
    String? id,
    String? title,
    DateTime? date,
    bool? isDone,
    String? category,
    bool? isNotificationEnabled,
    int? reminderMinutesBefore,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
      category: category ?? this.category,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }
}
