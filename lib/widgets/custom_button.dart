// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // 공통 텍스트 스타일 (가독성 개선)
    final textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    if (isPrimary) {
      // ------------------------------
      // ⭐ Primary 버튼 (브라운 + 화이트)
      // ------------------------------
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          splashFactory: InkRipple.splashFactory,
        ),
        child: Text(label, style: textStyle),
      );
    }

    // ------------------------------
    // ⭐ Secondary 버튼 (테두리만 브라운)
    // ------------------------------
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        side: BorderSide(color: scheme.primary, width: 1.4),
        foregroundColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        splashFactory: InkRipple.splashFactory,
      ),
      child: Text(label, style: textStyle),
    );
  }
}
