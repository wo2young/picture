// lib/pages/feedback/feedback_list_page.dart

import 'package:flutter/material.dart';
import 'package:family_app/models/feedback_post.dart';
import 'package:family_app/services/feedback_service.dart';
import 'package:family_app/pages/feedback/feedback_write_page.dart';
import 'package:family_app/pages/feedback/feedback_detail_page.dart';

class FeedbackListPage extends StatefulWidget {
  const FeedbackListPage({super.key});

  @override
  State<FeedbackListPage> createState() => _FeedbackListPageState();
}

class _FeedbackListPageState extends State<FeedbackListPage> {
  final FeedbackService _service = FeedbackService();

  bool _isLoading = false;
  List<FeedbackPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final list = await _service.fetchPosts();
      setState(() => _posts = list);
    } catch (_) {
      // 필요하면 스낵바 처리
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _goWrite() async {
    final created = await Navigator.of(context).push<FeedbackPost?>(
      MaterialPageRoute(
        builder: (_) => FeedbackWritePage(service: _service),
      ),
    );
    if (created != null) {
      await _load();
    }
  }

  Future<void> _goDetail(FeedbackPost post) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FeedbackDetailPage(service: _service, post: post),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('건의사항 / 버그 신고'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: _posts.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 120),
            Center(child: Text('아직 작성된 글이 없습니다.')),
          ],
        )
            : ListView.separated(
          itemCount: _posts.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final p = _posts[index];
            final statusText = p.hasReply ? '답변 완료' : '답변 대기';
            return ListTile(
              title: Text(
                p.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${statusText} · ${_formatDate(p.createdAt)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _goDetail(p),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goWrite,
        child: const Icon(Icons.edit),
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
