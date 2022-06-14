import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Constants.dart';
import '../../../blocs/progression_handler_bloc.dart';
import '../../../screens/progression_screen/widgets/reharmonize_range.dart';
import '../../../utilities.dart';
import '../../../widgets/custom_button.dart';

class ReharmonizeBar extends StatelessWidget {
  const ReharmonizeBar({Key? key, this.enabled = true}) : super(key: key);

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomButton(
          label: 'Reharmonize!',
          iconData: Icons.bubble_chart_rounded,
          borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(Constants.borderRadius)),
          onPressed: enabled
              ? () {
                  ProgressionHandlerBloc bloc =
                      BlocProvider.of<ProgressionHandlerBloc>(context);
                  if (bloc.rangeDisabled) {
                    Utilities.showSnackBar(
                      context,
                      "Can't reharmonize with no range selected.",
                      SnackBarType.error,
                    );
                  } else {
                    bloc.add(const Reharmonize());
                  }
                }
              : null,
        ),
        ReharmonizeRange(enabled: enabled),
      ],
    );
  }
}
