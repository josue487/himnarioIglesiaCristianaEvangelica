import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Decides when to gently remind the user about donating: never in the first
/// launches, at most once every [_minDays] days, and then only by chance.
class DonationPromptService {
  static const _launchesKey = 'donation_launches';
  static const _lastShownKey = 'donation_last_shown';
  static const _minLaunches = 4;
  static const _minDays = 7;
  static const _chance = 0.3;

  Future<bool> shouldPrompt({Random? random}) async {
    final prefs = await SharedPreferences.getInstance();
    final launches = (prefs.getInt(_launchesKey) ?? 0) + 1;
    await prefs.setInt(_launchesKey, launches);
    if (launches < _minLaunches) return false;

    final last = prefs.getInt(_lastShownKey);
    if (last != null) {
      final days = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(last))
          .inDays;
      if (days < _minDays) return false;
    }
    return (random ?? Random()).nextDouble() < _chance;
  }

  Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastShownKey, DateTime.now().millisecondsSinceEpoch);
  }
}
