import 'package:intl/intl.dart';

/// Centralised date/time formatting so every screen renders dates the same way.
class DateFormatters {
  DateFormatters._();

  static final DateFormat _date = DateFormat('d MMM yyyy');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, h:mm a');
  static final DateFormat _time = DateFormat('h:mm a');

  static String date(DateTime value) => _date.format(value);
  static String dateTime(DateTime value) => _dateTime.format(value);
  static String time(DateTime value) => _time.format(value);

  /// Formats a "HH:mm" stored reminder time (24h) for display, e.g. 8:00 AM.
  static String reminderTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return hhmm;
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
    return _time.format(dt);
  }

  /// Friendly relative label used in lists ("Just now", "3h ago", ...).
  static String relative(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(value);
  }

  /// "HH:mm" (24h) storage format for reminder times.
  static String toHhMm(DateTime value) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
