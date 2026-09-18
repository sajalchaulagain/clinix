import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_storage_service.dart';

/// Theme mode with persistence. `CliniXApp` watches this to switch themes.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.watch(localStorageServiceProvider);
    final stored = storage.getString(PrefsKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref
        .read(localStorageServiceProvider)
        .setString(PrefsKeys.themeMode, mode.name);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Selected language code ('en' now, 'ne' prepared).
/// LOCALIZATION: wire to AppLocalizations once ARB files exist.
class LanguageNotifier extends Notifier<String> {
  @override
  String build() {
    return ref
            .watch(localStorageServiceProvider)
            .getString(PrefsKeys.languageCode) ??
        'en';
  }

  Future<void> setLanguage(String code) async {
    state = code;
    await ref
        .read(localStorageServiceProvider)
        .setString(PrefsKeys.languageCode, code);
  }
}

final languageProvider =
    NotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);

/// Master notification preference (local reminders + future push handling).
class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref
        .watch(localStorageServiceProvider)
        .getBool(PrefsKeys.notificationsEnabled, defaultValue: true);
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await ref
        .read(localStorageServiceProvider)
        .setBool(PrefsKeys.notificationsEnabled, enabled);
  }
}

final notificationsEnabledProvider = NotifierProvider<
    NotificationsEnabledNotifier, bool>(NotificationsEnabledNotifier.new);
