import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:weizmann_theory_app_test/widgets/TButton.dart';
import 'package:weizmann_theory_app_test/widgets/TDropdownButton.dart';

import '../../blocs/progression_handler_bloc.dart';

class ScaleChooser extends StatefulWidget {
  const ScaleChooser({Key? key}) : super(key: key);

  @override
  State<ScaleChooser> createState() => _ScaleChooserState();
}

class _ScaleChooserState extends State<ScaleChooser> {
  @override
  Widget build(BuildContext context) {
    // return SizedBox(
    //   width: 100,
    //   height: 25,
    //   child: Row(
    //     children: [
    //       SizedBox(
    //         width: 25,
    //         child: TextField(
    //           inputFormatters: [
    //             FilteringTextInputFormatter.allow(RegExp('[a-gA-G#b]')),
    //             LengthLimitingTextInputFormatter(2),
    //           ],
    //         ),
    //       ),
    //       OutlinedButton(
    //         child: Text('Minor'),
    //         onPressed: () {},
    //       ),
    //     ],
    //   ),
    // );
    return BlocBuilder<ProgressionHandlerBloc, ProgressionHandlerState>(
        buildWhen: (context, state) =>
            state is ScaleChanged || state is RecalculatedScales,
        builder: (context, state) {
          ProgressionHandlerBloc bloc =
              BlocProvider.of<ProgressionHandlerBloc>(context);
          if (bloc.scales == null || bloc.scales!.isEmpty) {
            return TButton(
              label: 'Calculate Scale',
              iconData: Icons.piano_rounded,
              onPressed: () => setState(() {
                bloc.add(CalculateScale());
              }),
            );
          }
          return TDropdownButton<PitchScale>(
            value: bloc.scales![bloc.currentScale],
            items: bloc.scales!,
            onChanged: (PitchScale? scale) {
              if (scale != null) {
                // TODO: Optimize this...
                bloc.add(ChangeScale(bloc.scales!.indexOf(scale)));
              }
            },
            valToString: (PitchScale scale) => scale.getCommonName,
          );
        });
  }
}
