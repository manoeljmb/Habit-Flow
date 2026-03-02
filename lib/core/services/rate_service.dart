import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:habitflow/l10n/app_localizations.dart';

class RateService {
  static const String _startTimeKey = 'app_first_launch_time';
  static const String _alreadyRatedKey = 'app_already_rated';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_startTimeKey) == null) {
      await prefs.setInt(_startTimeKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> checkAndShowRateDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final bool alreadyRated = prefs.getBool(_alreadyRatedKey) ?? false;
    if (alreadyRated) return;

    final int? startTime = prefs.getInt(_startTimeKey);
    if (startTime == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final thirtyMinutesInMs = 30 * 60 * 1000;

    if (now - startTime >= thirtyMinutesInMs) {
      if (!context.mounted) return;
      _showDialog(context, prefs);
    }
  }

  void _showDialog(BuildContext context, SharedPreferences prefs) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.rateAppTitle),
        content: Text(l10n.rateAppMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.rateLater),
          ),
          FilledButton(
            onPressed: () async {
              await prefs.setBool(_alreadyRatedKey, true);
              // Aqui você abriria a URL da Play Store
              // ignore: use_build_context_synchronously
              Navigator.pop(ctx);
            },
            child: Text(l10n.rateNow),
          ),
        ],
      ),
    );
  }
}
