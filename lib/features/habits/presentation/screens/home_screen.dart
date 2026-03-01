import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:habitflow/l10n/app_localizations.dart';
import '../../../tasks/data/task_repository.dart';
import '../../../tasks/data/task_datasource.dart';
import 'package:habitflow/features/tasks/domain/task.dart';
import 'package:habitflow/core/constants/task_categories.dart';
import 'package:habitflow/widgets/progress_ring.dart';
import '/../widgets/pulsing_fab.dart';
import 'package:habitflow/core/theme/theme_controller.dart';

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final ThemeController themeController;

  const HomeScreen({
    super.key,
    required this.themeController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TaskRepository _repo = TaskRepository(TaskDatasource());

  DateTime _selectedDate = DateTime.now();
  List<Task> _tasks = [];
  int? _pressedIndex;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _tasks = _repo.getTasks());
  }

  List<Task> get _tasksForDate => _tasks.where((t) {
        return t.date.year == _selectedDate.year &&
            t.date.month == _selectedDate.month &&
            t.date.day == _selectedDate.day;
      }).toList();

  Color _colorOf(String category) {
    final match = taskCategories.firstWhere(
      (c) => c.name == category,
      orElse: () => taskCategories.first,
    );
    return match.color;
  }

  String _getTranslatedCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case "General": return l10n.general;
      case "Work": return l10n.work;
      case "Study": return l10n.study;
      case "Health": return l10n.health;
      case "Fitness": return l10n.fitness;
      case "Finance": return l10n.finance;
      case "Family": return l10n.family;
      case "Spiritual": return l10n.spiritual;
      case "Projects": return l10n.projects;
      case "Reading": return l10n.reading;
      case "Business": return l10n.business;
      case "Personal": return l10n.personal;
      case "Travel": return l10n.travel;
      case "Learning": return l10n.learning;
      case "Coding": return l10n.coding;
      case "Creative": return l10n.creative;
      case "Social": return l10n.social;
      case "Mindset": return l10n.mindset;
      default: return category;
    }
  }

  // ── Task dialog ────────────────────────────

  void _showTaskDialog({Task? existing}) {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: existing?.title ?? '');
    String cat = existing?.category ?? taskCategories.first.name;
    DateTime date = existing?.date ?? _selectedDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            existing == null ? l10n.newTask : l10n.editTask,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.taskName,
                    filled: true,
                    fillColor: Theme.of(ctx).colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.task_alt_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.category,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: cat,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(ctx).colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  items: taskCategories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.name,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: c.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(_getTranslatedCategory(context, c.name)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => set(() => cat = v!),
                ),
                const SizedBox(height: 16),
                Text(l10n.date,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) set(() => date = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18,
                            color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat("EEE, d MMM yyyy", Localizations.localeOf(context).toString())
                              .format(date),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
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
                final t = (existing ??
                        Task(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: '',
                          date: date,
                          isDone: false,
                          category: cat,
                        ))
                    .copyWith(
                  title: ctrl.text.trim(),
                  category: cat,
                  date: date,
                );
                await _repo.addTask(t);
                _load();
                Navigator.pop(context);
              },
              child: Text(existing == null ? l10n.create : l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  // ── Planner calendar ───────────────────────

  void _showPlanner() {
    DateTime temp = _selectedDate;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) {
          final y = temp.year;
          final m = temp.month;
          final totalDays = DateUtils.getDaysInMonth(y, m);
          final firstWD = DateTime(y, m, 1).weekday - 1;
          final cs = Theme.of(ctx).colorScheme;

          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CalNavBtn(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => set(() => temp = DateTime(y, m - 1)),
                    ),
                    Text(
                      DateFormat('MMMM yyyy', Localizations.localeOf(context).toString())
                          .format(temp),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    _CalNavBtn(
                      icon: Icons.chevron_right_rounded,
                      onTap: () => set(() => temp = DateTime(y, m + 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(d,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface.withOpacity(0.35),
                                  )),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 280,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: firstWD + totalDays,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemBuilder: (_, i) {
                      if (i < firstWD) return const SizedBox();
                      final day = i - firstWD + 1;
                      final date = DateTime(y, m, day);
                      final isSelected = date.year == _selectedDate.year &&
                          date.month == _selectedDate.month &&
                          date.day == _selectedDate.day;
                      final isToday = date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day;
                      final hasTasks = _tasks.any((t) =>
                          t.date.year == y && t.date.month == m && t.date.day == day);

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDate = date);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cs.primary
                                : isToday
                                    ? cs.primary.withOpacity(0.12)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                "$day",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                                  color: isSelected ? Colors.white : cs.onSurface,
                                ),
                              ),
                              if (hasTasks && !isSelected)
                                Positioned(
                                  bottom: 4,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _tasksForDate;
    final done = filtered.where((t) => t.isDone).length;
    double progress = 0.0;

    if (filtered.isNotEmpty) {
      progress = done / filtered.length;
    }

    if (progress.isNaN || progress.isInfinite) {
      progress = 0.0;
    }
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: cs.background,
      floatingActionButton: PulsingFAB(onTap: () => _showTaskDialog()),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          _buildHeader(context, cs, isDark, filtered, done, progress, isToday, l10n),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmpty(context, isToday, l10n)
                : _buildTaskList(context, filtered, l10n),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    ColorScheme cs,
    bool isDark,
    List<Task> filtered,
    int done,
    double progress,
    bool isToday,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday
                          ? l10n.today
                          : DateFormat("EEEE", Localizations.localeOf(context).toString())
                              .format(_selectedDate),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _showPlanner,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 13, color: cs.onSurface.withOpacity(0.4)),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat("d MMMM yyyy", Localizations.localeOf(context).toString())
                                .format(_selectedDate),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface.withOpacity(0.45),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16, color: cs.onSurface.withOpacity(0.3)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ThemeToggle(controller: widget.themeController),
                  const SizedBox(height: 8),
                  if (filtered.isNotEmpty)
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ProgressRing(
                            percentage: (progress * 100).clamp(0, 100),
                            size: 48,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _NavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => setState(
                    () => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TodayButton(
                  isToday: isToday,
                  onTap: () => setState(() => _selectedDate = DateTime.now()),
                ),
              ),
              const SizedBox(width: 10),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () =>
                    setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
              ),
            ],
          ),
          if (filtered.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DailyProgressBar(
              done: done,
              total: filtered.length,
              progress: progress,
            ),
          ],
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────

  Widget _buildEmpty(BuildContext context, bool isToday, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withOpacity(0.07),
            ),
            child: Icon(Icons.task_alt_rounded, size: 52, color: cs.primary.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),
          Text(
            isToday ? l10n.noTasks : l10n.noTasksDay,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            isToday ? l10n.tapToAddFirst : l10n.nothingPlanned,
            style: TextStyle(fontSize: 13, color: cs.onBackground.withOpacity(0.4)),
          ),
          if (isToday) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showTaskDialog(),
              icon: const Icon(Icons.add),
              label: Text(l10n.addTask),
            ),
          ],
        ],
      ),
    );
  }

  // ── Task list ──────────────────────────────

  Widget _buildTaskList(BuildContext context, List<Task> tasks, AppLocalizations l10n) {
    final pending = tasks.where((t) => !t.isDone).toList();
    final completed = tasks.where((t) => t.isDone).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        if (pending.isNotEmpty) ...[
          _SectionLabel(
            label: l10n.pending,
            count: pending.length,
            color: Theme.of(context).colorScheme.primary,
          ),
          ...pending
              .asMap()
              .entries
              .map((e) => _buildTaskTile(context, e.value, tasks.indexOf(e.value), l10n)),
        ],
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 8),
          _SectionLabel(
            label: l10n.completed,
            count: completed.length,
            color: Colors.green,
          ),
          ...completed
              .asMap()
              .entries
              .map((e) => _buildTaskTile(context, e.value, tasks.indexOf(e.value), l10n)),
        ],
      ],
    );
  }

  Widget _buildTaskTile(BuildContext context, Task task, int idx, AppLocalizations l10n) {
    final color = _colorOf(task.category);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: _SwipeBackground(l10n: l10n),
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) async {
        await _repo.deleteTask(task.id);
        _load();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showTaskDialog(existing: task);
          },
          child: _TaskCard(
            task: task,
            color: color,
            categoryLabel: _getTranslatedCategory(context, task.category),
            onToggle: () async {
              await _repo.addTask(task.copyWith(isDone: !task.isDone));
              _load();
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TASK CARD
// ─────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final Task task;
  final Color color;
  final String categoryLabel;
  final VoidCallback onToggle;

  const _TaskCard({
    required this.task,
    required this.color,
    required this.categoryLabel,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final done = task.isDone;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: done ? cs.surface.withOpacity(0.5) : cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: done ? cs.onSurface.withOpacity(0.06) : color.withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: done
            ? []
            : [
                BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 3,
            height: 38,
            decoration: BoxDecoration(
              color: done ? cs.onSurface.withOpacity(0.15) : color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: done ? cs.onSurface.withOpacity(0.35) : cs.onSurface,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: cs.onSurface.withOpacity(0.35),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: done ? cs.onSurface.withOpacity(0.2) : color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      categoryLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: done ? cs.onSurface.withOpacity(0.3) : color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? color : Colors.transparent,
                border: Border.all(
                  color: done ? color : cs.onSurface.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DAILY PROGRESS BAR
// ─────────────────────────────────────────────

class _DailyProgressBar extends StatelessWidget {
  final int done, total;
  final double progress;

  const _DailyProgressBar({
    required this.done,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final pct = (progress * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$done ${l10n.ofTotal} $total ${l10n.tasksDone}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cs.onSurface.withOpacity(0.45),
              ),
            ),
            Text(
              "$pct%",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: progress == 1.0 ? Colors.green : cs.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: cs.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(
              progress == 1.0 ? Colors.green : cs.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  SECTION LABEL
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SectionLabel({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.45),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              "$count",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SWIPE BACKGROUND
// ─────────────────────────────────────────────

class _SwipeBackground extends StatelessWidget {
  final AppLocalizations l10n;
  const _SwipeBackground({required this.l10n});

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.withOpacity(0), Colors.red.shade600],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            const SizedBox(height: 3),
            Text(l10n.delete,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
//  CALENDAR NAV BUTTON
// ─────────────────────────────────────────────

class _CalNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CalNavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: cs.onSurface),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NAV BUTTON
// ─────────────────────────────────────────────

class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.onSurface.withOpacity(0.07)),
          ),
          child: Icon(widget.icon, size: 22, color: cs.onSurface),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TODAY BUTTON
// ─────────────────────────────────────────────

class _TodayButton extends StatefulWidget {
  final bool isToday;
  final VoidCallback onTap;

  const _TodayButton({required this.isToday, required this.onTap});

  @override
  State<_TodayButton> createState() => _TodayButtonState();
}

class _TodayButtonState extends State<_TodayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 44,
          decoration: BoxDecoration(
            color: widget.isToday ? cs.primary.withOpacity(0.12) : cs.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isToday ? cs.primary.withOpacity(0.3) : cs.onSurface.withOpacity(0.07),
            ),
          ),
          child: Center(
            child: Text(
              l10n.today,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: widget.isToday ? cs.primary : cs.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  THEME TOGGLE
// ─────────────────────────────────────────────

class _ThemeToggle extends StatelessWidget {
  final ThemeController controller;

  const _ThemeToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = controller.themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: () => controller.setTheme(isDark ? ThemeMode.light : ThemeMode.dark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        width: 60,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFF6FCF97),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 2,
              top: 0,
              bottom: 0,
              child: Icon(Icons.dark_mode_rounded,
                  size: 14,
                  color:
                      isDark ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.3)),
            ),
            Positioned(
              right: 2,
              top: 0,
              bottom: 0,
              child: Icon(Icons.light_mode_rounded,
                  size: 14,
                  color:
                      isDark ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.8)),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              alignment: isDark ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
