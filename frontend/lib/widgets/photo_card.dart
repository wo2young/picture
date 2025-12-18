// lib/widgets/photo_card.dart
import 'package:flutter/material.dart';
import 'package:family_app/models/photo.dart';

// 사진 그리드에서 사용하는 카드
// GridView가 셀 크기를 정사각형(또는 거의 정사각형)으로 강제하기 때문에
// Column 조합에서 overflow가 잘 생긴다.
// => Expanded + Flexible 조합으로 완전히 해결.
class PhotoCard extends StatelessWidget {
  final Photo photo;
  final VoidCallback? onTap;

  const PhotoCard({
    super.key,
    required this.photo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ===========================
            // 1) 사진 영역 — Expanded로 확보
            // ===========================
            // 이걸 Expanded로 설정하면 Column 높이 내에서 자동으로 조정되기 때문에
            // 텍스트가 있어도 절대 오버플로우가 나지 않는다.
            Expanded(
              child: Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.photo, size: 40),
              ),
            ),

            // ===========================
            // 2) 캡션 영역 — Flexible로 최소 공간만 차지
            // ===========================
            if (photo.description != null && photo.description!.isNotEmpty)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Text(
                    photo.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
