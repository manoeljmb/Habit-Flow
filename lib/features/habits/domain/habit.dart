import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<DateTime> completedDates;

  @HiveField(3)
  final List<int> activeWeekdays;

  @HiveField(4)
  final String category;

  Habit({
    required this.id,
    required this.title,
    required this.completedDates,
    required this.activeWeekdays,
    required this.category
  });

  Habit copyWith({
    String? id,
    String? title,
    List<DateTime>? completedDates,
    List<int>? activeWeekdays,
    String? category,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      completedDates: completedDates ?? this.completedDates,
      activeWeekdays: activeWeekdays ?? this.activeWeekdays,
      category: category ?? this.category,
    );
  }
}