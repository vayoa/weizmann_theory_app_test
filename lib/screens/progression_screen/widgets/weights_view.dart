import 'package:flutter/material.dart';
import 'package:harmony_theory/modals/substitution.dart';
import 'package:harmony_theory/modals/weights/weight.dart';
import 'package:harmony_theory/state/substitution_handler.dart';

import '../../../constants.dart';

class WeightsPreview extends StatelessWidget {
  const WeightsPreview({Key? key, required this.score}) : super(key: key);

  final SubstitutionScore score;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 14.0, right: 18.0),
          child: _WeightTitle(
            weightTitle: 'Final Score',
            importance: 1,
            score: score.score,
            roundDigits: 4,
            style: Constants.boldedValuePatternTextStyle,
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: score.details.length,
            itemBuilder: (context, index) {
              MapEntry<String, Score> detail =
                  score.details.entries.elementAt(index);
              Weight? weight = SubstitutionHandler.weightsMap[detail.key];
              if (detail.key == SubstitutionHandler.keepHarmonicFunction.name) {
                weight = SubstitutionHandler.keepHarmonicFunction;
              }
              return ExpansionTile(
                title: _WeightTitle(
                  weightTitle: weight!.name,
                  importance: weight.importance,
                  score: detail.value.score,
                ),
                subtitle: Text(
                  weight.description,
                  style: const TextStyle(
                      fontSize: 13, fontStyle: FontStyle.italic),
                ),
                expandedAlignment: Alignment.topLeft,
                childrenPadding: const EdgeInsets.only(left: 22.0),
                children: [
                  Text(
                    detail.value.details,
                    style: const TextStyle(fontSize: 12),
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeightTitle extends StatelessWidget {
  const _WeightTitle({
    Key? key,
    required this.weightTitle,
    required this.importance,
    required this.score,
    this.roundDigits = 2,
    this.style = const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
  }) : super(key: key);

  final String weightTitle;
  final int importance;
  final double score;
  final int roundDigits;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$weightTitle:',
          style: style,
        ),
        Flexible(
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 3.0,
              thumbShape: RoundSliderThumbShape(
                disabledThumbRadius: 6,
                enabledThumbRadius: 6,
                elevation: 0.0,
              ),
            ),
            child: Slider(
              value: score,
              min: 0.0,
              max: importance.toDouble(),
              onChanged: null,
            ),
          ),
        ),
        Text(
          '${score.toStringAsFixed(roundDigits)} / $importance',
          style: style,
        ),
      ],
    );
  }
}
