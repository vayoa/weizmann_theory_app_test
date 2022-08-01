import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../utilities.dart';

class ProgressionValueView<T> extends StatelessWidget {
  const ProgressionValueView({
    Key? key,
    required this.value,
    this.highlight = false,
  }) : super(key: key);

  final T? value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    List<String> cut = Utilities.cutProgressionValue(value);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Text.rich(
          TextSpan(
            text: cut[0],
            children: [
              TextSpan(
                text: cut[1],
                style: _handleHighlight(Constants.valuePatternTextStyle),
              )
            ],
          ),
          style: _handleHighlight(Constants.valueTextStyle),
        ),
      ),
    );
  }

  TextStyle _handleHighlight(TextStyle style) => highlight
      ? style.copyWith(
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          color: Constants.substitutionColor,
          shadows: const [
            Shadow(
              offset: Offset(2.0, 2.0),
              blurRadius: 15.0,
              color: Colors.black38,
            )
          ],
        )
      : style;
}
