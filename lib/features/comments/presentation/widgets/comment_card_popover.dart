import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutcanvas/features/comments/domain/models/board_comment.dart';

/// Floating popover card for viewing, composing, and replying to a canvas comment.
class CommentCardPopover extends StatefulWidget {
  const CommentCardPopover({
    super.key,
    required this.comment,
    required this.screenPosition,
    required this.viewSize,
    required this.onAddReply,
    required this.onToggleResolved,
    required this.onDeleteComment,
    required this.onSaveInitialText,
    required this.onClose,
  });

  final BoardComment comment;
  final Offset screenPosition;
  final Size viewSize;
  final void Function(String text) onAddReply;
  final VoidCallback onToggleResolved;
  final VoidCallback onDeleteComment;
  final void Function(String text) onSaveInitialText;
  final VoidCallback onClose;

  @override
  State<CommentCardPopover> createState() => _CommentCardPopoverState();
}

class _CommentCardPopoverState extends State<CommentCardPopover> {
  final TextEditingController _replyController = TextEditingController();
  final TextEditingController _initialTextController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  final FocusNode _initialFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialTextController.text = widget.comment.text;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.comment.text.trim().isEmpty) {
        _initialFocusNode.requestFocus();
      } else {
        _replyFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _initialTextController.dispose();
    _replyFocusNode.dispose();
    _initialFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitInitialText() {
    final text = _initialTextController.text.trim();
    if (text.isNotEmpty) {
      widget.onSaveInitialText(text);
    } else {
      widget.onDeleteComment();
    }
  }

  void _submitReply() {
    final text = _replyController.text.trim();
    if (text.isNotEmpty) {
      widget.onAddReply(text);
      _replyController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isComposingInitial = widget.comment.text.trim().isEmpty;

    // Calculate clamped screen position (width: 300)
    const cardWidth = 300.0;
    const cardMaxHeight = 360.0;

    double left = widget.screenPosition.dx + 16;
    double top = widget.screenPosition.dy - 12;

    if (left + cardWidth > widget.viewSize.width - 12) {
      left = math.max(12, widget.screenPosition.dx - cardWidth - 16);
    }
    if (top + cardMaxHeight > widget.viewSize.height - 12) {
      top = math.max(64, widget.viewSize.height - cardMaxHeight - 12);
    }
    left = left.clamp(12.0, math.max(12.0, widget.viewSize.width - cardWidth - 12));
    top = top.clamp(64.0, math.max(64.0, widget.viewSize.height - cardMaxHeight - 12));

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: scheme.surfaceContainerHigh,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: cardWidth,
          constraints: const BoxConstraints(maxHeight: cardMaxHeight),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: isComposingInitial
              ? _buildInitialComposer(scheme)
              : _buildThreadView(scheme),
        ),
      ),
    );
  }

  Widget _buildInitialComposer(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: scheme.primary,
                child: Text(
                  '${widget.comment.pinNumber}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Add Comment #${widget.comment.pinNumber}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: widget.onDeleteComment,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _initialTextController,
            focusNode: _initialFocusNode,
            maxLines: 3,
            minLines: 2,
            style: TextStyle(fontSize: 13, color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Type your feedback or note here...',
              hintStyle: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
              isDense: true,
              filled: true,
              fillColor: scheme.surface,
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: scheme.primary, width: 1.5),
              ),
            ),
            onSubmitted: (_) => _submitInitialText(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onDeleteComment,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: scheme.onSurfaceVariant,
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: _submitInitialText,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.send_rounded, size: 13),
                label: const Text('Post', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThreadView(ColorScheme scheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.comment.isResolved
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : scheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.comment.isResolved ? Icons.check_circle_rounded : Icons.chat_bubble_rounded,
                      size: 11,
                      color: widget.comment.isResolved ? const Color(0xFF10B981) : scheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '#${widget.comment.pinNumber}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.comment.isResolved ? const Color(0xFF10B981) : scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.comment.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '· ${widget.comment.timeAgo}',
                      style: TextStyle(
                        fontSize: 10,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Resolve Button
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                tooltip: widget.comment.isResolved ? 'Reopen Comment' : 'Mark Resolved',
                onPressed: widget.onToggleResolved,
                icon: Icon(
                  widget.comment.isResolved ? Icons.replay_rounded : Icons.check_circle_outline_rounded,
                  color: widget.comment.isResolved ? const Color(0xFF10B981) : scheme.onSurfaceVariant,
                ),
              ),
              // Delete Button
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                tooltip: 'Delete Comment',
                onPressed: widget.onDeleteComment,
                icon: Icon(Icons.delete_outline_rounded, color: scheme.error.withValues(alpha: 0.8)),
              ),
              // Close Button
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                tooltip: 'Close',
                onPressed: widget.onClose,
                icon: Icon(Icons.close_rounded, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),

        // Scrollable Thread Content
        Flexible(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main comment body
                SelectableText(
                  widget.comment.text,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: scheme.onSurface,
                    decoration: widget.comment.isResolved ? TextDecoration.lineThrough : null,
                  ),
                ),

                // Replies
                if (widget.comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  for (final r in widget.comment.replies)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: scheme.outlineVariant.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  r.author,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.primary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  r.createdAt.difference(DateTime.now()).abs().inMinutes < 1
                                      ? 'Just now'
                                      : '${r.createdAt.difference(DateTime.now()).abs().inMinutes}m ago',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            SelectableText(
                              r.text,
                              style: TextStyle(fontSize: 12, color: scheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),

        const Divider(height: 1),
        // Reply Input Bar
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  focusNode: _replyFocusNode,
                  style: TextStyle(fontSize: 12, color: scheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Reply...',
                    hintStyle: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: scheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: scheme.primary, width: 1.2),
                    ),
                  ),
                  onSubmitted: (_) => _submitReply(),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                tooltip: 'Send Reply (Enter)',
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  padding: const EdgeInsets.all(8),
                ),
                onPressed: _submitReply,
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
