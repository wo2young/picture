// lib/view_models/diary_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:family_app/models/diary.dart';
import 'package:family_app/services/diary_service.dart';

class DiaryViewModel extends ChangeNotifier {
  final DiaryService _diaryService;

  DiaryViewModel({
    DiaryService? diaryService,
  }) : _diaryService = diaryService ?? DiaryService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Diary> _diaries = [];
  List<Diary> get diaries => _diaries;

  Diary? _diary;
  Diary? get diary => _diary;

  // --------------------------------------------
  // 가족별 일기 목록
  // --------------------------------------------
  Future<void> loadDiariesByFamily(String familyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _diaries = await _diaryService.fetchDiariesByFamily(familyId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --------------------------------------------
  // 일기 생성
  // --------------------------------------------
  Future<void> createDiary({
    required String familyId,
    required String title,
    required String content,
    required DateTime date,

    // (추가) 단일 사진 연결
    String? photoId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      const String writerId = '1'; // 임시

      final diary = await _diaryService.createDiary(
        familyId: familyId,
        writerId: writerId,
        title: title,
        content: content,
        date: date,

        // (추가) 그대로 Service로 전달
        photoId: photoId,
      );

      _diaries.insert(0, diary);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --------------------------------------------
  // 일기 수정
  // --------------------------------------------
  Future<void> updateDiary({
    required String diaryId,
    required String title,
    required String content,
    required DateTime date,

    // (추가)
    String? photoId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _diaryService.updateDiary(
        diaryId: diaryId,
        title: title,
        content: content,
        date: date,

        // (추가)
        photoId: photoId,
      );

      final index = _diaries.indexWhere((d) => d.id == diaryId);
      if (index != -1) {
        _diaries[index] = _diaries[index].copyWith(
          title: title,
          content: content,
          date: date,
          photoId: photoId, // (중요) 로컬 상태도 동기화
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // --------------------------------------------
  // 일기 삭제
  // --------------------------------------------
  Future<void> deleteDiary(String diaryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _diaryService.deleteDiary(diaryId);
      _diaries.removeWhere((d) => d.id == diaryId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
