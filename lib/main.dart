import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habitflow/core/theme/app_colors.dart';
import 'package:habitflow/features/habits/presentation/screens/home_screen.dart';
import 'package:habitflow/features/habits/presentation/screens/habits_screen.dart';
import 'package:habitflow/features/habits/domain/habit.dart';
import 'package:habitflow/features/tasks/domain/task.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(TaskAdapter());

  await Hive.openBox<Habit>('habitsBox');
  await Hive.openBox<Task>('tasksBox');

  runApp(const PlannerApp());
}

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      themeMode: ThemeMode.system, // usa sistema

      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6FCF97),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6FCF97),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1320),
        useMaterial3: true,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  final screens = const [
    HomeScreen(),
    HabitsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() => index = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.repeat),
            label: 'Habits',
          ),
        ],
      ),
    );
  }
}