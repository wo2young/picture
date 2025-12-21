// lib/pages/home/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:family_app/config/app_routes.dart';
import 'package:family_app/view_models/home_view_model.dart';
import 'package:family_app/models/home_photo_item.dart';
import 'package:family_app/widgets/custom_button.dart';
import 'package:family_app/pages/family/family_first_create_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.loadHome();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // ==================================================
  // 📸 사진 추가
  // ==================================================
  Future<void> _goToPhotoUpload() async {
    final albumId = await Navigator.pushNamed(
      context,
      AppRoutes.albumList,
    );

    if (!mounted || albumId == null) return;

    final uploaded = await Navigator.pushNamed(
      context,
      AppRoutes.photoUpload,
      arguments: albumId,
    );

    if (uploaded == true) {
      _viewModel.loadHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ================================
          // ⭐ 가족이 없으면 최초 생성 화면
          // ================================
          if (vm.needCreateFamily) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => const FamilyFirstCreatePage(),
                ),
              );

              if (created == true) {
                _viewModel.loadHome();
              }
            });

            return const Scaffold(body: SizedBox.shrink());
          }

          // ================================
          // ✅ 정상 홈 화면
          // ================================
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                '가족 사진관',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: _goToPhotoUpload,
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: vm.loadHome,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  if (vm.recentPhotos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('최근 사진이 없습니다.'),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: vm.recentPhotos.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final HomePhotoItem item =
                        vm.recentPhotos[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.photoView,
                              arguments: item.photoId,
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: '사진 앨범',
                            isPrimary: false,
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.albumList);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            label: '일기 모아보기',
                            isPrimary: false,
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.diaryList);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
