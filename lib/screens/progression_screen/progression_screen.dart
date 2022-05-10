import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/exceptions.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/state/progression_bank_entry.dart';
import 'package:tonic/tonic.dart';
import 'package:weizmann_theory_app_test/blocs/bank/bank_bloc.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/bank_progression_button.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/bpm_input.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/progression_title.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/reharmonize_bar.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/substitution_window.dart';

import '../../Constants.dart';
import '../../blocs/audio_player/audio_player_bloc.dart';
import '../../blocs/progression_handler_bloc.dart';
import '../../blocs/substitution_handler/substitution_handler_bloc.dart'
    hide TypeChanged;
import '../../modals/progression_type.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_icon_button.dart';
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
    required this.builtIn,
  }) : super(key: key);

  final BankBloc bankBloc;
  final ProgressionBankEntry entry;
  final String title;
  final bool initiallyBanked;
  final bool builtIn;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BankBloc>.value(value: bankBloc),
        BlocProvider(create: (_) => SubstitutionHandlerBloc()),
        BlocProvider(
          create: (context) => ProgressionHandlerBloc(
            initialTitle: title,
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
          builtIn: builtIn,
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
    required this.builtIn,
  }) : super(key: key);

  final String title;
  final bool initiallyBanked;
  final bool builtIn;

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
                      Row(
                        children: [
                          CustomButton(
                            label: 'Back',
                            tight: true,
                            size: 12,
                            iconData: Constants.backIcon,
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          BlocBuilder<BankBloc, BankState>(
                            builder: (context, state) {
                              final bool loading = state is BankLoading;
                              return CustomButton(
                                label: loading ? 'Saving...' : 'Save',
                                tight: true,
                                size: 12,
                                iconData: loading
                                    ? Icons.hourglass_bottom_rounded
                                    : Constants.saveIcon,
                                onPressed: loading
                                    ? null
                                    : () => BlocProvider.of<BankBloc>(context)
                                        .add(const SaveToJson()),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ProgressionTitle(title: title, builtIn: builtIn),
                          BankProgressionButton(
                            initiallyBanked: initiallyBanked,
                            onToggle: (active) {
                              BlocProvider.of<BankBloc>(context).add(
                                  ChangeUseInSubstitutions(
                                      title: BlocProvider.of<
                                              ProgressionHandlerBloc>(context)
                                          .title,
                                      useInSubstitutions: active));
                            },
                          )
                        ],
                      ),
                      Row(
                        children: [
                          BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                            builder: (context, state) {
                              return IgnorePointer(
                                ignoring:
                                    BlocProvider.of<ProgressionHandlerBloc>(
                                                context,
                                                listen: true)
                                            .progressionEmpty ||
                                        BlocProvider.of<ProgressionHandlerBloc>(
                                                    context,
                                                    listen: true)
                                                .currentScale ==
                                            null ||
                                        (state is Playing &&
                                            !state.baseControl),
                                child: Row(
                                  children: [
                                    TIconButton(
                                      iconData: (state is Playing &&
                                              state.baseControl)
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
                                          bloc.add(Play(
                                            measures: chords,
                                            basePlaying: true,
                                          ));
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
                          const SizedBox(width: 6),
                          const Text(
                            "BPM: ",
                            style: TextStyle(fontSize: 16),
                          ),
                          const BPMInput(),
                          const Text(
                            ', ',
                            style: TextStyle(fontSize: 16),
                          ),
                          BlocBuilder<ProgressionHandlerBloc,
                              ProgressionHandlerState>(
                            buildWhen: (_, state) =>
                                state is ChangedTimeSignature,
                            builder: (context, state) {
                              return TextButton(
                                child: Text(
                                  BlocProvider.of<ProgressionHandlerBloc>(
                                          context)
                                      .currentProgression
                                      .timeSignature
                                      .toString(),
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(40, 36),
                                  primary: Colors.black,
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                ),
                                onPressed:
                                    BlocProvider.of<SubstitutionHandlerBloc>(
                                                context,
                                                listen: true)
                                            .showingWindow
                                        ? null
                                        : () => BlocProvider.of<
                                                ProgressionHandlerBloc>(context)
                                            .add(const ChangeTimeSignature()),
                              );
                            },
                          )
                        ],
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                            minHeight: 24, maxHeight: 24, maxWidth: 600),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BlocBuilder<ProgressionHandlerBloc,
                                ProgressionHandlerState>(
                              buildWhen: (previous, state) =>
                                  state is TypeChanged,
                              builder: (context, state) {
                                return ViewTypeSelector(
                                  tight: true,
                                  startOnChords:
                                      BlocProvider.of<ProgressionHandlerBloc>(
                                                  context)
                                              .type ==
                                          ProgressionType.chords,
                                  onPressed: (newType) {
                                    ProgressionHandlerBloc _bloc =
                                        BlocProvider.of<ProgressionHandlerBloc>(
                                            context);
                                    if (newType ==
                                            ProgressionType.romanNumerals ||
                                        _bloc.currentScale != null) {
                                      _bloc.add(SwitchType(newType));
                                      return true;
                                    }
                                    return false;
                                  },
                                );
                              },
                            ),
                            ScaleChooser(
                                enabled:
                                    !BlocProvider.of<SubstitutionHandlerBloc>(
                                            context,
                                            listen: true)
                                        .showingWindow),
                            ReharmonizeBar(
                                enabled:
                                    !BlocProvider.of<SubstitutionHandlerBloc>(
                                            context,
                                            listen: true)
                                        .showingWindow),
                            CustomButton(
                              label: 'Surprise Me',
                              iconData: Icons.lightbulb,
                              onPressed:
                                  BlocProvider.of<SubstitutionHandlerBloc>(
                                              context,
                                              listen: true)
                                          .showingWindow
                                      ? null
                                      : () => BlocProvider.of<
                                              ProgressionHandlerBloc>(context)
                                          .add(const SurpriseMe()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                BlocConsumer<ProgressionHandlerBloc, ProgressionHandlerState>(
                  listener: (context, state) {
                    if (state is ProgressionChanged) {
                      BlocProvider.of<BankBloc>(context).add(OverrideEntry(
                        title: BlocProvider.of<ProgressionHandlerBloc>(context)
                            .title,
                        progression:
                            BlocProvider.of<ProgressionHandlerBloc>(context)
                                .currentProgression,
                      ));
                    } else if (state is InvalidInputReceived) {
                      Duration duration = const Duration(seconds: 4);
                      String message = 'An invalid value was inputted:'
                          '\n${state.exception}';
                      if (state.exception is NonValidDuration) {
                        NonValidDuration e =
                            state.exception as NonValidDuration;
                        String value = e.value is Chord
                            ? (e.value as Chord).commonName
                            : (e.value as ScaleDegreeChord).toString();
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
