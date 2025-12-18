// lib/pages/home/home_page.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:family_app/config/app_routes.dart';
import 'package:family_app/view_models/home_view_model.dart';
import 'package:family_app/widgets/custom_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _viewModel;

  bool _fadeIn = true;

  @override
  void initState() {
    super.initState();

    _viewModel = HomeViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadHome();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _goToDiaryList() =>
      Navigator.pushNamed(context, AppRoutes.diaryList);

  void _goToSettings() =>
      Navigator.pushNamed(context, AppRoutes.settingsPage);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isLoading = _viewModel.isLoading;
    final featured = _viewModel.featuredPhoto;
    final recentPhotos = _viewModel.recentPhotos;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      // --------------------------------------------------
      // AppBar
      // --------------------------------------------------
      appBar: AppBar(
        title: Text(
          '가족 사진관',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _goToSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),

      // --------------------------------------------------
      // Body
      // --------------------------------------------------
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        bottom: true,
        child: RefreshIndicator(
          onRefresh: _viewModel.loadHome,
          child: ListView(
            padding:
            const EdgeInsets.only(top: 16, bottom: 16),
            children: [
              // =================================================
              // 1) 오늘의 추천 사진
              // =================================================
              if (featured != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '오늘의 추천 사진',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: _fadeIn ? 1 : 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.photoView,
                        arguments: featured,
                      );
                    },
                    child: Container(
                      height: 220,
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image:
                          NetworkImage(featured.thumbnailUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // =================================================
              // 2) 최근 사진
              // =================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '최근 사진',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              if (recentPhotos.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '최근에 업로드된 사진이 없습니다.',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else
                GridView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount: recentPhotos.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final photo = recentPhotos[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.photoView,
                          arguments: photo,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(
                                photo.thumbnailUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),

              // =================================================
              // 3) 하단 버튼
              // =================================================
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  label: '일기 모아보기',
                  isPrimary: false,
                  onPressed: _goToDiaryList,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
