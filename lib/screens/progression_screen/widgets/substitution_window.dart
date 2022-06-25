import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/modals/substitution.dart';
import 'package:harmony_theory/modals/substitution_match.dart';
import 'package:harmony_theory/modals/theory_base/pitch_scale.dart';
import 'package:harmony_theory/modals/weights/keep_harmonic_function_weight.dart';
import 'package:harmony_theory/modals/weights/weight.dart';

import '../../../blocs/audio_player/audio_player_bloc.dart';
import '../../../blocs/progression_handler_bloc.dart';
import '../../../blocs/substitution_handler/substitution_handler_bloc.dart';
import '../../../constants.dart';
import '../../../modals/progression_type.dart';
import '../../../utilities.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_icon_button.dart';
import '../../../widgets/custom_selector.dart';
import '../../../widgets/dialogs.dart';
import 'progression/progression_view.dart';
import 'view_type_selector.dart';
import 'weights_view.dart';

class SubstitutionWindowCover extends StatelessWidget {
  const SubstitutionWindowCover({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.only(
          top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
      decoration: const BoxDecoration(
        color: Constants.rangeSelectColor,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(Constants.borderRadius * 3)),
      ),
      child: child,
    );
  }
}

class SubstitutionWindow extends StatefulWidget {
  const SubstitutionWindow({
    Key? key,
    this.pageSwitchDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  final Duration pageSwitchDuration;

  @override
  State<SubstitutionWindow> createState() => _SubstitutionWindowState();
}

class _SubstitutionWindowState extends State<SubstitutionWindow> {
  late final PageController _controller;
  final Curve _scrollCurve = Curves.easeInOut;
  int _currentIndex = 0;

  @override
  void initState() {
    _controller = PageController(initialPage: _currentIndex);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SubstitutionWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentIndex = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubstitutionHandlerBloc, SubstitutionHandlerState>(
      listener: (_, state) {
        if (state is CalculatedSubstitutions) {
          setState(() {
            // TODO: This throws an error but still works...
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              if (_controller.hasClients) {
                _controller.jumpToPage(0);
              }
            });
            _currentIndex = 0;
          });
        }
      },
      builder: (context, state) {
        SubstitutionHandlerBloc subBloc =
            BlocProvider.of<SubstitutionHandlerBloc>(context);
        ProgressionHandlerBloc progressionBloc =
            BlocProvider.of<ProgressionHandlerBloc>(context);
        if (state is CalculatingSubstitutions) {
          return SubstitutionWindowCover(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.topRight,
                  child: _CancelButton(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text('Loading...'),
                  ],
                ),
              ],
            ),
          );
        } else if (subBloc.inSetup) {
          return const SubstitutionWindowCover(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: SubstitutionButtonBar(
                    inSetup: true,
                  )));
        } else if (subBloc.substitutions == null) {
          return const SizedBox();
        } else if (subBloc.substitutions!.isEmpty) {
          return SubstitutionWindowCover(
              child: Column(
            children: const [
              SubstitutionButtonBar(
                inSetup: false,
              ),
              Divider(),
              Center(
                child: Text('No Substitutions Were found.',
                    style: Constants.valuePatternTextStyle),
              ),
            ],
          ));
        } else {
          final bool _surpriseMe =
              BlocProvider.of<SubstitutionHandlerBloc>(context).surpriseMe;
          return SubstitutionWindowCover(
            child: Column(
              children: [
                const SubstitutionButtonBar(
                  inSetup: false,
                ),
                const Divider(),
                SizedBox(
                  height: 200,
                  child: Listener(
                    onPointerSignal: _surpriseMe
                        ? null
                        : (signal) {
                            if (_controller.page != null &&
                                _controller.page! % 1 == 0 &&
                                signal is PointerScrollEvent) {
                              if (signal.scrollDelta.dy > 0) {
                                _nextPage(context);
                              } else {
                                _previousPage(context);
                              }
                            }
                          },
                    child: PageView.builder(
                      controller: _controller,
                      scrollDirection: Axis.vertical,
                      itemCount: subBloc.substitutions!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (newIndex) =>
                          setState(() => _currentIndex = newIndex),
                      itemBuilder: (BuildContext context, int index) =>
                          SubstitutionView(
                        index: index,
                        surpriseMe: _surpriseMe,
                        substitution: subBloc.substitutions![index],
                      ),
                    ),
                  ),
                ),
                const Divider(),
                BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                  builder: (context, state) {
                    PitchScale? blocScale =
                        BlocProvider.of<ProgressionHandlerBloc>(context)
                            .currentScale;
                    return SubstitutionBottomButtonBar(
                      currentPage: _currentIndex + 1,
                      pages: subBloc.substitutions!.length,
                      previous: _currentIndex == 0
                          ? null
                          : () => _previousPage(context),
                      next: _currentIndex == subBloc.substitutions!.length - 1
                          ? null
                          : () => _nextPage(context),
                      playing: state is Playing && !state.baseControl,
                      play: ((state is Playing && state.baseControl) ||
                              blocScale == null)
                          ? null
                          : () => BlocProvider.of<AudioPlayerBloc>(context).add(
                                state is Playing
                                    ? const Pause()
                                    : Play(
                                        basePlaying: false,
                                        measures: subBloc
                                            .getChordProgression(
                                                blocScale, _currentIndex)
                                            .splitToMeasures(),
                                      ),
                              ),
                      apply: () => progressionBloc.add(ApplySubstitution(
                          subBloc.substitutions![_currentIndex])),
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  _resetAudio(BuildContext context) {
    AudioPlayerBloc bloc = BlocProvider.of<AudioPlayerBloc>(context);
    if (!bloc.baseControl) bloc.add(const Reset());
  }

  Future<void> _previousPage(BuildContext context) {
    _resetAudio(context);
    return _controller.previousPage(
        duration: widget.pageSwitchDuration, curve: _scrollCurve);
  }

  Future<void> _nextPage(BuildContext context) {
    _resetAudio(context);
    return _controller.nextPage(
        duration: widget.pageSwitchDuration, curve: _scrollCurve);
  }
}

class SubstitutionButtonBar extends StatefulWidget {
  const SubstitutionButtonBar({
    Key? key,
    required this.inSetup,
  }) : super(key: key);

  final bool inSetup;

  @override
  State<SubstitutionButtonBar> createState() => _SubstitutionButtonBarState();
}

class _SubstitutionButtonBarState extends State<SubstitutionButtonBar> {
  late KeepHarmonicFunctionAmount _keepHarmonicFunction;
  late Sound _sound;

  static final amountNames = [
    for (KeepHarmonicFunctionAmount amount in KeepHarmonicFunctionAmount.values)
      amount.name
  ];

  static final soundNames = [for (Sound sound in Sound.values) sound.name];

  @override
  void initState() {
    _keepHarmonicFunction =
        BlocProvider.of<SubstitutionHandlerBloc>(context).keepHarmonicFunction;
    _sound = BlocProvider.of<SubstitutionHandlerBloc>(context).sound;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SubstitutionHandlerBloc bloc =
        BlocProvider.of<SubstitutionHandlerBloc>(context);
    bool _goDisabled = bloc.substitutions != null;
    bool _showGo = widget.inSetup ||
        (_keepHarmonicFunction == bloc.keepHarmonicFunction &&
            _sound == bloc.sound);
    return SizedBox(
      height: 25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 725,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ViewTypeSelector(
                  tight: true,
                  startOnChords:
                      BlocProvider.of<SubstitutionHandlerBloc>(context).type ==
                          ProgressionType.chords,
                  enabled: !widget.inSetup,
                  onPressed: (newType) {
                    if (newType == ProgressionType.romanNumerals ||
                        BlocProvider.of<ProgressionHandlerBloc>(context)
                                .currentScale !=
                            null) {
                      BlocProvider.of<SubstitutionHandlerBloc>(context)
                          .add(SwitchSubType(newType));
                      return true;
                    }
                    return false;
                  },
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text('Sound:'),
                    ),
                    CustomSelector(
                      tight: true,
                      values: soundNames,
                      value: _sound.name,
                      onPressed: (index) {
                        Sound newSound = Sound.values[index];
                        if (_sound != newSound) {
                          setState(() {
                            _sound = newSound;
                          });
                        }
                        return true;
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text('Keep Harmonic Function:'),
                    ),
                    CustomSelector(
                      tight: true,
                      values: amountNames,
                      value: _keepHarmonicFunction.name,
                      onPressed: (index) {
                        KeepHarmonicFunctionAmount amount =
                            KeepHarmonicFunctionAmount.values[index];
                        if (_keepHarmonicFunction != amount) {
                          setState(() {
                            _keepHarmonicFunction = amount;
                          });
                        }
                        return true;
                      },
                    ),
                  ],
                ),
                CustomButton(
                  label: _showGo ? 'Go!' : 'Refresh',
                  tight: true,
                  iconData: _showGo
                      ? Icons.arrow_right_alt_rounded
                      : Icons.refresh_rounded,
                  onPressed: _showGo && _goDisabled
                      ? null
                      : () => setState(() {
                            bloc.add(CalculateSubstitutions(
                              sound: _sound,
                              keepHarmonicFunction: _keepHarmonicFunction,
                            ));
                          }),
                ),
              ],
            ),
          ),
          const _CancelButton(),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: 'Cancel',
      tight: true,
      iconData: Icons.cancel_rounded,
      onPressed: () {
        BlocProvider.of<SubstitutionHandlerBloc>(context)
            .add(ClearSubstitutions());
      },
    );
  }
}

class SubstitutionBottomButtonBar extends StatelessWidget {
  const SubstitutionBottomButtonBar({
    Key? key,
    required this.previous,
    required this.play,
    required this.next,
    required this.apply,
    required this.currentPage,
    required this.pages,
    this.playing = false,
  }) : super(key: key);

  final void Function()? previous;
  final void Function()? next;
  final void Function()? play;
  final void Function() apply;
  final int currentPage;
  final int pages;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 400,
        height: 50,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  label: 'Previous',
                  iconData: Icons.arrow_upward_rounded,
                  onPressed: previous,
                ),
                CustomButton(
                  label: 'Next',
                  iconData: Icons.arrow_downward_rounded,
                  onPressed: next,
                ),
                CustomButton(
                  label: playing ? 'Pause' : 'Play',
                  iconData:
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  onPressed: play,
                ),
                CustomButton(
                  label: 'Apply',
                  iconData: Icons.check_rounded,
                  onPressed: apply,
                ),
              ],
            ),
            Text('$currentPage/$pages'),
          ],
        ),
      ),
    );
  }
}

