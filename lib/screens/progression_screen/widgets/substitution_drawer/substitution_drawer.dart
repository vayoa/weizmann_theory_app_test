import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:harmony_theory/modals/substitution.dart';
import 'package:harmony_theory/modals/substitution_match.dart';
import 'package:harmony_theory/modals/weights/keep_harmonic_function_weight.dart';
import 'package:harmony_theory/modals/weights/weight.dart';
import 'package:harmony_theory/state/progression_bank.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/substitution_drawer/navigation_buttons.dart';
import 'package:weizmann_theory_app_test/utilities.dart';
import 'package:weizmann_theory_app_test/widgets/custom_button.dart';
import 'package:weizmann_theory_app_test/widgets/custom_selector.dart';
import 'package:weizmann_theory_app_test/widgets/text_and_icon.dart';

import '../../../../blocs/substitution_handler/substitution_handler_bloc.dart';
import '../../../../constants.dart';
import '../progression/progression_grid.dart';
import '../substitution_window.dart';

part 'content.dart';
part 'harmonization_setting.dart';
part 'heading.dart';
part 'list.dart';
part 'middle_bar.dart';
part 'preferences_bar.dart';
part 'substitution.dart';
part 'top_bar.dart';
part 'wrapper.dart';

class SubstitutionDrawer extends StatefulWidget {
  const SubstitutionDrawer({
    Key? key,
    required this.popup,
  }) : super(key: key);

  final bool popup;

  @override
  State<SubstitutionDrawer> createState() => _SubstitutionDrawerState();
}

class _SubstitutionDrawerState extends State<SubstitutionDrawer> {
  bool _pinned = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubstitutionHandlerBloc, SubstitutionHandlerState>(
      listener: (_, state) {
        // if (state is CalculatedSubstitutions) {
        //   setState(() {
        //     // TODO: This throws an error but still works...
        //     WidgetsBinding.instance.addPostFrameCallback((_) {
        //       if (_controller.hasClients) {
        //         _controller.jumpToPage(0);
        //       }
        //     });
        //     _currentIndex = 0;
        //   });
        // }
      },
      builder: (context, state) {
        SubstitutionHandlerBloc subBloc =
            BlocProvider.of<SubstitutionHandlerBloc>(context);
        // ProgressionHandlerBloc progressionBloc =
        //     BlocProvider.of<ProgressionHandlerBloc>(context);
        if (!subBloc.showingWindow) {
          return const SizedBox();
        } else {
          return _Wrapper(
            pinned: _pinned,
            popup: widget.popup,
            show: subBloc.showingDrawer,
            showNav: !subBloc.inSetup &&
                state is! CalculatingSubstitutions &&
                subBloc.substitutions!.isNotEmpty,
            goDisabled: subBloc.substitutions != null,
            expandPreferences: subBloc.inSetup,
            onUpdate: (shouldShow, fromHover) =>
                handleShowing(shouldShow, fromHover, subBloc),
            onPin: () => setState(() => _pinned = !_pinned),
            onQuit: () => subBloc.add(const ClearSubstitutions()),
            onNavigation: (forward) => subBloc.add(
              ChangeSubstitutionIndex(
                subBloc.currentIndex + (forward ? 1 : -1),
              ),
            ),
            child: state is CalculatingSubstitutions
                ? const _LoadingSubs()
                : (subBloc.inSetup
                    ? const _InSetup()
                    : (subBloc.substitutions!.isEmpty
                        ? const _NoSubsFound()
                        : _List(
                            selected: subBloc.currentIndex,
                            onSelected: (index) =>
                                subBloc.add(ChangeSubstitutionIndex(index)),
                            substitutions: subBloc.substitutions!,
                          ))),
          );
        }
      },
    );
  }

  void handleShowing(
      bool shouldShow, bool fromHover, SubstitutionHandlerBloc bloc) {
    // If we're hovering make sure we're pinned...
    if (!fromHover || !_pinned) {
      bloc.add(UpdateShowSubstitutions(shouldShow));
    }
  }
}

class _LoadingSubs extends StatelessWidget {
  const _LoadingSubs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            height: 14.0,
            width: 14.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Constants.buttonUnfocusedColor,
            ),
          ),
          SizedBox(width: 10.0),
          Text('Loading...'),
        ],
      ),
    );
  }
}

class _NoSubsFound extends StatelessWidget {
  const _NoSubsFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _InfoBlock(
      TextSpan(
          text: 'No substitutions were found.\n'
              'Try changing ',
          children: [
            TextSpan(
              text: 'Preferences ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ]),
    );
  }
}

class _InSetup extends StatelessWidget {
  const _InSetup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _InfoBlock(
      TextSpan(
        text: 'Please choose reharmonization ',
        children: [
          TextSpan(
            text: 'Preferences ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'and then press ',
          ),
          TextSpan(
            text: 'Go!',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock(
    this.text, {
    Key? key,
    this.icon = Icons.help_outline_rounded,
  }) : super(key: key);

  final TextSpan text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        borderRadius: BorderRadius.circular(5.0),
        elevation: 5.0,
        color: Constants.buttonUnfocusedColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(
                icon,
                size: 24.0,
                color: Constants.buttonUnfocusedTextColor,
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text.rich(text, textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
