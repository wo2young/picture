// lib/services/feedback_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:family_app/models/feedback_post.dart';

/// ---------------------------------------------------------------------------
/// FeedbackService
/// - 서버 붙이기 전까지 더미(메모리) 저장소로 동작
/// - "내가 쓴 글" 느낌으로만 운영 (로그인 붙이면 userId 추가하면 됨)
/// ---------------------------------------------------------------------------
class FeedbackService {
  // 임시 더미 데이터
  final List<FeedbackPost> _posts = [
    FeedbackPost(
      id: 'f1',
      title: '글자가 조금 작은 것 같아요',
      content: '엄마가 보기에 글자가 조금 작아요. 크기 조절 가능하면 좋겠어요.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      developerReply: '의견 감사합니다! 글자 크기 옵션을 설정에 추가해볼게요.',
      repliedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FeedbackPost(
      id: 'f2',
      title: '사진이 가끔 늦게 떠요',
      content: '앨범 들어가면 사진이 늦게 뜨는 것 같아요.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<FeedbackPost>> fetchPosts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 250));
      // 최신 글이 위로 오도록
      final copy = List<FeedbackPost>.from(_posts);
      copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return copy;
    } catch (e, stack) {
      debugPrint('FeedbackService.fetchPosts 오류: $e\n$stack');
      rethrow;
    }
  }

  Future<FeedbackPost> createPost({
    required String title,
    required String content,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 250));
      final post = FeedbackPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim().isEmpty ? '(제목 없음)' : title.trim(),
        content: content.trim().isEmpty ? '(내용 없음)' : content.trim(),
        createdAt: DateTime.now(),
      );
      _posts.insert(0, post);
      return post;
    } catch (e, stack) {
      debugPrint('FeedbackService.createPost 오류: $e\n$stack');
      rethrow;
    }
  }

  Future<FeedbackPost> addDeveloperReply({
    required String postId,
    required String reply,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 250));
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx == -1) throw Exception('게시글을 찾을 수 없습니다.');

      final updated = _posts[idx].copyWith(
        developerReply: reply,
        repliedAt: DateTime.now(),
      );
      _posts[idx] = updated;
      return updated;
    } catch (e, stack) {
      debugPrint('FeedbackService.addDeveloperReply 오류: $e\n$stack');
      rethrow;
    }
  }
}
