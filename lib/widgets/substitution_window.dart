import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:weizmann_theory_app_test/blocs/substitution_handler/substitution_handler_bloc.dart';
import 'package:weizmann_theory_app_test/widgets/TButton.dart';
import 'package:weizmann_theory_app_test/widgets/TSelector.dart';
import 'package:weizmann_theory_app_test/widgets/progression_view.dart';
import 'package:weizmann_theory_app_test/widgets/view_type_selector.dart';
import '../Constants.dart';
import '../blocs/progression_handler_bloc.dart';
import 'package:tonic/tonic.dart';

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
          setState(() => _currentIndex = 0);
        }
      },
      builder: (context, state) {
        SubstitutionHandlerBloc subBloc =
            BlocProvider.of<SubstitutionHandlerBloc>(context);
        ProgressionHandlerBloc progressionBloc =
            BlocProvider.of<ProgressionHandlerBloc>(context);
        if (state is CalculatingSubstitutions) {
          return Container(
            height: 350,
            padding: const EdgeInsets.only(
                top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
            decoration: const BoxDecoration(
              color: Constants.rangeSelectColor,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Constants.borderRadius * 3)),
            ),
            child: const CircularProgressIndicator(),
          );
        }
        if (subBloc.substitutions == null || subBloc.substitutions!.isEmpty) {
          return const SizedBox();
        } else {
          return Container(
            height: 350,
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Constants.rangeSelectColor,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Constants.borderRadius * 3)),
            ),
            child: Column(
              children: [
                const SubstitutionButtonBar(),
                const Divider(),
                SizedBox(
                  height: 200,
                  child: Listener(
                    onPointerSignal: (signal) {
                      if (_controller.page != null &&
                          _controller.page! % 1 == 0 &&
                          signal is PointerScrollEvent) {
                        if (signal.scrollDelta.dy > 0) {
                          _controller.nextPage(
                              duration: widget.pageSwitchDuration,
                              curve: _scrollCurve);
                        } else {
                          _controller.previousPage(
                              duration: widget.pageSwitchDuration,
                              curve: _scrollCurve);
                        }
                      }
                    },
                    child: PageView.builder(
                      controller: _controller,
                      scrollDirection: Axis.vertical,
                      itemCount: subBloc.substitutions!.length,
                      // TODO: Figure out a way to scroll with the mouse wheel
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (newIndex) =>
                          setState(() => _currentIndex = newIndex),
                      itemBuilder: (BuildContext context, int index) =>
                          SubstitutionView(index: index),
                    ),
                  ),
                ),
                const Divider(),
                SubstitutionBottomButtonBar(
                  currentPage: _currentIndex + 1,
                  pages: subBloc.substitutions!.length,
                  previous: _currentIndex == 0
                      ? null
                      : () => _controller.previousPage(
                            duration: widget.pageSwitchDuration,
                            curve: _scrollCurve,
                          ),
                  next: _currentIndex == subBloc.substitutions!.length - 1
                      ? null
                      : () => _controller.nextPage(
                          duration: widget.pageSwitchDuration,
                          curve: _scrollCurve),
                  play: () {},
                  apply: () => progressionBloc.add(
                      ApplySubstitution(subBloc.substitutions![_currentIndex])),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class SubstitutionButtonBar extends StatelessWidget {
  const SubstitutionButtonBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 750,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ViewTypeSelector(
                  tight: true,
                  onPressed: (newType) =>
                      BlocProvider.of<SubstitutionHandlerBloc>(context)
                          .add(SwitchSubType(newType)),
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text('Sound:'),
                    ),
                    TSelector(
                      values: const ['Classical', 'Both', 'Exotic'],
                      value: 'Classical',
                      onPressed: (index) => true,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text('Keep Harmonic Function:'),
                    ),
                    TSelector(
                      values: const ['low', 'med', 'high'],
                      value: 'low',
                      onPressed: (index) => true,
                    ),
                  ],
                ),
                TButton(
                  label: 'Go!',
                  tight: true,
                  iconData: Icons.arrow_right_alt_rounded,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          TButton(
            label: 'Cancel',
            tight: true,
            iconData: Icons.cancel_rounded,
            onPressed: () {},
          ),
        ],
      ),
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
  }) : super(key: key);

  final void Function()? previous;
  final void Function()? next;
  final void Function() play;
  final void Function() apply;
  final int currentPage;
  final int pages;

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
                TButton(
                  label: 'Previous',
                  iconData: Icons.arrow_upward_rounded,
                  onPressed: previous,
                ),
                TButton(
                  label: 'Next',
                  iconData: Icons.arrow_downward_rounded,
                  onPressed: next,
                ),
                TButton(
                  label: 'Play',
                  iconData: Icons.play_arrow_rounded,
                  onPressed: play,
                ),
                TButton(
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
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    SubstitutionHandlerBloc bloc =
        BlocProvider.of<SubstitutionHandlerBloc>(context);
    Substitution substitution = bloc.substitutions![index];
    PitchScale scale =
        BlocProvider.of<ProgressionHandlerBloc>(context).currentlyActiveScale;
    int? from = substitution.match?.baseIndex;
    int? to = from == null ? null : from + 1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'From "My Other Song":',
          style: TextStyle(fontSize: Constants.measurePatternFontSize),
        ),
        Row(
          children: [
            HorizontalProgressionView(
                progression: bloc.getOriginalSubstitution(scale, index)),
          ],
        ),
        HorizontalProgressionView(
          fromChord: from,
          toChord: to,
          startAt: from,
          progression: bloc.getSubstitutedBase(scale, index),
        ),
      ],
    );
  }
}
