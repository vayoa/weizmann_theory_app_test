import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/modals/progression/progression.dart';

import '../../../../blocs/progression_handler_bloc.dart';
import '../../../../constants.dart';
import '../../../../utilities.dart';
import '../progression/measure_view.dart';

class ProgressionView<T> extends StatefulWidget {

  const ProgressionView({
    Key? key,
    required this.measures,
    this.rangeSelectPadding = 8.0,
    this.measuresInLine = 4,
    this.interactable = true,
    this.fromChord,
    this.toChord,
    this.padding,
    this.mainAxisSpacing = Constants.measureSpacing,
    this.maxCrossAxisExtent,
    this.mainAxisExtent,
    this.physics,
  }) : super(key: key);

  final List<Progression> measures;
  final double rangeSelectPadding;
  final int measuresInLine;
  final int? fromChord;
  final int? toChord;
  final bool interactable;
  final EdgeInsets? padding;
  final double mainAxisSpacing;
  final double? maxCrossAxisExtent;
  final double? mainAxisExtent;
  final ScrollPhysics? physics;

  @override
  State<ProgressionView<T>> createState() => _ProgressionViewState<T>();
}

class _ProgressionViewState<T> extends State<ProgressionView<T>> {
  late double stepW;
  late double minSelectDur;
  int editedMeasure = -1;
  int hoveredMeasure = -1;
  int hoveredPos = -1;
  double startHold = -1;
  int holdMeasure = -1;
  int holdPos = -1;
  late double maxDur;

  static const double max =
      Constants.measureWidth - 2 * Constants.measurePadding;

  int _getIndexFromPosition(Offset localPosition) =>
      (localPosition.dx ~/ Constants.measureWidth) +
      (widget.measuresInLine *
          (localPosition.dy ~/
              (Constants.measureHeight + Constants.measureSpacing)));

  int _getMeasureDur(Offset localPosition) {
    double x =
        (localPosition.dx % Constants.measureWidth) - Constants.measurePadding;
    return x >= 0 && x <= max ? x ~/ stepW : -1;
  }

  double _calcPosDur(int measure, int duration) =>
      measure != -1 && widget.measures.length > measure && duration != -1
          ? (measure * widget.measures[0].timeSignature.decimal) +
              (duration * widget.measures[0].timeSignature.step)
          : -1;

  _setup() {
    stepW = max / widget.measures[0].timeSignature.numerator;
    minSelectDur = widget.measures[0].timeSignature.step * 2;
    maxDur = math.max(widget.measures.length - 1, 0) *
            widget.measures[0].timeSignature.decimal +
        (widget.measures.last.duration);
  }

