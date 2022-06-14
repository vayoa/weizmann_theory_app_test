import 'package:flutter/material.dart';

import '../constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.label,
    required this.iconData,
    required this.onPressed,
    this.size = 14,
    this.iconSize,
    this.tight = false,
    this.borderRadius,
  }) : super(key: key);

  final String? label;
  final IconData iconData;
  final VoidCallback? onPressed;
  final double size;
  final double? iconSize;
  final bool tight;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: tight
            ? Size(
                label == null
                    ? Constants.minButtonOnlyIconWidth
                    : Constants.minButtonWidth,
                Constants.minButtonHeight)
            : null,
        padding: tight ? const EdgeInsets.all(5.0) : null,
        shape: tight
            ? RoundedRectangleBorder(
                borderRadius: borderRadius ??
                    BorderRadius.circular(Constants.tightBorderRadius))
            : (borderRadius == null
                ? null
                : RoundedRectangleBorder(borderRadius: borderRadius!)),
      ),
      label: Text(label ?? '', style: TextStyle(fontSize: size)),
      icon: tight
          ? SizedBox(
              width: iconSize == null ? 6 : (iconSize! / 2),
              child: Icon(iconData, size: (iconSize ?? size) - 1),
            )
          : Icon(iconData, size: iconSize ?? size),
      onPressed: onPressed,
    );
  }
}
