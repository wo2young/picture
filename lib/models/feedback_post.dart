// lib/models/feedback_post.dart

class FeedbackPost {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  // 개발자 답변(개발자만 작성)
  final String? developerReply;
  final DateTime? repliedAt;

  const FeedbackPost({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.developerReply,
    this.repliedAt,
  });

  bool get hasReply => developerReply != null && developerReply!.trim().isNotEmpty;

  FeedbackPost copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? developerReply,
    DateTime? repliedAt,
  }) {
    return FeedbackPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      developerReply: developerReply ?? this.developerReply,
      repliedAt: repliedAt ?? this.repliedAt,
    );
  }
}
