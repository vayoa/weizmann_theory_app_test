import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/extensions/pitch_extension.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:tonic/tonic.dart';
import 'package:weizmann_theory_app_test/widgets/TButton.dart';

import '../../../Constants.dart';
import '../../../blocs/progression_handler_bloc.dart';

class ScaleChooser extends StatefulWidget {
  const ScaleChooser({Key? key}) : super(key: key);

  @override
  State<ScaleChooser> createState() => _ScaleChooserState();
}

class _ScaleChooserState extends State<ScaleChooser> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressionHandlerBloc, ProgressionHandlerState>(
        buildWhen: (context, state) =>
            state is ScaleChanged || state is RecalculatedScales,
        builder: (context, state) {
          ProgressionHandlerBloc bloc =
              BlocProvider.of<ProgressionHandlerBloc>(context);
          if (bloc.currentScale == null) {
            return TButton(
              label: 'Guess Scale',
              iconData: Icons.piano_rounded,
              onPressed: () => setState(() {
                bloc.add(CalculateScale());
              }),
            );
          }
          PitchScale current = bloc.currentScale!;
          bool minor = current.isMinor;
          String currentTonicName = current.tonic.commonName;
          return SizedBox(
            width: 85,
            height: 25,
            child: Material(
              borderRadius: BorderRadius.circular(Constants.borderRadius),
              color: Constants.buttonBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TextField(
                          style: const TextStyle(fontSize: 14.0),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp('[a-gA-G#b]')),
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: currentTonicName,
                            isDense: true,
                          ),
                          onSubmitted: (newTonic) {
                            String prev = newTonic;
                            newTonic = newTonic[0].toUpperCase();
                            if (prev.length > 1) newTonic += prev[1];
                            if (newTonic != currentTonicName) {
                              bloc.add(ChangeScale(PitchScale.common(
                                  tonic: Pitch.parse(newTonic), minor: minor)));
                            }
                          },
                        ),
                      ),
                      OutlinedButton(
                        child: Text(minor ? 'Minor' : 'Major'),
                        style: OutlinedButton.styleFrom(
                          primary: Colors.black,
                          padding: EdgeInsets.zero,
                          backgroundColor: Constants.buttonBackgroundColor,
                          side: BorderSide.none,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(Constants.borderRadius)),
                          ),
                        ),
                        onPressed: () =>
                            bloc.add(ChangeScale(current.switchPattern)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
