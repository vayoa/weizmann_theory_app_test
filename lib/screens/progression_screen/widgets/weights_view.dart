import 'package:flutter/material.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:thoery_test/modals/weights/weight.dart';
import 'package:thoery_test/state/substitution_handler.dart';

class WeightsPreview extends StatelessWidget {
  const WeightsPreview({Key? key, required this.score}) : super(key: key);

  final SubstitutionScore score;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: score.details.length,
      itemBuilder: (context, index) {
        MapEntry<String, Score> detail = score.details.entries.elementAt(index);
        Weight? weight = SubstitutionHandler.weightsMap[detail.key];
        if (detail.key == SubstitutionHandler.keepHarmonicFunction.name) {
          weight = SubstitutionHandler.keepHarmonicFunction;
        }
        return ExpansionTile(
          title: Row(
            children: [
              Text(
                '${detail.key}:',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
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
                    value: detail.value.score,
                    min: 0.0,
                    max: weight!.importance.toDouble(),
                    onChanged: null,
                  ),
                ),
              ),
              Text(
                '${detail.value.score.toStringAsFixed(2)} / ${weight.importance}',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
              ),
            ],
          ),
          subtitle: Text(
            weight.description,
            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
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
    );
  }
}
