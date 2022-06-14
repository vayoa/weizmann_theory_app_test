import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/extensions/pitch_extension.dart';
import 'package:harmony_theory/modals/pitch_scale.dart';
import 'package:tonic/tonic.dart';

import '../../../Constants.dart';
import '../../../blocs/progression_handler_bloc.dart';
import '../../../widgets/custom_button.dart';

class ScaleChooser extends StatefulWidget {
  const ScaleChooser({Key? key, this.enabled = true}) : super(key: key);

  final bool enabled;

  @override
  State<ScaleChooser> createState() => _ScaleChooserState();
}

class _ScaleChooserState extends State<ScaleChooser> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _controller.text = '';
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressionHandlerBloc, ProgressionHandlerState>(
        buildWhen: (context, state) => state is ScaleChanged,
        builder: (context, state) {
          ProgressionHandlerBloc bloc =
              BlocProvider.of<ProgressionHandlerBloc>(context);
          if (bloc.currentScale == null) {
            return CustomButton(
              label: 'Guess Scale',
              iconData: Icons.piano_rounded,
              onPressed: widget.enabled
                  ? () => setState(() {
                        bloc.add(CalculateScale());
                      })
                  : null,
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
                          controller: _controller,
                          focusNode: _focusNode,
                          enabled: widget.enabled,
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.blue),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp('[a-gA-G#b♯♭]')),
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            isDense: true,
                            hintText: currentTonicName,
                            hintStyle: const TextStyle(fontSize: 14.0),
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
                      TextButton(
                        child: Text(minor ? 'Minor' : 'Major'),
                        style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(Constants.borderRadius)),
                          ),
                        ),
                        onPressed: widget.enabled
                            ? () => bloc.add(ChangeScale(current.switchPattern))
                            : null,
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
