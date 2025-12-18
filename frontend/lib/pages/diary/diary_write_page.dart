// lib/pages/diary/diary_write_page.dart
import 'package:flutter/material.dart';

import 'package:family_app/models/diary.dart';
import 'package:family_app/view_models/diary_view_model.dart';
import 'package:family_app/utils/validators.dart';
import 'package:family_app/widgets/custom_button.dart';

class DiaryWritePage extends StatefulWidget {
  final Diary? original;

  const DiaryWritePage({
    super.key,
    this.original,
  });

  @override
  State<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends State<DiaryWritePage> {
  final _formKey = GlobalKey<FormState>();
  late final DiaryViewModel _viewModel;

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late DateTime _selectedDate;

  bool _isSubmitting = false;

  // (추가) 이번 단계 핵심 상태: 단일 사진 1장만 연결
  // - 선택 안 하면 null
  // - 선택하면 photoId 문자열
  String? _selectedPhotoId;

  @override
  void initState() {
    super.initState();

    _viewModel = DiaryViewModel();

    _titleController = TextEditingController(text: widget.original?.title ?? '');
    _contentController =
        TextEditingController(text: widget.original?.content ?? '');
    _selectedDate = widget.original?.date ?? DateTime.now();

    // (추가) 수정 모드라면 기존 연결값을 화면에 반영
    // - 지금 Diary 모델이 photoId를 갖고 있으니 그대로 세팅
    _selectedPhotoId = widget.original?.photoId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // (추가) 사진 선택
  // - 현재 PhotoListPage가 없다고 했으니, 이번 단계는 "연동 파이프라인"을 먼저 완성시키는 용도로
  //   임시로 photoId를 직접 입력받는 방식으로 연결을 끝까지 뚫는다.
  // - 다음 단계에서 이 함수 내부만 "실제 사진 선택 화면으로 push"로 교체하면 됨.
  Future<void> _pickPhoto() async {
    try {
      final controller = TextEditingController(text: _selectedPhotoId ?? '');

      final result = await showDialog<String?>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('사진 연결'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'photoId 입력',
                hintText: '예: 123',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('연결'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (result == null || result.isEmpty) return;

      setState(() => _selectedPhotoId = result);
    } catch (e) {
      // 여기서는 UI 상호작용만 하므로 로그 정도로 충분
      debugPrint('_pickPhoto 오류: $e');
    }
  }

  // (추가) 사진 연결 해제
  void _clearPhoto() {
    setState(() => _selectedPhotoId = null);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      const String familyId = '1'; // 임시

      if (widget.original == null) {
        await _viewModel.createDiary(
          familyId: familyId,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          date: _selectedDate,

          // 단일 photoId 그대로 전달
          photoId: _selectedPhotoId,
        );
      } else {
        await _viewModel.updateDiary(
          diaryId: widget.original!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          date: _selectedDate,

          // 수정도 동일
          photoId: _selectedPhotoId,
        );
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.original != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '일기 수정' : '새 일기 쓰기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${_selectedDate.year}-'
                    '${_selectedDate.month.toString().padLeft(2, '0')}-'
                    '${_selectedDate.day.toString().padLeft(2, '0')}',
              ),
            ),

            // (추가) 사진 연결 UI
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo),
                    label: Text(
                      _selectedPhotoId == null
                          ? '사진 연결하기'
                          : '연결됨: $_selectedPhotoId',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: (_selectedPhotoId == null) ? null : _clearPhoto,
                  icon: const Icon(Icons.close),
                  tooltip: '사진 연결 해제',
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: '제목'),
                      validator: (v) =>
                          Validators.required(v, fieldName: '제목'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(labelText: '내용'),
                      maxLines: 10,
                      validator: (v) =>
                          Validators.required(v, fieldName: '내용'),
                    ),
                  ],
                ),
              ),
            ),
            CustomButton(
              label: _isSubmitting ? '저장 중...' : (isEdit ? '수정 완료' : '등록'),
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/*
[전체 정리]
- 이번 단계 핵심: DiaryWritePage는 단일 photoId(Nullable)만 상태로 들고, 저장 직전에만 List로 감싸서 전달한다.
- 빨간 줄이 날 부분: _viewModel.createDiary / updateDiary에 photoIds 파라미터가 아직 없어서 발생한다.

[다음으로 해야 할 변경 2곳]
1) DiaryViewModel.createDiary / updateDiary 시그니처에 photoIds(List<String>?) 옵션 파라미터 추가
2) ViewModel 내부에서 DiaryService.createDiary / updateDiary 호출 시 photoIds를 그대로 전달

[중요]
- UI는 단일 선택(1장)만 허용: 상태는 String? _selectedPhotoId 하나로 끝낸다.
- Service는 photo_ids(List) 형태라도 상관없음: 화면에서만 단일로 유지하고, 호출 시 래핑한다.

[실무에서 자주 쓰임]
- 화면 상태는 단순하게(단일 ID), 네트워크 요청 직전에만 서버 스펙에 맞춰 변환(래핑/매핑)하는 패턴이 유지보수에 강하다.
*/