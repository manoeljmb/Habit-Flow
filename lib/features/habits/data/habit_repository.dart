import '../domain/habit.dart';
import 'habit_datasource.dart';

class HabitRepository {
  final HabitDatasource datasource;

  HabitRepository(this.datasource);

  List<Habit> getHabits() {
    return datasource.getHabits();
  }

  Future<void> addHabit(Habit habit) {
    return datasource.saveHabit(habit);
  }

  Future<void> deleteHabit(String id) {
    return datasource.deleteHabit(id);
  }
}