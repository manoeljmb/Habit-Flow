import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habitflow/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habitflow/features/habits/presentation/screens/home_screen.dart';
import 'package:habitflow/features/habits/presentation/screens/habits_screen.dart';
import 'package:habitflow/features/habits/domain/habit.dart';
import 'package:habitflow/features/tasks/domain/task.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HabitAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TaskAdapter());
  }

  await Hive.openBox<Habit>('habitsBox');
  await Hive.openBox<Task>('tasksBox');

  runApp(const PlannerApp());
}

class PlannerApp extends StatefulWidget {
  const PlannerApp({super.key});

  @override
  State<PlannerApp> createState() => _PlannerAppState();
}

class _PlannerAppState extends State<PlannerApp> {
  final ThemeController _themeController = ThemeController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: _themeController.themeMode,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('pt'), // Portuguese
            Locale('es'), // Spanish
            Locale('hi'), // Hindi
            Locale('de'), // German
            Locale('ja'), // Japanese
            Locale('ko'), // Korean
          ],

          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6FCF97),
              brightness: Brightness.light,
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6FCF97),
              brightness: Brightness.dark,
            ),
          ),

          onGenerateTitle: (context) {
            return AppLocalizations.of(context)?.appTitle ?? 'HabitFlow';
          },

          home: MainNavigation(
            themeController: _themeController,
          ),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  final ThemeController themeController;

  const MainNavigation({super.key, required this.themeController});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      HomeScreen(themeController: widget.themeController),
      const HabitsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    final tasksLabel = l10n?.tasks ?? 'Tasks';
    final habitsLabel = l10n?.habits ?? 'Habits';

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() => index = value);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.list),
            label: tasksLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.repeat),
            label: habitsLabel,
          ),
        ],
      ),
    );
  }
}
