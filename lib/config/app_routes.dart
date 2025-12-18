// lib/config/app_routes.dart
import 'package:flutter/material.dart';

import 'package:family_app/pages/home/home_page.dart';
import 'package:family_app/pages/album/album_list_page.dart';
import 'package:family_app/pages/album/album_detail_page.dart';
import 'package:family_app/pages/album/album_create_page.dart';
import 'package:family_app/pages/photo/photo_view_page.dart';
import 'package:family_app/pages/photo/photo_upload_page.dart';
import 'package:family_app/pages/photo/photo_edit_page.dart';
import 'package:family_app/pages/diary/diary_list_page.dart';
import 'package:family_app/pages/diary/diary_detail_page.dart';
import 'package:family_app/pages/diary/diary_write_page.dart';
import 'package:family_app/pages/settings/settings_page.dart';

import 'package:family_app/models/album.dart';
import 'package:family_app/models/photo.dart';
import 'package:family_app/models/diary.dart';

// 라우트 이름과 이동 로직을 한 곳에 모아서 관리
class AppRoutes {
  // 라우트 이름 상수
  static const home = '/';

  static const albumList = '/album/list';
  static const albumDetail = '/album/detail';
  static const albumCreate = '/album/create';

  static const photoView = '/photo/view';
  static const photoUpload = '/photo/upload';
  static const photoEdit = '/photo/edit';

  static const diaryList = '/diary/list';
  static const diaryDetail = '/diary/detail';
  static const diaryWrite = '/diary/write';

  static const settingsPage = '/settings';

  // RouteSettings.name 과 arguments 를 기준으로 실제 페이지를 만들어주는 부분
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case albumList:
        return MaterialPageRoute(builder: (_) => const AlbumListPage());

      case albumDetail:
      // 앨범 상세는 Album 객체를 넘겨받는 구조로 설계
        final album = settings.arguments as Album?;
        return MaterialPageRoute(
          builder: (_) => AlbumDetailPage(album: album),
        );

      case albumCreate:
        return MaterialPageRoute(builder: (_) => const AlbumCreatePage());

      case photoView:
      // 사진 상세는 Photo 객체를 넘겨받음
        final photo = settings.arguments as Photo;
        return MaterialPageRoute(
          builder: (_) => PhotoViewPage(photo: photo),
        );

      case photoUpload:
      // 특정 앨범에 업로드하고 싶을 때 Album 을 arguments 로 넘김 (null 가능)
        final album = settings.arguments as Album?;
        return MaterialPageRoute(
          builder: (_) => PhotoUploadPage(targetAlbum: album),
        );

      case photoEdit:
        final photo = settings.arguments as Photo;
        return MaterialPageRoute(
          builder: (_) => PhotoEditPage(photo: photo),
        );

      case diaryList:
        return MaterialPageRoute(builder: (_) => const DiaryListPage());

      case diaryDetail:
        final diary = settings.arguments as Diary;
        return MaterialPageRoute(
          builder: (_) => DiaryDetailPage(diary: diary),
        );

      case diaryWrite:
      // 기존 일기를 수정할 때는 Diary 를 넘기고, 새로 작성할 때는 null
        final original = settings.arguments as Diary?;
        return MaterialPageRoute(
          builder: (_) => DiaryWritePage(original: original),
        );

      case settingsPage:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

    // 정의되지 않은 라우트는 기본적으로 홈으로 이동
      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }
}
