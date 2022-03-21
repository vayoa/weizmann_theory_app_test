import 'package:flutter/material.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:weizmann_theory_app_test/screens/widgets/progression/progression_view.dart';

import '../../../Constants.dart';

class SelectableProgressionView<T> extends StatelessWidget {
  const SelectableProgressionView({
    Key? key,
    required this.measures,
    this.rangeSelectPadding = 8.0,
    this.fromChord = 0,
    this.toChord = 0,
  }) : super(key: key);

  final List<Progression> measures;
  final double rangeSelectPadding;
  final int fromChord;
  final int toChord;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxMeasures = constraints.maxWidth / Constants.measureWidth;
          int measuresInLine = 1;
          if (maxMeasures > 8) {
            measuresInLine = 8;
          } else if (maxMeasures > 4) {
            measuresInLine = 4;
          } else if (maxMeasures > 2) {
            measuresInLine = 2;
          }
          double width = Constants.measureWidth * measuresInLine;
          return SizedBox(
            width: width + rangeSelectPadding,
            child: Padding(
              padding: EdgeInsets.all(rangeSelectPadding),
              child: ProgressionView(
                measures: measures,
                measuresInLine: measuresInLine,
                fromChord: fromChord,
                toChord: toChord,
              ),
            ),
          );
        },
      ),
    );
  }
}
