import 'package:flutter/material.dart';

class BottomSheetHandle extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry margin;

  const BottomSheetHandle({
    super.key,
    this.width = 48,
    this.height = 5,
    this.radius = 12,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.black12,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
