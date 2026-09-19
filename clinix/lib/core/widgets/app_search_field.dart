import 'package:flutter/material.dart';

import '../utils/debouncer.dart';

/// Search text field with built-in debouncing.
///
/// Once backend search endpoints exist, the debounced [onChanged] keeps
/// request volume sane; today it just filters mock lists locally.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.initialValue,
    this.enabled = true,
  });

  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? initialValue;
  final bool enabled;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  final Debouncer _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      textInputAction: TextInputAction.search,
      onChanged: (value) =>
          _debouncer.run(() => widget.onChanged?.call(value)),
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _controller.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                ),
        ),
      ),
    );
  }
}

/// Tappable, non-editable search bar (dashboard entry point). Navigates to a
/// real search surface when tapped.
class SearchEntryField extends StatelessWidget {
  const SearchEntryField({super.key, required this.hint, this.onTap});

  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
