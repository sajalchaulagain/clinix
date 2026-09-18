import 'dart:async';

import 'package:flutter/foundation.dart';

/// Debounces rapid calls (e.g. search keystrokes) so that once a backend is
/// connected we do not fire a request per character.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() => _timer?.cancel();

  void dispose() => _timer?.cancel();
}
