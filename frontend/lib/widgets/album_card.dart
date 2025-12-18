// lib/widgets/album_card.dart
import 'package:flutter/material.dart';
import 'package:family_app/models/album.dart';
import 'package:family_app/utils/formatters.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback? onTap;

  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = Formatters.formatDate(album.createdAt);

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,

      // 테마에서 정의된 그림자/반경 자동 적용
      elevation: 0,
      color: scheme.surface,
      shadowColor: scheme.primary.withOpacity(0.12),

      child: InkWell(
        onTap: onTap,
        splashColor: scheme.primary.withOpacity(0.1),

        child: SizedBox(
          height: 110,
          child: Row(
            children: [
              // -------------------------------
              // 앨범 커버 (사진 없을 때 placeholder)
              // -------------------------------
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.photo_album,
                  size: 38,
                  color: scheme.primary.withOpacity(0.8),
                ),
              ),

              const SizedBox(width: 14),

              // -------------------------------
              // 텍스트 영역
              // -------------------------------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 앨범 제목
                      Text(
                        album.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // 설명
                      if (album.description != null &&
                          album.description!.isNotEmpty)
                        Text(
                          album.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const Spacer(),

                      // 날짜 + 사진 수
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$dateText 생성',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '${album.photoCount}장',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
