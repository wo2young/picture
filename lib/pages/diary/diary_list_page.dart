// lib/pages/diary/diary_list_page.dart

import 'package:flutter/material.dart';
import 'package:family_app/models/diary.dart';
import 'package:family_app/view_models/diary_view_model.dart';
import 'package:family_app/config/app_routes.dart';
import 'package:family_app/utils/formatters.dart';

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  late final DiaryViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = DiaryViewModel();
    _viewModel.addListener(_onChanged);

    const String familyId = '1';
    _viewModel.loadDiariesByFamily(familyId);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _goToWrite() async {
    await Navigator.pushNamed(context, AppRoutes.diaryWrite);

    const String familyId = '1';
    _viewModel.loadDiariesByFamily(familyId);
  }

  @override
  Widget build(BuildContext context) {
    final diaries = _viewModel.diaries;
    final isLoading = _viewModel.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('일기 목록')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : diaries.isEmpty
          ? const Center(child: Text('아직 작성된 일기가 없습니다.'))
          : ListView.builder(
        itemCount: diaries.length,
        itemBuilder: (context, index) {
          final diary = diaries[index];
          return ListTile(
            title: Text(diary.title),
            subtitle: Text(
              '${Formatters.formatDate(diary.date)} · ${diary.content}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.diaryDetail,
                arguments: diary,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToWrite,
        child: const Icon(Icons.add),
      ),
    );
  }
}
