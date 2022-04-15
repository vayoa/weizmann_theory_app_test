import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/progression/measure_view.dart';

import '../../../../blocs/progression_handler_bloc.dart';
import '../../../../constants.dart';
import '../../../../utilities.dart';

class ProgressionView<T> extends StatefulWidget {
  const ProgressionView({
    Key? key,
    required this.measures,
    this.rangeSelectPadding = 8.0,
    this.measuresInLine = 4,
    this.fromChord,
    this.toChord,
  }) : super(key: key);

  final List<Progression> measures;
  final double rangeSelectPadding;
  final int measuresInLine;
  final int? fromChord;
  final int? toChord;

  @override
  State<ProgressionView<T>> createState() => _ProgressionViewState<T>();
}

class _ProgressionViewState<T> extends State<ProgressionView<T>> {
  int editedMeasure = -1;
  int hoveredMeasure = -1;
  int hoveredPos = -1;

  int _getIndexFromPosition(Offset localPosition) =>
      (localPosition.dx ~/ Constants.measureWidth) +
      (widget.measuresInLine *
          (localPosition.dy ~/
              (Constants.measureHeight + Constants.measureSpacing)));

  @override
  Widget build(BuildContext context) {
    ProgressionHandlerBloc bloc =
        BlocProvider.of<ProgressionHandlerBloc>(context);
    int startMeasure = bloc.startMeasure;
    int startIndex = bloc.startIndex;
    int endMeasure = bloc.endMeasure;
    int endIndex = bloc.endIndex;
    double startDur = bloc.fromDur;
    double endDur = 0.0;
    if (startMeasure != -1 && endMeasure != -1) {
      if (startDur != 0) {
        double durBefore =
            widget.measures[0].timeSignature.decimal * startMeasure;
        durBefore += widget.measures[startMeasure].durations.real(startIndex) -
            widget.measures[startMeasure].durations[startIndex];
        startDur -= durBefore;
      }
      endDur = bloc.toDur;
      double durBefore = widget.measures[0].timeSignature.decimal * endMeasure;
      durBefore += widget.measures[endMeasure].durations.real(endIndex) -
          widget.measures[endMeasure].durations[endIndex];
      endDur -= durBefore;
    }
    const double max = Constants.measureWidth - 2 * Constants.measurePadding;
    final double stepW = max / widget.measures[0].timeSignature.denominator;
    return SizedBox(
      width: widget.measuresInLine * Constants.measureWidth,
      child: Listener(
        onPointerHover: (event) {
          int index = _getIndexFromPosition(event.localPosition);
          double x = (event.localPosition.dx % Constants.measureWidth) -
              Constants.measurePadding;
          if (x >= 0 && x <= max) {
            setState(() {
              hoveredPos = x ~/ stepW;
            });
          } else if (hoveredPos != -1) {
            setState(() {
              hoveredPos = -1;
            });
          }
          if (index != hoveredMeasure) {
            setState(() {
              hoveredMeasure = index;
            });
          }
        },
        onPointerDown: (event) {
          if (event.buttons == kSecondaryButton) {
            int index = _getIndexFromPosition(event.localPosition);
            setState(() {
              editedMeasure = index;
            });
          }
        },
        child: GridView.builder(
            itemCount: widget.measures.length,
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: Constants.measureWidth,
              mainAxisSpacing: Constants.measureSpacing,
              childAspectRatio:
                  Constants.measureWidth / Constants.measureHeight,
            ),
            itemBuilder: (context, index) {
              bool shouldPaint = index >= startMeasure && index <= endMeasure;
              // TODO: Fix this weird case...
              bool last = (index == widget.measures.length - 1) ||
                  (index + 1) % widget.measuresInLine == 0;
              int? fromChord =
                  shouldPaint ? (index == startMeasure ? startIndex : 0) : null;
              int? toChord = shouldPaint
                  ? (index == endMeasure
                      ? endIndex
                      : widget.measures[index].length - 1)
                  : null;
              double paintStartDur = index == startMeasure ? startDur : 0.0;
              double? paintEndDur = index == endMeasure ? endDur : null;
              if (index == editedMeasure) {
                return EditedMeasure(
                  measure: widget.measures[index],
                  last: last,
                  onDone: (bool rebuild, List<String> values) {
                    setState(() {
                      if (rebuild) {
                        BlocProvider.of<ProgressionHandlerBloc>(context).add(
                            MeasureEdited(inputs: values, measureIndex: index));
                      }
                      editedMeasure = -1;
                    });
                  },
                );
              }
              final bool editable = index == hoveredMeasure;
              return MeasureView(
                measure: widget.measures[index],
                last: last,
                fromChord: fromChord,
                startDur: paintStartDur,
                toChord: toChord,
                endDur: paintEndDur,
                editable: editable,
                cursorPos: editable && hoveredPos != -1 ? hoveredPos : null,
                selectorStart: index == startMeasure,
                selectorEnd: index == endMeasure,
                onEdit: () {
                  setState(() {
                    editedMeasure = index;
                  });
                },
              );
            }),
      ),
    );
  }
}

class HorizontalProgressionView extends StatefulWidget {
  const HorizontalProgressionView({
    Key? key,
    required this.progression,
    this.measures,
    this.fromChord,
    this.startDur = 0.0,
    this.toChord,
    this.endDur,
    this.startAt,
    this.editable = false,
  }) : super(key: key);

  final Progression progression;
  final List<Progression>? measures;
  final int? fromChord;
  final double startDur;
  final int? toChord;
  final double? endDur;
  final int? startAt;
  final bool editable;

  @override
  State<HorizontalProgressionView> createState() =>
      _HorizontalProgressionViewState();
}

class _HorizontalProgressionViewState extends State<HorizontalProgressionView> {
  late final ScrollController _controller;
  late List<Progression> _measures;
  int startMeasure = -1, startIndex = -1;
  int endMeasure = -1, endIndex = -1;

  @override
  void initState() {
    _updateMeasures();
    _controller = ScrollController();
    _updateController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant HorizontalProgressionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMeasures();
    _updateController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateMeasures() {
    _measures = widget.measures ?? widget.progression.splitToMeasures();
    if (widget.fromChord != null && widget.toChord != null) {
      List<int> results = Utilities.calculateRangePositions(
        progression: widget.progression,
        measures: _measures,
        fromChord: widget.fromChord!,
        startDur: widget.startDur,
        toChord: widget.toChord!,
        endDur: widget.endDur,
      );
      startMeasure = results[0];
      startIndex = results[1];
      endMeasure = results[2];
      endIndex = results[3];
    }
  }

  void _updateController() =>
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        if (widget.startAt != null) {
          _controller.animateTo(widget.startAt! * Constants.measureWidth,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut);
          // TODO: Give the widget a measure to scroll to...
        }
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.measureHeight,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.mouse},
          platform: TargetPlatform.windows,
        ),
        child: Scrollbar(
          scrollbarOrientation: ScrollbarOrientation.bottom,
          controller: _controller,
          interactive: true,
          child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              itemCount: _measures.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                bool shouldPaint = widget.fromChord != null &&
                    widget.toChord != null &&
                    index >= startMeasure &&
                    index <= endMeasure;
                return MeasureView(
                  measure: _measures[index],
                  last: index == _measures.length - 1,
                  fromChord: shouldPaint
                      ? (index == startMeasure ? startIndex : 0)
                      : null,
                  toChord: shouldPaint
                      ? (index == endMeasure
                          ? endIndex
                          : _measures[index].length)
                      : null,
                  editable: widget.editable,
                  onEdit: () {},
                );
              }),
        ),
      ),
    );
  }
}
