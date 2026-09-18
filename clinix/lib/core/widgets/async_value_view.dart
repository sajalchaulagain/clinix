import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_empty_state.dart';
import 'app_error_view.dart';
import 'app_loading.dart';

/// Removes the repeated `value.when(...)` boilerplate on data screens.
///
/// Handles loading / error (with retry) / data, and optionally empty lists.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.loading,
    this.emptyIcon,
    this.emptyTitle,
    this.emptyMessage,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final Widget? loading;

  // Empty state is applied when T is a List and the list is empty.
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading ?? const AppLoading(),
      error: (error, _) => AppErrorView(error: error, onRetry: onRetry),
      data: (data) {
        if (data is List && data.isEmpty && emptyTitle != null) {
          return AppEmptyState(
            icon: emptyIcon ?? Icons.inbox_outlined,
            title: emptyTitle!,
            message: emptyMessage,
          );
        }
        return builder(data);
      },
    );
  }
}
