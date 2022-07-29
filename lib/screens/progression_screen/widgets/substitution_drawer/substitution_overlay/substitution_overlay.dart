import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weizmann_theory_app_test/blocs/substitution_handler/substitution_handler_bloc.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/substitution_drawer/navigation_buttons.dart';
import 'package:weizmann_theory_app_test/widgets/custom_button.dart';

class SubstitutionOverlay extends StatelessWidget {
  const SubstitutionOverlay({Key? key}) : super(key: key);

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
            onPressed: () {},
          ),
          const SizedBox(width: 5.0),
          CustomButton(
            label: null,
            tight: true,
            small: true,
            iconSize: 14.0,
            iconData: Icons.visibility_rounded,
            onPressed: () {},
          ),
          const SizedBox(width: 5.0),
          NavigationButtonsBar(
            onNavigation: (forward) =>
                BlocProvider.of<SubstitutionHandlerBloc>(context)
                    .add(ChangeSubstitutionIndexInOrder(forward)),
          ),
          const SizedBox(width: 5.0),
          CustomButton(
            label: null,
            tight: true,
            small: true,
            iconSize: 14.0,
            iconData: Icons.read_more_rounded,
            onPressed: () => BlocProvider.of<SubstitutionHandlerBloc>(context)
                .add(const UpdateShowSubstitutions(true)),
          ),
        ],
      ),
    );
  }
}
