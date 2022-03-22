import 'package:flutter/material.dart';

import '../constants.dart';

class TButton extends StatelessWidget {
  const TButton({
    Key? key,
    required this.label,
    required this.iconData,
    required this.onPressed,
    this.size = 14,
    this.iconSize,
    this.tight = false,
  }) : super(key: key);

  final String label;
  final IconData iconData;
  final Function()? onPressed;
  final double size;
  final double? iconSize;
  final bool tight;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: tight
            ? const Size(Constants.minButtonWidth, Constants.minButtonHeight)
            : null,
        padding: tight ? const EdgeInsets.all(5.0) : null,
        shape: tight
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))
            : null,
      ),
      label: Text(label, style: TextStyle(fontSize: size)),
      icon: tight
          ? SizedBox(
              width: 6,
              child: Icon(iconData, size: (iconSize ?? size) - 1),
            )
          : Icon(iconData, size: iconSize ?? size),
      onPressed: onPressed,
    );
  }
}
