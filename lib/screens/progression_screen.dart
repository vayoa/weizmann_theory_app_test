import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:tonic/tonic.dart';

import '../blocs/audio_player/audio_player_bloc.dart';
import '../blocs/progression_handler_bloc.dart';
import '../widgets/TButton.dart';
import '../widgets/t_icon_button.dart';
import 'widgets/BankProgressionButton.dart';
import 'widgets/progression/selectable_progression_view.dart';
import 'widgets/reharmonize_range.dart';
import 'widgets/scale_chooser.dart';
import 'widgets/substitution_window.dart';
import 'widgets/view_type_selector.dart';

class ProgressionScreen extends StatelessWidget {
  const ProgressionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 30.0, left: 30.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 700,
                    height: 140,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TButton(
                          label: 'Back',
                          tight: true,
                          size: 12,
                          iconData: Icons.arrow_back_ios_rounded,
                          onPressed: () {},
                        ),
                        Row(
                          children: [
                            const Text(
                              "My Song's Title",
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            BankProgressionButton(
                              onToggle: (active) {},
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                              builder: (context, state) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: TIconButton(
                                    iconData: state is Playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 36,
                                    crop: true,
                                    // TODO: Find a better place for this.
                                    disabled:
                                        BlocProvider.of<ProgressionHandlerBloc>(
                                                context,
                                                listen: true)
                                            .currentProgression
                                            .isEmpty,
                                    onPressed: () {
                                      AudioPlayerBloc bloc =
                                          BlocProvider.of<AudioPlayerBloc>(
                                              context);
                                      if (state is Playing) {
                                        bloc.add(Pause());
                                      } else {
                                        List<Progression<Chord>> chords =
                                            BlocProvider.of<
                                                        ProgressionHandlerBloc>(
                                                    context)
                                                .chordMeasures;
                                        print(chords);
                                        bloc.add(Play(chords));
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                            const Text(
                              " 00 / 34s  BPM: 120, 4/4",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ViewTypeSelector(
                              tight: true,
                              onPressed: (newType) =>
                                  BlocProvider.of<ProgressionHandlerBloc>(
                                          context)
                                      .add(SwitchType(newType)),
                            ),
                            Row(
                              children: const [
                                Text(
                                  'Scale: ',
                                  style: TextStyle(fontSize: 18),
                                ),
                                ScaleChooser(),
                              ],
                            ),
                            TButton(
                              label: 'Reharmonize!',
                              iconData: Icons.bubble_chart_rounded,
                              onPressed: () {
                                BlocProvider.of<ProgressionHandlerBloc>(context)
                                    .add(Reharmonize());
                              },
                            ),
                            const ReharmonizeRange(),
                            TButton(
                              label: 'Surprise Me',
                              iconData: Icons.lightbulb,
                              onPressed: () =>
                                  BlocProvider.of<ProgressionHandlerBloc>(
                                          context)
                                      .add(SurpriseMe()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  BlocConsumer<ProgressionHandlerBloc, ProgressionHandlerState>(
                    listener: (context, state) {
                      if (state is InvalidInputReceived) {
                        Duration duration = const Duration(seconds: 4);
                        String message = 'An invalid value was inputted:'
                            '\n${state.exception}';
                        if (state.exception is NonValidDuration) {
                          NonValidDuration e =
                              state.exception as NonValidDuration;
                          String value = e.value is Chord
                              ? (e.value as Chord).getCommonName()
                              : e.value;
                          message = 'An invalid duration was inputted:'
                              '\nA value of $value in a duration of '
                              '${(e.duration * e.timeSignature.denominator).toInt()}'
                              '/${e.timeSignature.denominator} is not a valid '
                              'duration in a ${e.timeSignature} time signature.';
                          duration = const Duration(seconds: 12);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(message),
                            duration: duration,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      ProgressionHandlerBloc bloc =
                          BlocProvider.of<ProgressionHandlerBloc>(context);
                      return SelectableProgressionView(
                        measures: bloc.currentlyViewedMeasures,
                        fromChord: bloc.fromChord,
                        toChord: bloc.toChord,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SubstitutionWindow(),
        ],
      ),
    );
  }
}