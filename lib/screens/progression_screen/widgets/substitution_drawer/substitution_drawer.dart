import 'package:english_words/english_words.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:harmony_theory/modals/progression/progression.dart';
import 'package:harmony_theory/modals/substitution_match.dart';
import 'package:harmony_theory/modals/weights/keep_harmonic_function_weight.dart';
import 'package:harmony_theory/modals/weights/weight.dart';
import 'package:harmony_theory/state/progression_bank.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/progression/progression_view.dart';
import 'package:weizmann_theory_app_test/utilities.dart';
import 'package:weizmann_theory_app_test/widgets/custom_button.dart';
import 'package:weizmann_theory_app_test/widgets/custom_icon_button.dart';
import 'package:weizmann_theory_app_test/widgets/custom_selector.dart';
import 'package:weizmann_theory_app_test/widgets/text_and_icon.dart';

import '../../../../Constants.dart';
import '../../../../blocs/substitution_handler/substitution_handler_bloc.dart';

part 'content.dart';
part 'heading.dart';
part 'list.dart';
part 'middle_bar.dart';
part 'preferences.dart';
part 'substitution.dart';
part 'top_bar.dart';

class SubstitutionDrawer extends StatefulWidget {
  const SubstitutionDrawer({
    Key? key,
    required this.popup,
  }) : super(key: key);

  static const double topPadding = 24.0;
  static const double horizontalPadding = 10.0;
  static const double drawerWidth = Constants.measureWidth;
  final bool popup;

  @override
  State<SubstitutionDrawer> createState() => _SubstitutionDrawerState();
}

class _SubstitutionDrawerState extends State<SubstitutionDrawer> {
  bool _showing = true;

  @override
  Widget build(BuildContext context) {
    const durationMilliseconds = 400;
    const Curve curve = Curves.easeInOut;
    return MouseRegion(
      onEnter: (_) {
        if (widget.popup && !_showing) _show();
      },
      onExit: (_) {
        if (widget.popup && _showing) _show();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: durationMilliseconds),
        curve: curve,
        height: double.infinity,
        width: _showing ? SubstitutionDrawer.drawerWidth : 20.0,
        decoration: BoxDecoration(
          color: Constants.libraryEntryColor,
          borderRadius: _showing
              ? const BorderRadius.only(
                  topRight: Radius.circular(Constants.borderRadius))
              : BorderRadius.zero,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: durationMilliseconds),
          switchOutCurve: curve,
          switchInCurve: curve,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                  begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .animate(animation),
              child: child,
            ),
          ),
          child: !_showing
              ? GestureDetector(
            onTap: _show,
            child: const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding:
                EdgeInsets.only(top: SubstitutionDrawer.topPadding),
                child: Icon(Icons.arrow_forward_ios_rounded, size: 12.0),
              ),
            ),
          )
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              // TODO: Sort this without a sized box somehow, in a cleaner way...
              width: SubstitutionDrawer.drawerWidth,
              child: _Content(
                popup: widget.popup,
                onClose: _show,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _show() => setState(() => _showing = !_showing);
}
