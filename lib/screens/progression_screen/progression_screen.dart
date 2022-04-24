import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/exceptions.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/state/progression_bank_entry.dart';
import 'package:tonic/tonic.dart';
import 'package:weizmann_theory_app_test/blocs/bank/bank_bloc.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/BankProgressionButton.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/bpm_input.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/progression_title.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/reharmonize_bar.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/substitution_window.dart';

import '../../blocs/audio_player/audio_player_bloc.dart';
import '../../blocs/progression_handler_bloc.dart';
import '../../blocs/substitution_handler/substitution_handler_bloc.dart';
import '../../widgets/TButton.dart';
import '../../widgets/t_icon_button.dart';
import 'widgets/progression/selectable_progression_view.dart';
import 'widgets/scale_chooser.dart';
import 'widgets/view_type_selector.dart';

class ProgressionScreen extends StatelessWidget {
  const ProgressionScreen({
    Key? key,
    required this.bankBloc,
    required this.entry,
    required this.title,
    required this.initiallyBanked,
  }) : super(key: key);

  final BankBloc bankBloc;
  final ProgressionBankEntry entry;
  final String title;
  final bool initiallyBanked;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => bankBloc),
        BlocProvider(create: (_) => SubstitutionHandlerBloc()),
        BlocProvider(
          create: (context) => ProgressionHandlerBloc(
            currentProgression: entry.progression,
            substitutionHandlerBloc:
                BlocProvider.of<SubstitutionHandlerBloc>(context),
          ),
        ),
        BlocProvider(create: (_) => AudioPlayerBloc()),
      ],
      child: Scaffold(
        body: ProgressionScreenUI(
          title: title,
          initiallyBanked: initiallyBanked,
        ),
      ),
    );
  }
}

class ProgressionScreenUI extends StatelessWidget {
  const ProgressionScreenUI({
    Key? key,
    required this.title,
    required this.initiallyBanked,
  }) : super(key: key);

  final String title;
  final bool initiallyBanked;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          ProgressionTitle(title: title),
                          BankProgressionButton(
                            initiallyBanked: initiallyBanked,
                            onToggle: (active) {},
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                            builder: (context, state) {
                              return IgnorePointer(
                                // TODO: Find a better place for this.
                                ignoring:
                                    BlocProvider.of<ProgressionHandlerBloc>(
                                            context,
                                            listen: true)
                                        .progressionEmpty,
                                child: Row(
                                  children: [
                                    TIconButton(
                                      iconData: state is Playing
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 32,
                                      crop: true,
                                      onPressed: () {
                                        AudioPlayerBloc bloc =
                                            BlocProvider.of<AudioPlayerBloc>(
                                                context);
                                        if (state is Playing) {
                                          bloc.add(const Pause());
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
                                    TIconButton(
                                      iconData: Icons.stop_rounded,
                                      size: 32,
                                      onPressed: () =>
                                          BlocProvider.of<AudioPlayerBloc>(
                                                  context)
                                              .add(const Reset()),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Text(
                            " 00 / 34s  BPM: ",
                            style: TextStyle(fontSize: 16),
                          ),
                          const BPMInput(),
                          const Text(
                            ', ',
                            style: TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            child: const Text(
                              '4/4',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(40, 36),
                              primary: Colors.black,
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                            ),
                            onPressed: () {},
                          )
                        ],
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                            minHeight: 24, maxHeight: 24, maxWidth: 600),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ViewTypeSelector(
                              tight: true,
                              startOnChords: false,
                              onPressed: (newType) =>
                                  BlocProvider.of<ProgressionHandlerBloc>(
                                          context)
                                      .add(SwitchType(newType)),
                            ),
                            const ScaleChooser(),
                            const ReharmonizeBar(),
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
                            ? (e.value as Chord).commonName
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
    );
  }
}
