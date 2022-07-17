import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../widgets/custom_button.dart';

class NavigationButtonsBar extends StatelessWidget {
  const NavigationButtonsBar({
    Key? key,
    this.vertical = false,
    required this.onBackwards,
    required this.onForward,
  }) : super(key: key);

  final bool vertical;
  final void Function() onBackwards;
  final void Function() onForward;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomButton(
          label: null,
          tight: true,
          small: true,
          iconSize: vertical ? 16.0 : 12.0,
          borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(Constants.smallBorderRadius)),
          iconData: vertical
              ? Icons.expand_less_rounded
              : Icons.arrow_back_ios_rounded,
          onPressed: onBackwards,
        ),
        const SizedBox(
          height: 15.0,
          width: 1.0,
          child: ColoredBox(color: Colors.grey),
        ),
        CustomButton(
          label: null,
          tight: true,
          small: true,
          iconSize: vertical ? 16.0 : 12.0,
          borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(Constants.smallBorderRadius)),
          iconData: vertical
              ? Icons.expand_more_rounded
              : Icons.arrow_forward_ios_rounded,
          onPressed: onForward,
        ),
      ],
    );
  }
}
