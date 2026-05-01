import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:flutter/material.dart';

class LoadErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String title;
  final bool compact;

  const LoadErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title = "Couldn't load",
    this.compact = false,
  });

  factory LoadErrorView.fromError(
    Object? error, {
    VoidCallback? onRetry,
    String title = "Couldn't load",
    bool compact = false,
  }) {
    return LoadErrorView(
      message: errorMessageForUi(error),
      onRetry: onRetry,
      title: title,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final iconSize = compact ? 40.0 : 56.0;

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_off_outlined,
          size: iconSize,
          color: scheme.onSurfaceVariant,
        ),
        SizedBox(height: compact ? 12 : 16),
        Text(
          title,
          style: (compact
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.titleMedium)
              ?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: compact ? 6 : 8),
        Text(
          message,
          style: (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
              ?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          SizedBox(height: compact ? 12 : 24),
          if (compact)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
            )
          else
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
        ],
      ],
    );

    return compact
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: body,
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: body,
          );
  }
}
