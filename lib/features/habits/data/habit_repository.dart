import 'habit_datasource.dart';

class HabitRepository {
  final HabitDatasource datasource;

  HabitRepository(this.datasource);

  List<Map> getHabits() {
    return datasource.getHabits();
  }

  void saveHabits(List<Map> habits) {
    datasource.saveHabits(habits);
  }
}