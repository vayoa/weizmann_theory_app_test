import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/modals/pitch_chord.dart';
import 'package:harmony_theory/modals/progression/exceptions.dart';
import 'package:harmony_theory/modals/progression/progression.dart';
import 'package:harmony_theory/state/progression_bank.dart';
import 'package:harmony_theory/state/progression_bank_entry.dart';

import '../../Constants.dart';
import '../../blocs/audio_player/audio_player_bloc.dart';
import '../../blocs/bank/bank_bloc.dart';
import '../../blocs/progression_handler_bloc.dart';
import '../../blocs/substitution_handler/substitution_handler_bloc.dart'
    hide TypeChanged;
import '../../modals/progression_type.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_icon_button.dart';
import 'widgets/bank_progression_button.dart';
import 'widgets/bpm_input.dart';
import 'widgets/progression/selectable_progression_view.dart';
import 'widgets/progression_title.dart';
import 'widgets/reharmonize_bar.dart';
import 'widgets/scale_chooser.dart';
import 'widgets/substitution_window.dart';
import 'widgets/view_type_selector.dart';

class ProgressionScreen extends StatelessWidget {
  const ProgressionScreen({
    Key? key,
    required this.bankBloc,
    required this.location,
    required this.entry,
    required this.initiallyBanked,
  }) : super(key: key);

  final BankBloc bankBloc;
  final EntryLocation location;
  final ProgressionBankEntry entry;
  final bool initiallyBanked;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BankBloc>.value(value: bankBloc),
        BlocProvider(create: (_) => SubstitutionHandlerBloc()),
        BlocProvider(
          create: (context) => ProgressionHandlerBloc(
            initialLocation: location,
            currentProgression: entry.progression,
            substitutionHandlerBloc:
                BlocProvider.of<SubstitutionHandlerBloc>(context),
          ),
        ),
        BlocProvider(create: (_) => AudioPlayerBloc()),
      ],
      child: Scaffold(
        body: ProgressionScreenUI(
          initiallyBanked: initiallyBanked,
        ),
      ),
    );
  }
}

class ProgressionScreenUI extends StatelessWidget {
  const ProgressionScreenUI({
    Key? key,
    required this.initiallyBanked,
  }) : super(key: key);

  final bool initiallyBanked;

  @override
  Widget build(BuildContext context) {
    final EntryLocation location =
        BlocProvider.of<ProgressionHandlerBloc>(context).location;
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
                          BlocBuilder<ProgressionHandlerBloc,
                              ProgressionHandlerState>(
                            buildWhen: (prev, state) =>
                                state is ChangedLocation,
                            builder: (context, state) {
                              final EntryLocation location =
                                  BlocProvider.of<ProgressionHandlerBloc>(
                                          context)
                                      .location;
                              return CustomButton(
                                label: 'Library / ${location.package}',
                                tight: true,
                                size: 12,
                                iconData: Constants.backIcon,
                                onPressed: () => Navigator.pop(context),
                              );
                            },
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
                          ProgressionTitle(title: location.title),
                          BankProgressionButton(
                            initiallyBanked: initiallyBanked,
                            onToggle: (active) {
                              BlocProvider.of<BankBloc>(context).add(
                                  ChangeUseInSubstitutions(
                                      location: BlocProvider.of<
                                              ProgressionHandlerBloc>(context)
                                          .location,
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
                                          List<Progression<PitchChord>> chords =
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
                                child: Text(
                                  BlocProvider.of<ProgressionHandlerBloc>(
                                          context)
                                      .currentProgression
                                      .timeSignature
                                      .toString(),
                                  style: const TextStyle(fontSize: 16.0),
                                ),
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
                                    ProgressionHandlerBloc bloc =
                                        BlocProvider.of<ProgressionHandlerBloc>(
                                            context);
                                    if (newType ==
                                            ProgressionType.romanNumerals ||
                                        bloc.currentScale != null) {
                                      bloc.add(SwitchType(newType));
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
                        location:
                            BlocProvider.of<ProgressionHandlerBloc>(context)
                                .location,
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
                        String value = e.value is String
                            ? e.value
                            : (e.value == null ? '//' : e.value.toString());
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
