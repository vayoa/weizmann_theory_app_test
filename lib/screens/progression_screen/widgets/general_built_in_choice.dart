import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../widgets/dialogs.dart';

class GeneralBuiltInChoice extends StatelessWidget {
  const GeneralBuiltInChoice({
    Key? key,
    required this.prefix,
    required this.onPressed,
  }) : super(key: key);

  final String prefix;
  final void Function(bool) onPressed;

  @override
  Widget build(BuildContext context) {
    return GeneralDialogChoice(
      title: Text.rich(
        TextSpan(
          text: prefix,
          style: Constants.valuePatternTextStyle,
          children: const [
            TextSpan(
              text: 'built-in entry ',
              style: Constants.boldedValuePatternTextStyle,
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.aboveBaseline,
              child: Icon(Constants.builtInIcon, size: 12),
              baseline: TextBaseline.alphabetic,
            ),
            TextSpan(
              text: ' ?',
              style: Constants.boldedValuePatternTextStyle,
            ),
          ],
        ),
        maxLines: 2,
        textAlign: TextAlign.center,
        style: Constants.valuePatternTextStyle,
      ),
      onPressed: onPressed,
    );
  }
}