  @override
  void initState() {
    _setup();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProgressionView<T> oldWidget) {
    _setup();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ProgressionHandlerBloc bloc =
        BlocProvider.of<ProgressionHandlerBloc>(context);
    int startMeasure = bloc.startMeasure;
    int startIndex = bloc.startIndex;
    int endMeasure = bloc.endMeasure;
    int endIndex = bloc.endIndex;
    double startDur = 0.0;
    double endDur = 0.0;
    bool disabled = bloc.rangeDisabled;
    if (!disabled && startMeasure != -1 && endMeasure != -1) {
      startDur = bloc.fromDur;
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
    return SizedBox(
      width: widget.measuresInLine * Constants.measureWidth,
      child: Listener(
        onPointerMove: !widget.interactable
            ? (_) {}
            : (event) {
                if (editedMeasure == -1 && event.buttons == kPrimaryButton) {
                  if (holdMeasure != -1 && holdPos != -1) {
                    int measureDur = _getMeasureDur(event.localPosition);
                    int measure = _getIndexFromPosition(event.localPosition);
                    if (measure != -1 && measureDur != -1) {
                      double selectorEndDur, selectorStartDur;
                      if (holdMeasure > measure ||
                          (holdMeasure == measure && holdPos > measureDur)) {
                        selectorEndDur = _calcPosDur(holdMeasure, holdPos + 1);
                        selectorStartDur = _calcPosDur(measure, measureDur);
                      } else {
                        selectorEndDur = _calcPosDur(measure, measureDur + 1);
                        selectorStartDur = startHold;
                      }
                      if (selectorEndDur > 0 &&
                          selectorEndDur <= maxDur &&
                          selectorStartDur >= 0 &&
                          selectorStartDur < maxDur) {
                        if (selectorEndDur - selectorStartDur >= minSelectDur) {
                          BlocProvider.of<ProgressionHandlerBloc>(context).add(
                              ChangeRangeDuration(
                                  start: selectorStartDur,
                                  end: selectorEndDur));
                        } else {
                          BlocProvider.of<ProgressionHandlerBloc>(context)
                              .add(const DisableRange(disable: true));
                        }
                      }
                    }
                  }
                }
              },
        onPointerHover: !widget.interactable
            ? (_) {}
            : (event) {
                int index = _getIndexFromPosition(event.localPosition);
                setState(() {
                  hoveredPos = _getMeasureDur(event.localPosition);
                });
                if (index != hoveredMeasure) {
                  setState(() {
                    hoveredMeasure = index;
                  });
                }
              },
        onPointerDown: !widget.interactable
            ? (_) {}
            : (event) {
                if (event.buttons == kPrimaryButton) {
                  double hold = _calcPosDur(hoveredMeasure, hoveredPos);
                  if (hold >= 0 && hold <= maxDur) {
                    setState(() {
                      holdMeasure = hoveredMeasure;
                      holdPos = hoveredPos;
                      startHold = hold;
                    });
                  }
                } else if (event.buttons == kSecondaryButton) {
                  int index = _getIndexFromPosition(event.localPosition);
                  setState(() {
                    editedMeasure = index;
                  });
                }
              },
        child: GridView.builder(
            itemCount: widget.measures.length,
            shrinkWrap: true,
            padding: widget.padding,
            physics: widget.physics,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: widget.mainAxisExtent,
              maxCrossAxisExtent:
                  widget.maxCrossAxisExtent ?? Constants.measureWidth,
              mainAxisSpacing: widget.mainAxisSpacing,
              childAspectRatio:
                  Constants.measureWidth / Constants.measureHeight,
            ),
            itemBuilder: (context, index) {
              bool shouldPaint = index >= startMeasure && index <= endMeasure;
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
              if (widget.interactable && index == editedMeasure) {
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
                disabled: disabled,
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
    this.padding,
    this.extent,
    this.physics,
  }) : super(key: key);

  final Progression progression;
  final List<Progression>? measures;
  final int? fromChord;
  final double startDur;
  final int? toChord;
  final double? endDur;
  final int? startAt;
  final bool editable;
  final EdgeInsets? padding;
  final double? extent;
  final ScrollPhysics? physics;

  @override
  State<HorizontalProgressionView> createState() =>
      _HorizontalProgressionViewState();
}

class _HorizontalProgressionViewState extends State<HorizontalProgressionView> {
  late final ScrollController _controller;
  late List<Progression> _measures;
  int startMeasure = -1, startIndex = -1;
  int endMeasure = -1, endIndex = -1;
  double startDur = 0.0;
  double endDur = 0.0;
  bool _canPaint = false;

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
    final Progression prog = widget.progression;
    if (widget.fromChord != null && widget.toChord != null) {
      int toChord = widget.toChord!;
      List<int> results = Utilities.calculateRangePositions(
        progression: widget.progression,
        measures: _measures,
        fromChord: widget.fromChord!,
        startDur: widget.startDur,
        toChord: toChord,
        endDur: widget.endDur,
      );
      startMeasure = results[0];
      startIndex = results[1];
      endMeasure = results[2];
      endIndex = results[3];
      startDur = 0.0;
      endDur = 0.0;
      if (startMeasure != -1 && endMeasure != -1) {
        startDur = prog.isEmpty
            ? 0.0
            : prog.durations.real(widget.fromChord!) -
                prog.durations[widget.fromChord!] +
                widget.startDur;
        if (startDur != 0) {
          double durBefore = _measures[0].timeSignature.decimal * startMeasure;
          durBefore += _measures[startMeasure].durations.real(startIndex) -
              _measures[startMeasure].durations[startIndex];
          startDur -= durBefore;
        }
        endDur = prog.isEmpty ? 0.0 : prog.durations.real(toChord);
        if (widget.endDur != null) {
          endDur += widget.endDur! - prog.durations[toChord];
        }
        double durBefore = _measures[0].timeSignature.decimal * endMeasure;
        durBefore += _measures[endMeasure].durations.real(endIndex) -
            _measures[endMeasure].durations[endIndex];
        endDur -= durBefore;
      }
    }
    _canPaint = widget.fromChord != null && widget.toChord != null;
  }

  void _updateController() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.startAt != null) {
          _controller.animateTo(widget.startAt! * Constants.measureWidth,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut);
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
              padding: widget.padding,
              itemExtent: widget.extent,
              physics: widget.physics,
              itemBuilder: (context, index) {
                bool shouldPaint =
                    _canPaint && index >= startMeasure && index <= endMeasure;
                bool start = index == startMeasure;
                bool end = index == endMeasure;
                int? fromChord, toChord;
                double? buildStartDur, buildEndDur;
                if (shouldPaint) {
                  if (start) {
                    fromChord = startIndex;
                    buildStartDur = startDur;
                  } else {
                    fromChord = 0;
                    buildStartDur = 0.0;
                  }
                  if (end) {
                    toChord = endIndex;
                    buildEndDur = endDur;
                  } else {
                    toChord = _measures[index].length - 1;
                    buildEndDur = _measures[index].durations[toChord];
                  }
                }
                return MeasureView(
                  measure: _measures[index],
                  last: index == _measures.length - 1,
                  fromChord: fromChord,
                  startDur: buildStartDur,
                  toChord: toChord,
                  endDur: buildEndDur,
                  selectorStart: start,
                  selectorEnd: end,
                  editable: widget.editable,
                  onEdit: () {},
                );
              }),
        ),
      ),
    );
  }
}
