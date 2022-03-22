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
        return ExpansionTile(
          title: Row(
            children: [
              Text('${detail.key}:'),
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
                  '${detail.value.score.toStringAsFixed(2)} / ${weight.importance}'),
            ],
          ),
          expandedAlignment: Alignment.topLeft,
          childrenPadding: const EdgeInsets.only(left: 22.0),
          children: [
            Text(
              detail.value.details,
              style: const TextStyle(fontSize: 15),
            )
          ],
        );
      },
    );
  }
}
