import 'package:flutter/material.dart';

class TextAndIcon extends StatelessWidget {
  const TextAndIcon({
    Key? key,
    required this.icon,
    this.textBefore,
    this.text,
    this.style = const TextStyle(fontSize: 16.0),
    this.iconSize = 14,
    this.alignment = PlaceholderAlignment.aboveBaseline,
  }) : super(key: key);

  final String? text;
  final String? textBefore;
  final IconData icon;
  final TextStyle style;
  final double iconSize;
  final PlaceholderAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          if (textBefore != null)
            TextSpan(
              text: textBefore,
              style: style,
            ),
          WidgetSpan(
            alignment: alignment,
            baseline: TextBaseline.ideographic,
            child: Padding(
              padding: EdgeInsets.only(
                left: textBefore != null ? 4.0 : 0.0,
                right: text != null ? 4.0 : 0.0,
              ),
              child: Icon(icon, size: iconSize),
            ),
          ),
          if (text != null)
            TextSpan(
              text: text,
              style: style,
            ),
        ],
      ),
    );
  }
}
