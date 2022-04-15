import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/reharmonize_range.dart';

import '../../../Constants.dart';
import '../../../blocs/progression_handler_bloc.dart';
import '../../../widgets/TButton.dart';

class ReharmonizeBar extends StatelessWidget {
  const ReharmonizeBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TButton(
          label: 'Reharmonize!',
          iconData: Icons.bubble_chart_rounded,
          borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(Constants.borderRadius)),
          onPressed: () {
            ProgressionHandlerBloc bloc =
                BlocProvider.of<ProgressionHandlerBloc>(context);
            if (bloc.rangeDisabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text("Can't reharmonize with no range selected."),
                ),
              );
            } else {
              bloc.add(Reharmonize());
            }
          },
        ),
        const ReharmonizeRange(),
      ],
    );
  }
}
