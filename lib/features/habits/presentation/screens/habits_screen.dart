import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:habitflow/l10n/app_localizations.dart';
import '../../../../widgets/pulsing_fab.dart';
import '../../data/habit_datasource.dart';
import '../../data/habit_repository.dart';
import '../widgets/habit_week_row.dart';
import 'package:habitflow/features/habits/domain/habit.dart';

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────

const _kCategories = [
  "Health", "Fitness", "Study", "Work", "Spiritual",
  "Reading", "Productivity", "Finance", "Mindset", "Diet",
];

const _kDayLabels = ["M", "T", "W", "T", "F", "S", "S"];
const _kDayHeaders = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

// ─────────────────────────────────────────────
//  CATEGORY COLOR MAP
// ─────────────────────────────────────────────

final Map<String, Color> _categoryColors = {
  "Health": const Color(0xFF2ECC71),
  "Fitness": const Color(0xFF1ABC9C),
  "Study": const Color(0xFF9B59B6),
  "Work": const Color(0xFF3498DB),
  "Finance": const Color(0xFFF39C12),
  "Spiritual": const Color(0xFF795548),
  "Reading": const Color(0xFF3F51B5),
  "Productivity": const Color(0xFF00BCD4),
  "Mindset": const Color(0xFF8BC34A),
  "Diet": const Color(0xFFE74C3C),
};

Color _categoryColor(String category) =>
    _categoryColors[category] ?? const Color(0xFF9E9E9E);

String _getTranslatedCategory(BuildContext context, String category) {
  final l10n = AppLocalizations.of(context)!;
  switch (category) {
    case "Health": return l10n.health;
    case "Fitness": return l10n.fitness;
    case "Study": return l10n.study;
    case "Work": return l10n.work;
    case "Spiritual": return l10n.spiritual;
    case "Reading": return l10n.reading;
    case "Productivity": return l10n.productivity;
    case "Finance": return l10n.finance;
    case "Mindset": return l10n.mindset;
    case "Diet": return l10n.diet;
    default: return category;
  }
}

