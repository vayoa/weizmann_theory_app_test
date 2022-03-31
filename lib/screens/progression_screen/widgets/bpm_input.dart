import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../Constants.dart';
import '../../../blocs/audio_player/audio_player_bloc.dart';

class BPMInput extends StatefulWidget {
  const BPMInput({Key? key}) : super(key: key);

  @override
  State<BPMInput> createState() => _BPMInputState();
}

class _BPMInputState extends State<BPMInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late int bpm;

  @override
  void initState() {
    bpm = BlocProvider.of<AudioPlayerBloc>(context).bpm;
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _controller.text = '');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: BlocListener<AudioPlayerBloc, AudioPlayerState>(
        listener: (context, state) {
          if (state is ChangedBPM) {
            setState(() {
              bpm = state.newBPM;
              _controller.text = '';
            });
          }
        },
        child: IgnorePointer(
          // TODO: Improve the way this is written...
          ignoring:
              BlocProvider.of<AudioPlayerBloc>(context, listen: true).playing,
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                int newBPM = bpm + -1 * event.scrollDelta.dy.sign.toInt();
                if (newBPM >= AudioPlayerBloc.minBPM &&
                    newBPM <= AudioPlayerBloc.maxBPM) {
                  BlocProvider.of<AudioPlayerBloc>(context)
                      .add(ChangeBPM(newBPM));
                } else {
                  setState(() => _controller.text = '');
                }
              }
            },
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              inputFormatters: [
                LengthLimitingTextInputFormatter(2),
                FilteringTextInputFormatter.allow(RegExp(r'[\d]')),
              ],
              decoration: InputDecoration(
                hintText: bpm.toString(),
                isDense: true,
                border: InputBorder.none,
                focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Constants.buttonUnfocusedColor)),
              ),
              onSubmitted: (input) {
                if (input.isNotEmpty && input != bpm.toString()) {
                  int newBPM = int.parse(input);
                  if (newBPM >= AudioPlayerBloc.minBPM &&
                      newBPM <= AudioPlayerBloc.maxBPM) {
                    BlocProvider.of<AudioPlayerBloc>(context)
                        .add(ChangeBPM(newBPM));
                  } else {
                    setState(() => _controller.text = '');
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
