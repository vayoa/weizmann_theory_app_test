import 'package:flutter/material.dart';
import 'package:harmony_theory/modals/substitution.dart';

import '../../../../constants.dart';
import '../../../../widgets/custom_icon_button.dart';
import '../../../../widgets/dialogs.dart';
import '../weights_view.dart';

class WeightPreviewButton extends StatelessWidget {
  const WeightPreviewButton({
    Key? key,
    required this.substitution,
    this.size = Constants.measurePatternFontSize * 0.8,
  }) : super(key: key);

  final Substitution substitution;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TIconButton(
      iconData: Icons.notes_rounded,
      size: size,
      onPressed: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Details',
          pageBuilder: (context, _, __) => GeneralDialogPage(
            title: 'Details',
            child: Expanded(child: WeightsPreview(score: substitution.score)),
          ),
        );
      },
    );
  }
}
