import 'package:flutter/material.dart';
import 'package:flutcanvas/features/comments/domain/models/board_comment.dart';

/// A sleek floating pin badge widget rendered on top of the whiteboard canvas.
class CommentPinBadge extends StatelessWidget {
  const CommentPinBadge({
    super.key,
    required this.comment,
    required this.isSelected,
    required this.onTap,
  });

  final BoardComment comment;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pinColor = comment.isResolved
        ? const Color(0xFF10B981) // Emerald Green
        : (comment.colorValue != null
            ? Color(comment.colorValue!)
            : theme.colorScheme.primary);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isSelected ? 34 : 28,
          height: isSelected ? 34 : 28,
          decoration: BoxDecoration(
            color: comment.isResolved ? pinColor.withValues(alpha: 0.9) : pinColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? pinColor.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.25),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: comment.isResolved
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  )
                : Text(
                    '${comment.pinNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
