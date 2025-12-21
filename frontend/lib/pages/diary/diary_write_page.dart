// lib/pages/diary/diary_write_page.dart
import 'package:flutter/material.dart';

import 'package:family_app/models/diary.dart';
import 'package:family_app/view_models/diary_view_model.dart';
import 'package:family_app/utils/validators.dart';
import 'package:family_app/widgets/custom_button.dart';
import 'package:family_app/pages/photo/photo_select_page.dart';
import 'package:family_app/services/photo_service.dart';

class DiaryWritePage extends StatefulWidget {
  final Diary? original;

  /// PhotoSelectPage가 albumId를 required로 받기 때문에
  /// 여기서도 전달 (nullable)
  final int? albumId;

  /// PhotoDetailPage → DiaryWritePage 진입 시
  final int? initialPhotoId;

  const DiaryWritePage({
    super.key,
    this.original,
    this.albumId,
    this.initialPhotoId,
  });

  @override
  State<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends State<DiaryWritePage> {
  final _formKey = GlobalKey<FormState>();

  late final DiaryViewModel _viewModel;
  late final PhotoService _photoService;

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late DateTime _selectedDate;

  bool _isSubmitting = false;

  // -----------------------------
  // 사진 연결 상태
  // -----------------------------
  int? _selectedPhotoId;
  String? _selectedPhotoThumbnailUrl;

  @override
  void initState() {
    super.initState();

    _viewModel = DiaryViewModel();
    _photoService = PhotoService();

    _titleController =
        TextEditingController(text: widget.original?.title ?? '');
    _contentController =
        TextEditingController(text: widget.original?.content ?? '');
    _selectedDate = widget.original?.date ?? DateTime.now();

    // 우선순위:
    // 1) 수정 모드 기존 photoId
    // 2) PhotoDetailPage에서 넘어온 initialPhotoId
    _selectedPhotoId =
        widget.original?.photoId ?? widget.initialPhotoId;

    if (_selectedPhotoId != null) {
      _loadSelectedPhotoPreview(_selectedPhotoId!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // 날짜 선택
  // --------------------------------------------------
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

  // --------------------------------------------------
  // 사진 미리보기 로딩 (photoId → thumbnailUrl)
  // --------------------------------------------------
  Future<void> _loadSelectedPhotoPreview(int photoId) async {
    // 이미 로딩되어 있으면 재요청 안 함
    if (_selectedPhotoThumbnailUrl != null) return;

    try {
      final detail = await _photoService.fetchPhotoDetail(photoId);

      if (!mounted) return;

      setState(() {
        _selectedPhotoThumbnailUrl =
            detail.photo.thumbnailUrl;
      });
    } catch (_) {
      // 미리보기 실패해도 작성은 가능
    }
  }

  // --------------------------------------------------
  // 사진 선택
  // --------------------------------------------------
  Future<void> _pickPhoto() async {
    if (widget.albumId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('앨범 정보가 없어 사진을 선택할 수 없습니다.'),
        ),
      );
      return;
    }

    final photo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoSelectPage(
          albumId: widget.albumId!,
        ),
      ),
    );

    if (!mounted || photo == null) return;

    setState(() {
      _selectedPhotoId = photo.id;
      _selectedPhotoThumbnailUrl = photo.thumbnailUrl;
    });
  }

  void _clearPhoto() {
    setState(() {
      _selectedPhotoId = null;
      _selectedPhotoThumbnailUrl = null;
    });
  }

  // --------------------------------------------------
  // 저장
  // --------------------------------------------------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      const int familyId = 1; // TODO: 로그인 연동 시 교체

      if (widget.original == null) {
        await _viewModel.createDiary(
          familyId: familyId,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          date: _selectedDate,
          photoId: _selectedPhotoId,
        );
      } else {
        await _viewModel.updateDiary(
          diaryId: widget.original!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          date: _selectedDate,
          photoId: _selectedPhotoId,
        );
      }

      // true = 변경 있음
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
            // 날짜
            TextButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${_selectedDate.year}-'
                    '${_selectedDate.month.toString().padLeft(2, '0')}-'
                    '${_selectedDate.day.toString().padLeft(2, '0')}',
              ),
            ),

            // -----------------------------
            // 사진 연결 UI (미리보기)
            // -----------------------------
            if (_selectedPhotoThumbnailUrl != null)
              GestureDetector(
                onTap: _pickPhoto, // 다시 선택 가능
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _selectedPhotoThumbnailUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: _clearPhoto,
                      ),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo),
                label: const Text('사진 연결하기'),
              ),

            const SizedBox(height: 12),

            // -----------------------------
            // 제목 / 내용
            // -----------------------------
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration:
                      const InputDecoration(labelText: '제목'),
                      validator: (v) =>
                          Validators.required(v, fieldName: '제목'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contentController,
                      decoration:
                      const InputDecoration(labelText: '내용'),
                      maxLines: 10,
                      validator: (v) =>
                          Validators.required(v, fieldName: '내용'),
                    ),
                  ],
                ),
              ),
            ),

            CustomButton(
              label: _isSubmitting
                  ? '저장 중...'
                  : (isEdit ? '수정 완료' : '등록'),
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
