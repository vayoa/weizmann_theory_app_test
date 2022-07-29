import 'package:flutter/material.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/substitution_drawer/navigation_buttons.dart';
import 'package:weizmann_theory_app_test/widgets/custom_button.dart';

class SubstitutionOverlay extends StatelessWidget {
  const SubstitutionOverlay({
    Key? key,
    required this.visible,
    required this.onNavigation,
    required this.onApply,
    required this.onOpenDrawer,
    required this.onChangeVisibility,
  }) : super(key: key);

  final bool visible;
  final void Function(bool forward) onNavigation;
  final void Function() onApply;
  final void Function() onOpenDrawer;
  final void Function() onChangeVisibility;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          const SizedBox(width: 5.0),
          CustomButton(
            label: 'Apply',
            tight: true,
            small: true,
            size: 12.0,
            iconSize: 14.0,
            iconData: Icons.check_rounded,
            onPressed: onApply,
          ),
          const SizedBox(width: 5.0),
          CustomButton(
            label: null,
            tight: true,
            small: true,
            iconSize: 14.0,
            iconData: visible
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            onPressed: onChangeVisibility,
          ),
          const SizedBox(width: 5.0),
          NavigationButtonsBar(
            onNavigation: onNavigation,
          ),
          const SizedBox(width: 5.0),
          CustomButton(
            label: null,
            tight: true,
            small: true,
            iconSize: 14.0,
            iconData: Icons.read_more_rounded,
            onPressed: onOpenDrawer,
          ),
        ],
      ),
    );
  }
}
