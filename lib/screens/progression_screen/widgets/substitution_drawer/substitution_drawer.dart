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

part 'heading.dart';

part 'list.dart';

part 'middle_bar.dart';

part 'preferences.dart';

part 'substitution.dart';

part 'top_bar.dart';

part 'wrapper.dart';

class SubstitutionDrawer extends StatelessWidget {
  const SubstitutionDrawer({
    Key? key,
    required this.popup,
  }) : super(key: key);

  final bool popup;

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
            popup: popup,
            show: true,
            onUpdate: handleShowing,
            child: subBloc.inSetup
                ? const SizedBox()
                : (state is CalculatingSubstitutions
                    ? const _LoadingSubs()
                    : (subBloc.substitutions!.isEmpty
                        ? const _NoSubsFound()
                        : _List(
                            substitutions: subBloc.substitutions!,
                          ))),
          );
        }
      },
    );
  }

  void handleShowing(bool shouldShow) {}
}

class _LoadingSubs extends StatelessWidget {
  const _LoadingSubs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(width: 20),
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
    return const Center(
      child: Text(
        'No Substitutions Were found.',
        style: Constants.valuePatternTextStyle,
      ),
    );
  }
}
