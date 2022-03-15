import 'package:flutter/material.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:weizmann_theory_app_test/utilities.dart';

import '../Constants.dart';

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
            style: const TextStyle(fontSize: Constants.measurePatternFontSize),
          )
        ],
      ),
      style: const TextStyle(fontSize: Constants.measureFontSize),
    );
  }
}
