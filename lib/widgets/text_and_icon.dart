import 'package:flutter/material.dart';

class TextAndIcon extends StatelessWidget {
  const TextAndIcon({
    Key? key,
    required this.text,
    required this.icon,
    this.style = const TextStyle(fontSize: 16.0),
    this.iconSize = 14,
    this.beforeText = true,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final TextStyle style;
  final double iconSize;
  final bool beforeText;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          if (beforeText)
            WidgetSpan(
              alignment: PlaceholderAlignment.aboveBaseline,
              baseline: TextBaseline.ideographic,
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(icon, size: iconSize),
              ),
            ),
          TextSpan(
            text: text,
            style: style,
          ),
          if (!beforeText)
            WidgetSpan(
              alignment: PlaceholderAlignment.aboveBaseline,
              baseline: TextBaseline.ideographic,
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 1.5),
                child: Icon(icon, size: iconSize),
              ),
            ),
        ],
      ),
    );
  }
}
