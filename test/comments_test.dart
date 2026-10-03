import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/models/board_comment.dart';
import 'package:flutcanvas/models/board_document.dart';
import 'package:flutcanvas/ui/widgets/comment_card_popover.dart';
import 'package:flutcanvas/ui/widgets/comment_pin_badge.dart';
import 'package:flutcanvas/ui/widgets/layers_sidebar.dart';

void main() {
  group('BoardComment & CommentReply Data Model Tests', () {
    test('creates BoardComment and adds threaded replies', () {
      final comment = BoardComment(
        id: 'c1',
        worldPosition: const Offset(120, 240),
        pinNumber: 1,
        author: 'Alice',
        text: 'Should we change this button to primary color?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(comment.id, 'c1');
      expect(comment.worldPosition, const Offset(120, 240));
      expect(comment.pinNumber, 1);
      expect(comment.author, 'Alice');
      expect(comment.isResolved, isFalse);
      expect(comment.replies.length, 0);
      expect(comment.totalReplies, 0);
      expect(comment.timeAgo, contains('m ago'));

      // Add reply
      final withReply = comment.addReply(
        author: 'Bob',
        text: 'Agreed, updating it now!',
      );

      expect(withReply.replies.length, 1);
      expect(withReply.replies.first.author, 'Bob');
      expect(withReply.replies.first.text, 'Agreed, updating it now!');
      expect(withReply.totalReplies, 1);

      // Add another reply
      final withTwoReplies = withReply.addReply(
        author: 'Alice',
        text: 'Thanks Bob!',
      );
      expect(withTwoReplies.replies.length, 2);

      // Remove reply
      final replyIdToRemove = withTwoReplies.replies.first.id;
      final withRemovedReply = withTwoReplies.removeReply(replyIdToRemove);
      expect(withRemovedReply.replies.length, 1);
      expect(withRemovedReply.replies.first.text, 'Thanks Bob!');
    });

    test('toggles resolved status correctly', () {
      final comment = BoardComment(
        id: 'c2',
        worldPosition: const Offset(300, 150),
        pinNumber: 2,
        author: 'Charlie',
        text: 'Check margin on mobile screen',
        createdAt: DateTime.now(),
      );

      expect(comment.isResolved, isFalse);

      final resolved = comment.toggleResolved();
      expect(resolved.isResolved, isTrue);

      final reopened = resolved.toggleResolved();
      expect(reopened.isResolved, isFalse);
    });

    test('serializes and deserializes BoardComment to and from JSON', () {
      final original = BoardComment(
        id: 'c_test_json',
        worldPosition: const Offset(450.5, 600.25),
        pinNumber: 3,
        author: 'Designer',
        text: 'Align this card with grid',
        createdAt: DateTime(2026, 10, 1, 14, 30),
        isResolved: true,
        colorValue: 0xFFEF4444,
        replies: [
          CommentReply(
            id: 'r_1',
            author: 'Developer',
            text: 'Aligned to 8pt grid.',
            createdAt: DateTime(2026, 10, 1, 15, 0),
          ),
        ],
      );

      final map = original.toMap();
      final fromMap = BoardComment.fromMap(map);

      expect(fromMap.id, original.id);
      expect(fromMap.worldPosition, original.worldPosition);
      expect(fromMap.pinNumber, 3);
      expect(fromMap.author, 'Designer');
      expect(fromMap.text, 'Align this card with grid');
      expect(fromMap.isResolved, isTrue);
      expect(fromMap.colorValue, 0xFFEF4444);
      expect(fromMap.replies.length, 1);
      expect(fromMap.replies.first.author, 'Developer');
      expect(fromMap.replies.first.text, 'Aligned to 8pt grid.');

      final jsonStr = original.toJson();
      final fromJson = BoardComment.fromJson(jsonStr);
      expect(fromJson.id, original.id);
      expect(fromJson.text, original.text);
    });
  });

  group('BoardDocument Comments Integration Tests', () {
    test('BoardDocument stores, updates, and serializes comments list', () {
      final doc = BoardDocument(
        id: 'board_comments_doc',
        title: 'Review Board',
        elements: [],
        comments: [
          BoardComment(
            id: 'c_doc_1',
            worldPosition: const Offset(100, 100),
            pinNumber: 1,
            author: 'Lead',
            text: 'Initial review note',
            createdAt: DateTime.now(),
          ),
        ],
      );

      expect(doc.comments.length, 1);
      expect(doc.comments.first.pinNumber, 1);

      // copyWith
      final updatedDoc = doc.copyWith(
        comments: [
          ...doc.comments,
          BoardComment(
            id: 'c_doc_2',
            worldPosition: const Offset(200, 200),
            pinNumber: 2,
            author: 'Reviewer',
            text: 'Second note',
            createdAt: DateTime.now(),
          ),
        ],
      );
      expect(updatedDoc.comments.length, 2);

      // JSON roundtrip
      final docMap = updatedDoc.toMap();
      final docFromMap = BoardDocument.fromMap(docMap);
      expect(docFromMap.comments.length, 2);
      expect(docFromMap.comments[0].id, 'c_doc_1');
      expect(docFromMap.comments[1].id, 'c_doc_2');
    });
  });

  group('CommentPinBadge Widget Tests', () {
    testWidgets('renders pin number when open and checkmark when resolved', (tester) async {
      bool tapped = false;
      final openComment = BoardComment(
        id: 'pin1',
        worldPosition: const Offset(50, 50),
        pinNumber: 7,
        author: 'Tester',
        text: 'Open comment',
        createdAt: DateTime.now(),
        isResolved: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CommentPinBadge(
                comment: openComment,
                isSelected: false,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('7'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);

      await tester.tap(find.text('7'));
      expect(tapped, isTrue);

      // Now test resolved pin badge
      final resolvedComment = openComment.toggleResolved();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CommentPinBadge(
                comment: resolvedComment,
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });

  group('CommentCardPopover Widget Tests', () {
    testWidgets('renders initial composer for blank draft comment and submits text', (tester) async {
      String savedText = '';
      bool deleted = false;

      final draftComment = BoardComment(
        id: 'draft1',
        worldPosition: const Offset(100, 100),
        pinNumber: 1,
        author: 'User',
        text: '',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                CommentCardPopover(
                  comment: draftComment,
                  screenPosition: const Offset(100, 100),
                  viewSize: const Size(1200, 800),
                  onAddReply: (_) {},
                  onToggleResolved: () {},
                  onDeleteComment: () => deleted = true,
                  onSaveInitialText: (t) => savedText = t,
                  onClose: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Add Comment #1'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'My first comment on this section');
      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();

      expect(savedText, 'My first comment on this section');
      expect(deleted, isFalse);
    });

    testWidgets('renders full thread, adds reply, toggles resolve, and deletes', (tester) async {
      String addedReply = '';
      bool resolvedToggled = false;
      bool deleted = false;
      bool closed = false;

      final comment = BoardComment(
        id: 'thread1',
        worldPosition: const Offset(150, 150),
        pinNumber: 2,
        author: 'Alex',
        text: 'Please review this component hierarchy',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        replies: [
          CommentReply(
            id: 'r1',
            author: 'Dana',
            text: 'Looks clean to me!',
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                CommentCardPopover(
                  comment: comment,
                  screenPosition: const Offset(150, 150),
                  viewSize: const Size(1200, 800),
                  onAddReply: (r) => addedReply = r,
                  onToggleResolved: () => resolvedToggled = true,
                  onDeleteComment: () => deleted = true,
                  onSaveInitialText: (_) {},
                  onClose: () => closed = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('#2'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('Please review this component hierarchy'), findsOneWidget);
      expect(find.text('Dana'), findsOneWidget);
      expect(find.text('Looks clean to me!'), findsOneWidget);

      // Enter a new reply
      await tester.enterText(find.byType(TextField), 'Great, ready for merge.');
      await tester.tap(find.byIcon(Icons.send_rounded));
      expect(addedReply, 'Great, ready for merge.');

      // Toggle resolve
      await tester.tap(find.byTooltip('Mark Resolved'));
      expect(resolvedToggled, isTrue);

      // Delete
      await tester.tap(find.byTooltip('Delete Comment'));
      expect(deleted, isTrue);

      // Close
      await tester.tap(find.byTooltip('Close'));
      expect(closed, isTrue);
    });
  });

  group('LayersSidebar Comments Tab Integration Tests', () {
    testWidgets('renders comments in sidebar, switches tabs, and filters by open/resolved', (tester) async {
      String selectedCommentId = '';
      String resolvedCommentId = '';
      String deletedCommentId = '';

      final comments = [
        BoardComment(
          id: 'c1',
          worldPosition: const Offset(10, 10),
          pinNumber: 1,
          author: 'Alice',
          text: 'Fix contrast ratio',
          createdAt: DateTime.now(),
          isResolved: false,
        ),
        BoardComment(
          id: 'c2',
          worldPosition: const Offset(20, 20),
          pinNumber: 2,
          author: 'Bob',
          text: 'Spacing adjusted',
          createdAt: DateTime.now(),
          isResolved: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                LayersSidebar(
                  elements: const [],
                  selectedIds: const {},
                  comments: comments,
                  initialTab: 1, // Start on Comments tab
                  onSelectElement: (id, multi) {},
                  onToggleVisibility: (id) {},
                  onToggleLock: (id) {},
                  onRenameElement: (id, name) {},
                  onDeleteElement: (id) {},
                  onReorderElements: (oldI, newI) {},
                  onSelectComment: (id) => selectedCommentId = id,
                  onToggleResolveComment: (id) => resolvedCommentId = id,
                  onDeleteComment: (id) => deletedCommentId = id,
                  onClose: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Comments tab is active
      expect(find.text('Fix contrast ratio'), findsOneWidget);
      expect(find.text('Spacing adjusted'), findsOneWidget);

      // Tap on comment card to jump to it
      await tester.tap(find.text('Fix contrast ratio'));
      expect(selectedCommentId, 'c1');

      // Tap resolve on comment c1
      await tester.tap(find.byIcon(Icons.check_circle_outline_rounded).first);
      expect(resolvedCommentId, 'c1');

      // Tap delete on comment c1
      await tester.tap(find.byIcon(Icons.close_rounded).at(1));
      expect(deletedCommentId, 'c1');

      // Filter to Open only
      await tester.tap(find.text('Open (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Fix contrast ratio'), findsOneWidget);
      expect(find.text('Spacing adjusted'), findsNothing);

      // Filter to Resolved only
      await tester.tap(find.text('Resolved (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Fix contrast ratio'), findsNothing);
      expect(find.text('Spacing adjusted'), findsOneWidget);

      // Switch back to Layers tab
      await tester.tap(find.text('Layers'));
      await tester.pumpAndSettle();
      expect(find.text('No elements on canvas'), findsOneWidget);
    });
  });
}
