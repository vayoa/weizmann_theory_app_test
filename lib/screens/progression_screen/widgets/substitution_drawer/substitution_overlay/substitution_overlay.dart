import 'package:flutter/material.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/substitution_drawer/navigation_buttons.dart';
import 'package:weizmann_theory_app_test/widgets/custom_button.dart';

import '../../../../../constants.dart';

class SubstitutionOverlay extends StatefulWidget {
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
  State<SubstitutionOverlay> createState() => _SubstitutionOverlayState();
}

class _SubstitutionOverlayState extends State<SubstitutionOverlay> {
  bool _locked = false;

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
            color: Constants.substitutionColor,
            iconData: Icons.check_rounded,
            onPressed: widget.onApply,
          ),
          const SizedBox(width: 5.0),
          CustomButton(
            label: null,
            tight: true,
            small: true,
            iconSize: 14.0,
            iconData: widget.visible
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            onPressed: _lock,
            onHover: (entered) {
              if (_locked && entered) {
                _lock();
              }
              if (entered || !_locked) {
                widget.onChangeVisibility();
              }
            },
          ),
          const SizedBox(width: 5.0),
          NavigationButtonsBar(
            onNavigation: widget.onNavigation,
          ),
          const SizedBox(width: 5.0),
          CustomButton(
            label: null,
            tight: true,
            small: true,
            iconSize: 14.0,
            iconData: Icons.read_more_rounded,
            onPressed: widget.onOpenDrawer,
          ),
        ],
      ),
    );
  }

  void _lock() => setState(() => _locked = !_locked);
}
