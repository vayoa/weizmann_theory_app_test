import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/state/progression_bank.dart';
import 'package:harmony_theory/state/progression_bank_entry.dart';
import 'package:weizmann_theory_app_test/blocs/input/input_cubit.dart';

import '../../blocs/audio_player/audio_player_bloc.dart';
import '../../blocs/bank/bank_bloc.dart';
import '../../blocs/progression_handler_bloc.dart';
import '../../blocs/substitution_handler/substitution_handler_bloc.dart'
    hide TypeChanged;
import '../../constants.dart';
import '../../modals/progression_type.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_icon_button.dart';
import 'widgets/bank_progression_button.dart';
import 'widgets/bpm_input.dart';
import 'widgets/progression/selectable_progression_view.dart';
import 'widgets/progression_screen_top_bar.dart';
import 'widgets/progression_title.dart';
import 'widgets/reharmonize_bar.dart';
import 'widgets/scale_chooser.dart';
import 'widgets/substitution_drawer/substitution_drawer.dart';
import 'widgets/substitution_drawer/substitution_overlay/substitution_overlay.dart';
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
        BlocProvider(
            create: (context) =>
                InputCubit(BlocProvider.of<ProgressionHandlerBloc>(context)))
      ],
      child: Scaffold(
        body: LayoutBuilder(builder: (context, constraints) {
          const double smallWidth = 700 + Constants.measureWidth;
          if (constraints.maxWidth > smallWidth) {
            return Row(
              children: [
                const SubstitutionDrawer(popup: false),
                Expanded(
                  child: ProgressionScreenUI(
                    initiallyBanked: initiallyBanked,
                  ),
                ),
              ],
            );
          } else {
            return Stack(
              children: [
                ProgressionScreenUI(
                  initiallyBanked: initiallyBanked,
                ),
                const SubstitutionDrawer(popup: true),
              ],
            );
          }
        }),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, right: 30.0, left: 30.0),
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
                  ProgressionScreenTopBar(location: location),
                  Row(
                    children: [
                      ProgressionTitle(title: location.title),
                      BankProgressionButton(
                        initiallyBanked: initiallyBanked,
                        onToggle: (active) {
                          BlocProvider.of<BankBloc>(context).add(
                              ChangeUseInSubstitutions(
                                  location:
                                      BlocProvider.of<ProgressionHandlerBloc>(
                                              context)
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
                            ignoring: BlocProvider.of<ProgressionHandlerBloc>(
                                        context,
                                        listen: true)
                                    .progressionEmpty ||
                                BlocProvider.of<ProgressionHandlerBloc>(context,
                                            listen: true)
                                        .currentScale ==
                                    null ||
                                (state is Playing && !state.baseControl),
                            child: BlocBuilder<SubstitutionHandlerBloc,
                                SubstitutionHandlerState>(
                              builder: (context, subState) {
                                SubstitutionHandlerBloc subBloc =
                                    BlocProvider.of<SubstitutionHandlerBloc>(
                                        context);
                                final bool showSubs =
                                    (subBloc.variationGroups?.isNotEmpty ??
                                            false) &&
                                        subBloc.visible;
                                final Color? color = showSubs
                                    ? Constants.substitutionColor
                                    : null;
                                return Row(
                                  children: [
                                    TIconButton(
                                      iconData: (state is Playing &&
                                              state.baseControl)
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 32,
                                      crop: true,
                                      color: color,
                                      onPressed: () {
                                        AudioPlayerBloc bloc =
                                            BlocProvider.of<AudioPlayerBloc>(
                                                context);
                                        if (state is Playing) {
                                          bloc.add(const Pause());
                                        } else {
                                          final bool showSubs = (subBloc
                                                      .variationGroups
                                                      ?.isNotEmpty ??
                                                  false) &&
                                              subBloc.visible;
                                          final progBloc = BlocProvider.of<
                                              ProgressionHandlerBloc>(context);
                                          final scale = progBloc.currentScale;
                                          if (scale != null) {
                                            bloc.add(Play(
                                              measures: showSubs
                                                  ? subBloc
                                                      .currentlyViewedSubstitutionChordMeasures(
                                                          scale)
                                                  : progBloc.chordMeasures,
                                              basePlaying: true,
                                            ));
                                          }
                                        }
                                      },
                                    ),
                                    TIconButton(
                                      iconData: Icons.stop_rounded,
                                      size: 32,
                                      color: color,
                                      onPressed: () =>
                                          BlocProvider.of<AudioPlayerBloc>(
                                                  context)
                                              .add(const Reset()),
                                    ),
                                  ],
                                );
                              },
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
                        buildWhen: (_, state) => state is ChangedTimeSignature,
                        builder: (context, state) {
                          return TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(40, 36),
                              primary: Colors.black,
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                            ),
                            onPressed: BlocProvider.of<SubstitutionHandlerBloc>(
                                        context,
                                        listen: true)
                                    .currentlyHarmonizing
                                ? null
                                : () => BlocProvider.of<ProgressionHandlerBloc>(
                                        context)
                                    .add(const ChangeTimeSignature()),
                            child: Text(
                              BlocProvider.of<ProgressionHandlerBloc>(context)
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
                      children: [
                        BlocBuilder<ProgressionHandlerBloc,
                            ProgressionHandlerState>(
                          buildWhen: (previous, state) => state is TypeChanged,
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
                                if (newType == ProgressionType.romanNumerals ||
                                    bloc.currentScale != null) {
                                  bloc.add(SwitchType(newType));
                                  return true;
                                }
                                return false;
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 10.0),
                        BlocBuilder<SubstitutionHandlerBloc,
                            SubstitutionHandlerState>(
                          builder: (context, state) {
                            final bloc =
                                BlocProvider.of<SubstitutionHandlerBloc>(
                                    context);
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeInOut,
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween(
                                    begin: const Offset(0, 0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                              child: bloc.currentlyHarmonizing
                                  ? bloc.showingDrawer
                                      ? const SizedBox()
                                      : const SetSubstitutionOverlay()
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ScaleChooser(
                                            enabled:
                                                !bloc.currentlyHarmonizing),
                                        const SizedBox(width: 10.0),
                                        ReharmonizeBar(
                                            enabled:
                                                !bloc.currentlyHarmonizing),
                                        const SizedBox(width: 10.0),
                                        CustomButton(
                                          label: 'Surprise Me',
                                          iconData: Icons.lightbulb,
                                          onPressed: bloc.currentlyHarmonizing
                                              ? null
                                              : () => BlocProvider.of<
                                                          ProgressionHandlerBloc>(
                                                      context)
                                                  .add(const SurpriseMe()),
                                        ),
                                      ],
                                    ),
                            );
                          },
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
                    location: BlocProvider.of<ProgressionHandlerBloc>(context)
                        .location,
                    progression:
                        BlocProvider.of<ProgressionHandlerBloc>(context)
                            .currentProgression,
                  ));
                } else if (state is InvalidInputReceived) {
                  Duration duration = const Duration(seconds: 4);
                  String message = 'An invalid value was inputted:'
                      '\n${state.exception}';
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
                return BlocBuilder<SubstitutionHandlerBloc,
                    SubstitutionHandlerState>(
                  builder: (context, state) {
                    SubstitutionHandlerBloc subBloc =
                        BlocProvider.of<SubstitutionHandlerBloc>(context);
                    final bool hasSubs =
                        (subBloc.variationGroups?.isNotEmpty ?? false);
                    final bool showSubs = hasSubs && subBloc.visible;
                    return SelectableProgressionView(
                      progression: showSubs
                          ? subBloc.currentlyViewedSubstitution(
                              bloc.currentScale, bloc.type)
                          : bloc.currentlyViewedProgression,
                      measures: showSubs ? null : bloc.currentlyViewedMeasures,
                      startRange: bloc.fromDur,
                      endRange: bloc.toDur,
                      rangeDisabled: bloc.rangeDisabled,
                      interactable: !hasSubs,
                      highlightFrom: showSubs
                          ? subBloc.currentSubstitution!.subContext.insertStart
                          : null,
                      highlightTo: showSubs
                          ? subBloc.currentSubstitution!.subContext.insertEnd
                          : null,
                      onChangeRange: (start, end) {
                        if (start == null || end == null) {
                          BlocProvider.of<ProgressionHandlerBloc>(context)
                              .add(const DisableRange(disable: true));
                        } else {
                          BlocProvider.of<ProgressionHandlerBloc>(context)
                              .add(ChangeRangeDuration(start: start, end: end));
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
