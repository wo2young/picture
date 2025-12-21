// lib/pages/photo/photo_upload_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:family_app/models/album.dart';
import 'package:family_app/services/photo_service.dart';
import 'package:family_app/services/upload_service.dart';
import 'package:family_app/widgets/custom_button.dart';

class PhotoUploadPage extends StatefulWidget {
  final int albumId;

  const PhotoUploadPage({
    super.key,
    required this.albumId,
  });

  @override
  State<PhotoUploadPage> createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();

  final PhotoService _photoService = PhotoService();

  File? _selectedFile;        // (ImagePicker로 선택된 실제 파일)
  bool _isSubmitting = false; // (중복 업로드 방지용 상태)

  // --------------------------------------------------
  // 사진 선택
  // --------------------------------------------------
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // (gallery에서 사진 1장 선택, XFile 반환)
    final result = await picker.pickImage(source: ImageSource.gallery);

    // (선택 취소 시 null 반환 → 반드시 체크 필요)
    if (result != null) {
      setState(() {
        // (XFile → File 변환 필수, Azure 업로드는 File 기준)
        _selectedFile = File(result.path);
      });
    }
  }

  // --------------------------------------------------
  // 업로드 처리
  // --------------------------------------------------
  Future<void> _submit() async {
    // (사진 미선택 방어 로직)
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 선택해주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1️⃣ Azure 업로드
      // - 실제 파일을 Azure Blob Storage에 업로드
      // - public 접근 가능한 URL 문자열 반환
      final url = await UploadService.uploadPhotoToAzure(_selectedFile!);

      // 2️⃣ DB 저장
      // - Azure URL을 Photo 테이블에 저장
      // - album_id 기준으로 앨범과 연결
      await _photoService.createPhoto(
        albumId: widget.albumId,        // (Navigator arguments로 받은 album)
        originalUrl: url,                      // (원본 이미지 URL)
        thumbnailUrl: url,                     // (현재는 동일 URL 사용)
        description: _captionController.text.trim(),
        place: _locationController.text.trim(),
      );

      // (성공 시 이전 화면으로 복귀)
      // ※ AlbumDetailPage에서 pop 결과를 받아 리스트 갱신 가능
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진이 추가되었습니다')),
        );
        Navigator.pop(context, true);
      }
      // (네트워크 / Azure / DB 오류 공통 처리)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 업로드 실패')),
        );
      }
    } finally {
      // (에러 여부와 관계없이 업로드 상태 해제)
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사진 업로드')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: _selectedFile == null
                    ? const Center(child: Text('사진 선택'))
                    : Image.file(_selectedFile!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(labelText: '사진 설명'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: '장소'),
            ),
            const Spacer(),
            CustomButton(
              label: _isSubmitting ? '업로드 중...' : '업로드',
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/*
==================== 전체 정리 ====================

[현재 이 페이지에서 완성된 것]
- ImagePicker를 통한 이미지 선택
- 선택된 파일 미리보기
- Azure Blob Storage 업로드
- Azure URL을 DB(Photo 테이블)에 저장
- 앨범과 사진 연결(album_id 기준)

[실무에서 중요한 포인트]
1) XFile → File 변환
   - image_picker는 XFile을 반환하지만
   - multipart 업로드는 File 기준이므로 변환 필수

2) 업로드 순서
   - 파일 → Azure 업로드 → URL 확보
   - URL → DB 저장
   (이 순서가 뒤집히면 DB에 쓰레기 데이터 남음)

3) Navigator.pop(context, true)
   - true 반환으로 상위 화면에서 "업로드 완료"를 감지 가능
   - AlbumDetailPage에서 즉시 목록 갱신 가능

4) _isSubmitting 상태
   - 중복 업로드 방지
   - 실무에서 매우 중요 (네트워크 중복 요청 방지)

[아직 남은 TODO]
- thumbnailUrl 실제 썸네일 분리 (백엔드 or 클라이언트)
- 업로드 실패 시 Azure 업로드만 성공한 경우 정리 전략
- 카메라(ImageSource.camera) 옵션 추가 여부

==================================================
*/
