import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../utilities.dart';

class ProgressionValueView<T> extends StatelessWidget {
  const ProgressionValueView({
    Key? key,
    required this.value,
  }) : super(key: key);

  final T? value;

  @override
  Widget build(BuildContext context) {
    List<String> cut = Utilities.cutProgressionValue(value);
    return Text.rich(
      TextSpan(
        text: cut[0],
        children: [
          TextSpan(
            text: cut[1],
            style: Constants.valuePatternTextStyle,
          )
        ],
      ),
      style: Constants.valueTextStyle,
    );
  }
}