class SubstitutionView extends StatelessWidget {
  const SubstitutionView({
    Key? key,
    required this.index,
    required this.substitution,
    required this.surpriseMe,
  }) : super(key: key);

  final int index;
  final Substitution substitution;
  final bool surpriseMe;

  @override
  Widget build(BuildContext context) {
    final SubstitutionHandlerBloc bloc =
        BlocProvider.of<SubstitutionHandlerBloc>(context);
    final PitchScale? scale =
        BlocProvider.of<ProgressionHandlerBloc>(context).currentScale;
    final SubstitutionMatch match = substitution.match;
    /* TODO: This could probably be optimized, since we kinda calculate the
             duration again in horizontal progression view to show the
             selector...
     */
    List<double> results = Utilities.calculateDurationPositions(
        substitution.substitutedBase,
        substitution.changedStart,
        substitution.changedEnd)!;
    int fromChord = results[0].toInt();
    double startDur = results[1];
    int toChord = results[2].toInt();
    double endDur = results[3];
    return Column(
      mainAxisAlignment:
          surpriseMe ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text.rich(
          TextSpan(
            text: surpriseMe ? '' : 'From ',
            children: [
              TextSpan(
                  text: surpriseMe
                      ? 'Final Substitution'
                      : '"${substitution.location}" ',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text: surpriseMe ? '' : match.type.name,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: Constants.measurePatternFontSize * 0.75)),
              WidgetSpan(
                baseline: TextBaseline.ideographic,
                alignment: PlaceholderAlignment.aboveBaseline,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: WeightPreviewButton(substitution: substitution),
                ),
              ),
            ],
          ),
          style: const TextStyle(fontSize: Constants.measurePatternFontSize),
        ),
        (surpriseMe
            ? const SizedBox()
            : HorizontalProgressionView(
                progression: bloc.getOriginalSubstitution(scale, index))),
        HorizontalProgressionView(
          fromChord: surpriseMe ? null : fromChord,
          startAt: surpriseMe ? null : fromChord,
          startDur: surpriseMe ? 0.0 : startDur,
          toChord: surpriseMe ? null : toChord,
          endDur: endDur,
          progression: bloc.getSubstitutedBase(scale, index),
        ),
      ],
    );
  }
}

class WeightPreviewButton extends StatelessWidget {
  const WeightPreviewButton({
    Key? key,
    required this.substitution,
  }) : super(key: key);

  final Substitution substitution;

  @override
  Widget build(BuildContext context) {
    return TIconButton(
      iconData: Icons.notes_rounded,
      size: Constants.measurePatternFontSize * 0.8,
      onPressed: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Details',
          pageBuilder: (context, _, __) => GeneralDialogPage(
            title: 'Details',
            child: Expanded(child: WeightsPreview(score: substitution.score)),
          ),
        );
      },
    );
  }
}
