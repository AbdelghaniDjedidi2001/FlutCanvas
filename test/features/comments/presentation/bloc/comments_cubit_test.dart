import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/comments/presentation/bloc/comments_cubit.dart';
import 'package:flutcanvas/features/comments/presentation/bloc/comments_state.dart';

void main() {
  group('CommentsCubit Tests', () {
    late CommentsCubit cubit;

    setUp(() {
      cubit = CommentsCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has empty comments', () {
      expect(cubit.state.comments, isEmpty);
      expect(cubit.state.activeCommentId, isNull);
    });

    blocTest<CommentsCubit, CommentsState>(
      'addComment adds new pinned thread and selects it',
      build: () => cubit,
      act: (c) => c.addComment(
        position: const Offset(100, 100),
        author: 'Alex',
        text: 'Review this design',
      ),
      verify: (c) {
        expect(c.state.comments.length, equals(1));
        final comment = c.state.comments.first;
        expect(comment.author, equals('Alex'));
        expect(comment.text, equals('Review this design'));
        expect(c.state.activeCommentId, equals(comment.id));
      },
    );

    blocTest<CommentsCubit, CommentsState>(
      'addReply appends reply to targeted comment',
      build: () => cubit,
      act: (c) {
        c.addComment(
          position: const Offset(100, 100),
          author: 'Alex',
          text: 'First note',
        );
        final commentId = c.state.comments.first.id;
        c.addReply(
          commentId: commentId,
          author: 'Sam',
          text: 'Looks great!',
        );
      },
      verify: (c) {
        final comment = c.state.comments.first;
        expect(comment.replies.length, equals(1));
        expect(comment.replies.first.author, equals('Sam'));
      },
    );

    blocTest<CommentsCubit, CommentsState>(
      'toggleResolved marks comment resolved',
      build: () => cubit,
      act: (c) {
        c.addComment(
          position: const Offset(100, 100),
          author: 'Alex',
          text: 'Task',
        );
        final commentId = c.state.comments.first.id;
        c.toggleResolved(commentId);
      },
      verify: (c) {
        expect(c.state.comments.first.isResolved, isTrue);
        expect(c.state.visibleComments, isEmpty);
      },
    );
  });
}
