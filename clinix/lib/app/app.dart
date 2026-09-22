import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/services/app_update_service.dart';
import '../features/settings/providers/settings_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget. Watches [themeModeProvider] so dark mode applies app-wide.
class CliniXApp extends ConsumerStatefulWidget {
  const CliniXApp({super.key});

  @override
  ConsumerState<CliniXApp> createState() => _CliniXAppState();
}

class _CliniXAppState extends ConsumerState<CliniXApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        checkAndShowUpdateDialog(context, ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
