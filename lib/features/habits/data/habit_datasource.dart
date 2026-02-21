import 'package:hive/hive.dart';
import '../domain/habit.dart';

class HabitDatasource {
  final Box<Habit> box = Hive.box<Habit>('habitsBox');

  List<Habit> getHabits() {
    return box.values.toList();
  }

  Future<void> saveHabit(Habit habit) async {
    await box.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await box.delete(id);
  }
}