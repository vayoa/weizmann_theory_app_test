import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../widgets/custom_button.dart';

class NavigationButtonsBar extends StatelessWidget {
  const NavigationButtonsBar({
    Key? key,
    this.vertical = false,
    this.small = true,
    this.disable = false,
    required this.onNavigation,
  }) : super(key: key);

  final bool vertical;
  final bool small;
  final bool disable;
  final void Function(bool forward, bool longPress) onNavigation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomButton(
          label: null,
          tight: true,
          small: small,
          iconSize: vertical ? 16.0 : 12.0,
          borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(Constants.smallBorderRadius)),
          iconData: vertical
              ? Icons.expand_less_rounded
              : Icons.arrow_back_ios_rounded,
          onPressed: disable ? null : () => onNavigation(false, false),
          onLongPressed: disable ? null : () => onNavigation(false, true),
        ),
        SizedBox(
          height: small ? 15.0 : 20.0,
          width: 1.0,
          child: const ColoredBox(color: Colors.grey),
        ),
        CustomButton(
          label: null,
          tight: true,
          small: small,
          iconSize: vertical ? 16.0 : 12.0,
          borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(Constants.smallBorderRadius)),
          iconData: vertical
              ? Icons.expand_more_rounded
              : Icons.arrow_forward_ios_rounded,
          onPressed: disable ? null : () => onNavigation(true, false),
          onLongPressed: disable ? null : () => onNavigation(true, true),
        ),
      ],
    );
  }
}
