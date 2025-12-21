// lib/services/diary_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:family_app/api/api_client.dart';
import 'package:family_app/models/diary.dart';

/// ============================================================================
/// DiaryService
/// ----------------------------------------------------------------------------
/// - 일기 관련 API 호출 전담
/// - ID 타입은 전부 int 기준
/// ============================================================================
class DiaryService {
  // ---------------------------------------------------------------------------
  // 가족별 일기 목록 조회
  // GET /diaries/family/{family_id}
  // ---------------------------------------------------------------------------
  Future<List<Diary>> fetchDiariesByFamily(int familyId) async {
    try {
      final data = await ApiClient.get(
        '/diaries/family/$familyId',
      ) as List<dynamic>;

      return data
          .map((e) => Diary.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      debugPrint('fetchDiariesByFamily 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 일기 단건 조회 (사진 포함)
  // GET /diaries/{diary_id}
  // ---------------------------------------------------------------------------
  Future<Diary> fetchDiaryDetail(int diaryId) async {
    try {
      final data = await ApiClient.get(
        '/diaries/$diaryId',
      ) as Map<String, dynamic>;

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
    required int familyId,
    required int writerId,
    required String title,
    required String content,
    required DateTime date,
    int? photoId,
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

      return Diary.fromJson(data as Map<String, dynamic>);
    } catch (e, stack) {
      debugPrint('createDiary 오류: $e\n$stack');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 일기 수정
  // PUT /diaries/{diary_id}
  // ---------------------------------------------------------------------------
  Future<void> updateDiary({
    required int diaryId,
    String? title,
    String? content,
    DateTime? date,
    int? photoId,
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
  // DELETE /diaries/{diary_id}
  // ---------------------------------------------------------------------------
  Future<void> deleteDiary(int diaryId) async {
    try {
      await ApiClient.delete('/diaries/$diaryId');
    } catch (e, stack) {
      debugPrint('deleteDiary 오류: $e\n$stack');
      rethrow;
    }
  }
}
