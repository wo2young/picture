// lib/pages/feedback/feedback_detail_page.dart

import 'package:flutter/material.dart';
import 'package:family_app/models/feedback_post.dart';
import 'package:family_app/services/feedback_service.dart';

class FeedbackDetailPage extends StatefulWidget {
  final FeedbackService service;
  final FeedbackPost post;

  const FeedbackDetailPage({
    super.key,
    required this.service,
    required this.post,
  });

  @override
  State<FeedbackDetailPage> createState() => _FeedbackDetailPageState();
}

class _FeedbackDetailPageState extends State<FeedbackDetailPage> {
  late FeedbackPost _post;

  // (임시) 개발자 모드: true일 때만 답변 입력 UI 노출
  // 실제로는 "관리자 계정" 같은 인증 로직으로 바꾸면 됨
  final bool _developerMode = true;

  final _replyCtrl = TextEditingController();
  bool _savingReply = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _replyCtrl.text = _post.developerReply ?? '';
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveReply() async {
    if (_savingReply) return;
    setState(() => _savingReply = true);

    try {
      final updated = await widget.service.addDeveloperReply(
        postId: _post.id,
        reply: _replyCtrl.text,
      );
      if (!mounted) return;
      setState(() => _post = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변이 저장되었습니다.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변 저장 실패')),
      );
    } finally {
      if (mounted) setState(() => _savingReply = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _post.hasReply ? '답변 완료' : '답변 대기';

    return Scaffold(
      appBar: AppBar(
        title: const Text('상세 보기'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _post.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '$status · ${_formatDate(_post.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            Text(
              _post.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            Text(
              '개발자 답변',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),

            if (!_developerMode)
              Text(
                _post.hasReply ? _post.developerReply! : '아직 답변이 없습니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...[
              TextField(
                controller: _replyCtrl,
                decoration: const InputDecoration(
                  hintText: '답변을 입력하세요 (개발자만)',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 8,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _savingReply ? null : _saveReply,
                  child: _savingReply
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('답변 저장'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }
}
