import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:family_app/api/api_client.dart';
import 'package:family_app/models/diary.dart';

/// ============================================================================
/// DiaryService
/// ----------------------------------------------------------------------------
/// - 일기 관련 API 호출 전담
/// - 상태는 들고 있지 않음 (ViewModel 책임)
/// - 백엔드 FastAPI /diaries 엔드포인트와 1:1 매칭
/// ============================================================================
class DiaryService {
  // ---------------------------------------------------------------------------
  // 가족별 일기 목록 조회
  // GET /diaries/family/{familyId}
  // ---------------------------------------------------------------------------
  Future<List<Diary>> fetchDiariesByFamily(String familyId) async {
    try {
      final data =
      await ApiClient.get('/diaries/family/$familyId') as List<dynamic>;

      return data.map((e) => Diary.fromJson(e)).toList();
    } catch (e, stack) {
      debugPrint('fetchDiariesByFamily 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 일기 단건 조회 (사진 포함)
  // GET /diaries/{diaryId}
  // ---------------------------------------------------------------------------
  Future<Diary> fetchDiaryDetail(String diaryId) async {
    try {
      final data = await ApiClient.get('/diaries/$diaryId');
      return Diary.fromJson(data);
    } catch (e, stack) {
      debugPrint('fetchDiaryDetail 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 일기 생성
  // POST /diaries
  // ---------------------------------------------------------------------------
  Future<Diary> createDiary({
    required String familyId,
    required String writerId,
    required String title,
    required String content,
    required DateTime date,
    String? photoId,
  }) async {
    try {
      final data = await ApiClient.post(
        '/diaries',
        {
          'family_id': familyId,
          'writer_id': writerId,
          'title': title,
          'content': content,
          'diary_date': date.toIso8601String(),
          'photo_id': photoId,
        },
      );

      return Diary.fromJson(data);
    } catch (e, stack) {
      debugPrint('createDiary 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 일기 수정
  // PUT /diaries/{diaryId}
  // ---------------------------------------------------------------------------
  Future<void> updateDiary({
    required String diaryId,
    String? title,
    String? content,
    DateTime? date,
    String? photoId,
  }) async {
    try {
      await ApiClient.put(
        '/diaries/$diaryId',
        {
          'title': title,
          'content': content,
          'diary_date': date?.toIso8601String(),
          'photo_id': photoId,
        },
      );
    } catch (e, stack) {
      debugPrint('updateDiary 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 일기 삭제 (soft delete)
  // DELETE /diaries/{diaryId}
  // ---------------------------------------------------------------------------
  Future<void> deleteDiary(String diaryId) async {
    try {
      await ApiClient.delete('/diaries/$diaryId');
    } catch (e, stack) {
      debugPrint('deleteDiary 오류: $e\n$stack');
      rethrow;
    }
  }
}