// ─────────────────────────────────────────────
//  HABITS SCREEN
// ─────────────────────────────────────────────

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final HabitRepository _repo = HabitRepository(HabitDatasource());
  List<Habit> _habits = [];
  int? _pressedIndex;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = _repo.getHabits();
    setState(() => _habits = data);
  }

  List<DateTime> _currentWeek() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  Map<String, int> _streak(List<DateTime> raw) {
    if (raw.isEmpty) return {"current": 0, "best": 0};

    final dates = raw
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    int best = 1, temp = 1;
    for (int i = 1; i < dates.length; i++) {
      dates[i].difference(dates[i - 1]).inDays == 1 ? temp++ : temp = 1;
      if (temp > best) best = temp;
    }

    int current = 0;
    DateTime check = DateTime.now();
    check = DateTime(check.year, check.month, check.day);
    while (dates.any((d) =>
        d.year == check.year &&
        d.month == check.month &&
        d.day == check.day)) {
      current++;
      check = check.subtract(const Duration(days: 1));
    }

    return {"current": current, "best": best};
  }

  double _monthlyAccuracy(Habit habit, DateTime month) {
    int done = 0, total = 0;
    final days = DateTime(month.year, month.month + 1, 0).day;
    for (int d = 1; d <= days; d++) {
      final date = DateTime(month.year, month.month, d);
      if (!habit.activeWeekdays.contains(date.weekday)) continue;
      total++;
      if (habit.completedDates.any((c) =>
          c.year == date.year && c.month == date.month && c.day == date.day)) {
        done++;
      }
    }
    return total == 0 ? 0 : (done / total) * 100;
  }

  double _yearlyAccuracy(Habit habit, int year) {
    int done = 0, total = 0;
    for (int m = 1; m <= 12; m++) {
      final days = DateTime(year, m + 1, 0).day;
      for (int d = 1; d <= days; d++) {
        final date = DateTime(year, m, d);
        if (!habit.activeWeekdays.contains(date.weekday)) continue;
        total++;
        if (habit.completedDates.any((c) =>
            c.year == date.year && c.month == date.month && c.day == date.day)) {
          done++;
        }
      }
    }
    return total == 0 ? 0 : (done / total) * 100;
  }

  Future<void> _toggleDay(int idx, DateTime date) async {
    final habit = _habits[idx];
    if (!habit.activeWeekdays.contains(date.weekday)) return;

    final d = DateTime(date.year, date.month, date.day);
    final updated = List<DateTime>.from(habit.completedDates);

    updated.any((c) => c.year == d.year && c.month == d.month && c.day == d.day)
        ? updated.removeWhere(
            (c) => c.year == d.year && c.month == d.month && c.day == d.day)
        : updated.add(d);

    await _repo.addHabit(habit.copyWith(completedDates: updated));
    _load();
  }

  void _showOptions(int idx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(
        onView: () {
          Navigator.pop(context);
          _openDetails(idx);
        },
        onEdit: () {
          Navigator.pop(context);
          _showEditDialog(idx);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(idx);
        },
      ),
    );
  }

  void _openDetails(int idx) {
    final h = _habits[idx];
    final s = _streak(h.completedDates);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HabitDetailsScreen(
          habit: h,
          currentStreak: s["current"]!,
          bestStreak: s["best"]!,
          monthlyAccuracy: _monthlyAccuracy(h, DateTime.now()),
          yearlyAccuracy: _yearlyAccuracy(h, DateTime.now().year),
        ),
      ),
    );
  }

  void _showAddDialog() => _showHabitDialog();
  void _showEditDialog(int idx) => _showHabitDialog(existing: _habits[idx]);

  void _showHabitDialog({Habit? existing}) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: existing?.title ?? '');
    List<int> days = existing != null
        ? List.from(existing.activeWeekdays)
        : [1, 2, 3, 4, 5, 6, 7];
    String cat = existing?.category ?? "Health";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            existing == null ? l10n.addHabit : l10n.editHabit,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    hintText: l10n.habitName,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.category,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: cat,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  items: _kCategories
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text(_getTranslatedCategory(context, e))))
                      .toList(),
                  onChanged: (v) => set(() => cat = v!),
                ),
                const SizedBox(height: 16),
                Text(l10n.activeDays,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: List.generate(7, (i) {
                    final day = i + 1;
                    final sel = days.contains(day);
                    return GestureDetector(
                      onTap: () => set(() => sel ? days.remove(day) : days.add(day)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: sel
                              ? _categoryColor(cat)
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            _kDayLabels[i],
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: sel
                                  ? Colors.white
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (ctrl.text.trim().isEmpty) return;
                final h = (existing ??
                        Habit(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: '',
                          completedDates: [],
                          activeWeekdays: [],
                          category: '',
                        ))
                    .copyWith(
                  title: ctrl.text.trim(),
                  category: cat,
                  activeWeekdays: days,
                );
                await _repo.addHabit(h);
                await _load();
                Navigator.pop(context);
              },
              child: Text(existing == null ? l10n.create : l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int idx) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.deleteHabit),
        content: Text(l10n.deleteHabitConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _repo.deleteHabit(_habits[idx].id);
              _load();
              Navigator.pop(context);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  ({int done, int total, double pct}) _weekStats(Habit habit) {
    final week = _currentWeek();
    int done = 0, total = 0;
    for (final d in week) {
      if (!habit.activeWeekdays.contains(d.weekday)) continue;
      total++;
      if (habit.completedDates.any((c) =>
          c.year == d.year && c.month == d.month && c.day == d.day)) {
        done++;
      }
    }
    return (done: done, total: total, pct: total == 0 ? 0 : done / total);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: _buildAppBar(context, cs, l10n),
      floatingActionButton: PulsingFAB(onTap: _showAddDialog),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _habits.isEmpty ? _buildEmpty(context, l10n) : _buildList(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext ctx, ColorScheme cs, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: cs.background,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myHabits,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cs.onBackground,
            ),
          ),
          Text(
            DateFormat("EEEE, d MMMM", Localizations.localeOf(ctx).toString())
                .format(DateTime.now()),
            style: TextStyle(fontSize: 12, color: cs.onBackground.withOpacity(0.45)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            ),
            child: Icon(Icons.track_changes_rounded,
                size: 56, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text(l10n.noHabits,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            l10n.startBuilding,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.45)),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: Text(l10n.createFirstHabit),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _habits.length,
      itemBuilder: (_, i) => _buildHabitCard(context, i),
    );
  }

  Widget _buildHabitCard(BuildContext context, int idx) {
    final habit = _habits[idx];
    final color = _categoryColor(habit.category);
    final stats = _weekStats(habit);
    final week = _currentWeek();
    final l10n = AppLocalizations.of(context)!;

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: _swipeBackground(l10n),
      confirmDismiss: (_) => _confirmDismiss(context, l10n),
      onDismissed: (_) async {
        await _repo.deleteHabit(habit.id);
        _load();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onLongPressStart: (_) {
            HapticFeedback.mediumImpact();
            setState(() => _pressedIndex = idx);
          },
          onLongPressEnd: (_) => setState(() => _pressedIndex = null),
          onLongPress: () => _showOptions(idx),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 140),
            scale: _pressedIndex == idx ? 0.97 : 1.0,
            child: _HabitCard(
              habit: habit,
              color: color,
              weekDates: week,
              weekStats: stats,
              onDayTap: (date) => _toggleDay(idx, date),
              onTap: () => _openDetails(idx),
            ),
          ),
        ),
      ),
    );
  }

  Widget _swipeBackground(AppLocalizations l10n) => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.withOpacity(0), Colors.red.shade600],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(l10n.delete,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Future<bool?> _confirmDismiss(BuildContext ctx, AppLocalizations l10n) {
    return showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.deleteHabit),
        content: Text(l10n.deleteHabitConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HABIT CARD WIDGET
// ─────────────────────────────────────────────

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final Color color;
  final List<DateTime> weekDates;
  final ({int done, int total, double pct}) weekStats;
  final void Function(DateTime) onDayTap;
  final VoidCallback onTap;

  const _HabitCard({
    required this.habit,
    required this.color,
    required this.weekDates,
    required this.weekStats,
    required this.onDayTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.2), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      habit.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      _getTranslatedCategory(context, habit.category),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: _kDayHeaders
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withOpacity(0.35),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              HabitWeekRow(
                weekDates: weekDates,
                dates: habit.completedDates,
                activeWeekdays: habit.activeWeekdays,
                onTap: onDayTap,
              ),
              const SizedBox(height: 14),
              _WeekProgressBar(
                done: weekStats.done,
                total: weekStats.total,
                pct: weekStats.pct,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WEEK PROGRESS BAR
// ─────────────────────────────────────────────

class _WeekProgressBar extends StatelessWidget {
  final int done, total;
  final double pct;
  final Color color;

  const _WeekProgressBar({
    required this.done,
    required this.total,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.thisWeek,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            ),
            Text(
              "$done / $total ${l10n.days}",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  OPTIONS BOTTOM SHEET
// ─────────────────────────────────────────────

class _OptionsSheet extends StatelessWidget {
  final VoidCallback onView, onEdit, onDelete;

  const _OptionsSheet({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.onSurface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            _SheetTile(
              icon: Icons.bar_chart_rounded,
              label: l10n.viewDetails,
              color: cs.primary,
              onTap: onView,
            ),
            _SheetTile(
              icon: Icons.edit_rounded,
              label: l10n.editHabit,
              color: Colors.orange,
              onTap: onEdit,
            ),
            _SheetTile(
              icon: Icons.delete_outline_rounded,
              label: l10n.deleteHabit,
              color: Colors.red,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────
//  HABIT DETAILS SCREEN
// ─────────────────────────────────────────────

class HabitDetailsScreen extends StatelessWidget {
  final Habit habit;
  final int bestStreak, currentStreak;
  final double monthlyAccuracy, yearlyAccuracy;

  const HabitDetailsScreen({
    super.key,
    required this.habit,
    required this.bestStreak,
    required this.currentStreak,
    required this.monthlyAccuracy,
    required this.yearlyAccuracy,
  });

  List<double> _lastSixMonths() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i));
      int done = 0, total = 0;
      final days = DateTime(m.year, m.month + 1, 0).day;
      for (int d = 1; d <= days; d++) {
        final date = DateTime(m.year, m.month, d);
        if (!habit.activeWeekdays.contains(date.weekday)) continue;
        total++;
        if (habit.completedDates.any((c) =>
            c.year == date.year && c.month == date.month && c.day == date.day)) done++;
      }
      return total == 0 ? 0 : (done / total) * 100;
    });
  }

  void _showCalendar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    DateTime current = DateTime.now();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) {
          final y = current.year;
          final m = current.month;
          final totalDays = DateUtils.getDaysInMonth(y, m);
          final startWD = DateTime(y, m, 1).weekday % 7;

          final List<Widget> cells = [
            ...List.generate(startWD, (_) => const SizedBox()),
            ...List.generate(totalDays, (i) {
              final day = i + 1;
              final date = DateTime(y, m, day);
              final active = habit.activeWeekdays.contains(date.weekday);
              final done = habit.completedDates.any((c) =>
                  c.year == y && c.month == m && c.day == day);

              Color bg;
              if (!active) {
                bg = Colors.grey.shade800;
              } else if (done) {
                bg = Colors.green;
              } else {
                bg = Colors.red.withOpacity(0.3);
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text("$day",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              );
            }),
          ];

          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(20),
            height: 520,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => set(() => current = DateTime(y, m - 1)),
                    ),
                    Text(
                      DateFormat.yMMMM(Localizations.localeOf(context).toString())
                          .format(current),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () => set(() => current = DateTime(y, m + 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(d,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    children: cells,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(color: Colors.green, label: l10n.done),
                    const SizedBox(width: 16),
                    _LegendDot(color: Colors.red.withOpacity(0.5), label: l10n.missed),
                    const SizedBox(width: 16),
                    _LegendDot(color: Colors.grey.shade800, label: l10n.inactive),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _categoryColor(habit.category);
    final cs = Theme.of(context).colorScheme;
    final chartData = _lastSixMonths();
    final now = DateTime.now();
    final monthNames = List.generate(
        6,
        (i) => DateFormat.MMM(Localizations.localeOf(context).toString())
            .format(DateTime(now.year, now.month - (5 - i))));

    return Scaffold(
      backgroundColor: cs.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
              title: Text(
                habit.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.9),
                          color,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: 40,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 90,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _getTranslatedCategory(context, habit.category),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(context, color),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: l10n.lastSixMonths,
                    trailing: _iconBtn(
                      context,
                      icon: Icons.calendar_month_rounded,
                      onTap: () => _showCalendar(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChart(context, chartData, monthNames, color),
                  const SizedBox(height: 12),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            )),
                        const SizedBox(width: 6),
                        Text(
                          l10n.completionRate,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onBackground.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color color) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (
        title: l10n.currentStreak,
        value: "$currentStreak ${l10n.days}",
        icon: Icons.local_fire_department_rounded,
        color: Colors.orange,
      ),
      (
        title: l10n.bestStreak,
        value: "$bestStreak ${l10n.days}",
        icon: Icons.emoji_events_rounded,
        color: Colors.amber,
      ),
      (
        title: l10n.monthly,
        value: "${monthlyAccuracy.toStringAsFixed(0)}%",
        icon: Icons.calendar_today_rounded,
        color: Colors.green,
      ),
      (
        title: l10n.yearly,
        value: "${yearlyAccuracy.toStringAsFixed(0)}%",
        icon: Icons.trending_up_rounded,
        color: Colors.blue,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2,
      children: items
          .map((e) => _StatTile(
                title: e.title,
                value: e.value,
                icon: e.icon,
                color: e.color,
              ))
          .toList(),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<double> data,
    List<String> labels,
    Color color,
  ) {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: 100,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.grey.withOpacity(0.12),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text(
                  "${v.toInt()}%",
                  style: TextStyle(fontSize: 10, color: Colors.grey.withOpacity(0.6)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i],
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.withOpacity(0.7))),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: data.asMap().entries.map((e) {
            final isLast = e.key == data.length - 1;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  width: 28,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isLast
                        ? [color, color.withOpacity(0.85)]
                        : [
                            color.withOpacity(0.35),
                            color.withOpacity(0.55),
                          ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _iconBtn(BuildContext ctx, {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED SMALL WIDGETS
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          if (trailing != null) trailing!,
        ],
      );
}

class _StatTile extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        ],
      );
}

// ─────────────────────────────────────────────
//  STATS CARD (backward compat, still exported)
// ─────────────────────────────────────────────

class StatsCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => _StatTile(
        title: title,
        value: value,
        icon: icon,
        color: color,
      );
}
