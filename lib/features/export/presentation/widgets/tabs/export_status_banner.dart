import 'package:flutter/material.dart';

/// Toast banner displaying success confirmation or error feedback.
class ExportStatusBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const ExportStatusBanner({
    super.key,
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isError
            ? scheme.errorContainer.withValues(alpha: 0.7)
            : (isDark
                ? scheme.primaryContainer.withValues(alpha: 0.3)
                : const Color(0xFFEBFBEE)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isError
              ? scheme.error.withValues(alpha: 0.5)
              : (isDark
                  ? scheme.primary.withValues(alpha: 0.3)
                  : const Color(0xFFB2F2BB)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_rounded,
            size: 16,
            color: isError ? scheme.error : const Color(0xFF2B8A3E),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isError
                    ? scheme.onErrorContainer
                    : (isDark
                        ? scheme.onPrimaryContainer
                        : const Color(0xFF2B8A3E)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
