import 'dart:math';

import 'package:flutter/material.dart';

import '../constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.label,
    required this.iconData,
    required this.onPressed,
    this.onHover,
    this.size = 14,
    this.iconSize,
    this.tight = false,
    this.small = false,
    this.borderRadius,
    this.color,
  }) : super(key: key);

  final String? label;
  final IconData iconData;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onHover;
  final double size;
  final double? iconSize;
  final bool tight;

  /// Depends on [tight].
  final bool small;
  final BorderRadius? borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final maxSmallSize = Size(
      label == null
          ? max(24.0, 11.0 + max(iconSize ?? size, size))
          : Constants.minButtonWidth * 2,
      Constants.minSmallButtonHeight - 2.0,
    );
    return TextButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: tight
            ? Size(
                label == null ? maxSmallSize.width : Constants.minButtonWidth,
                small ? maxSmallSize.height : Constants.minButtonHeight)
            : null,
        maximumSize: small ? maxSmallSize : null,
        padding: tight ? const EdgeInsets.all(5.0) : null,
        shape: tight
            ? RoundedRectangleBorder(
                borderRadius: borderRadius ??
                    BorderRadius.circular(small
                        ? Constants.smallBorderRadius
                        : Constants.tightBorderRadius))
            : (borderRadius == null
                ? null
                : RoundedRectangleBorder(borderRadius: borderRadius!)),
      ),
      label: Text(label ?? '', style: TextStyle(fontSize: size, color: color)),
      icon: tight
          ? SizedBox(
              width: iconSize == null ? 6 : (iconSize! / 2),
              child: Icon(
                iconData,
                size: (iconSize ?? size) - 1,
                color: color,
              ),
            )
          : Icon(iconData, size: iconSize ?? size),
      onPressed: onPressed,
      onHover: onHover,
    );
  }
}
