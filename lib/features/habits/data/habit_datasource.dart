import 'package:hive/hive.dart';

class HabitDatasource {
  final Box box = Hive.box('habitsBox');

  List<Map> getHabits() {
    return box.get('habits', defaultValue: []).cast<Map>();
  }

  void saveHabits(List<Map> habits) {
    box.put('habits', habits);
  }
}