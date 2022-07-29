import 'package:flutter/material.dart';
import 'package:harmony_theory/modals/progression/progression.dart';

import '../../../../constants.dart';
import '../../../../utilities.dart';
import 'measure_view.dart';

// TODO: Combine this widget with ProgressionView.
class ProgressionGrid extends StatefulWidget {
  const ProgressionGrid({
    Key? key,
    required this.progression,
    this.measures,
    this.rangeSelectPadding = 8.0,
    this.measuresInLine = 4,
    this.fromChord,
    this.startDur = 0.0,
    this.toChord,
    this.endDur,
    this.startAt,
    this.padding,
    this.mainAxisSpacing = Constants.measureSpacing,
    this.maxCrossAxisExtent,
    this.mainAxisExtent,
    this.physics,
    this.rangeDisabled = false,
    this.hoveredMeasure,
    this.hoveredPos,
    this.editedMeasure,
    this.onDoneEdit,
    this.onEdit,
  })  : assert((editedMeasure == null) == (onDoneEdit == null) &&
            (editedMeasure == null) == (onEdit == null)),
        super(key: key);

  final Progression progression;
  final List<Progression>? measures;
  final double rangeSelectPadding;
  final int measuresInLine;
  final int? fromChord;
  final double startDur;
  final int? toChord;
  final double? endDur;
  final int? startAt;
  final bool rangeDisabled;
  final EdgeInsets? padding;
  final double mainAxisSpacing;
  final double? maxCrossAxisExtent;
  final double? mainAxisExtent;
  final ScrollPhysics? physics;
  final int? hoveredMeasure;
  final int? hoveredPos;
  final int? editedMeasure;
  final void Function(bool rebuild, List<String> values, int index)? onDoneEdit;
  final void Function(int measure)? onEdit;

  @override
  State<ProgressionGrid> createState() => _ProgressionGridState();
}

class _ProgressionGridState extends State<ProgressionGrid> {
  late List<Progression> _measures;
  int startMeasure = -1, startIndex = -1;
  int endMeasure = -1, endIndex = -1;
  double startDur = 0.0;
  double endDur = 0.0;
  bool _canPaint = false;

  @override
  void initState() {
    _updateMeasures();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProgressionGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMeasures();
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

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: _measures.length,
      shrinkWrap: true,
      padding: widget.padding,
      physics: widget.physics,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisExtent: widget.mainAxisExtent,
        maxCrossAxisExtent: widget.maxCrossAxisExtent ?? Constants.measureWidth,
        mainAxisSpacing: widget.mainAxisSpacing,
        childAspectRatio: Constants.measureWidth / Constants.measureHeight,
      ),
      itemBuilder: (context, index) {
        final bool last = (index == _measures.length - 1) ||
            (index + 1) % widget.measuresInLine == 0;
        if (index == widget.editedMeasure) {
          return EditedMeasure(
            measure: _measures[index],
            last: last,
            onDone: (rebuild, values) =>
                widget.onDoneEdit?.call(rebuild, values, index),
          );
        }
        bool shouldPaint = !widget.rangeDisabled &&
            _canPaint &&
            index >= startMeasure &&
            index <= endMeasure;
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
        final bool editable = index == widget.hoveredMeasure;
        return MeasureView(
          measure: _measures[index],
          last: last,
          fromChord: fromChord,
          startDur: buildStartDur,
          toChord: toChord,
          endDur: buildEndDur,
          selectorStart: start,
          selectorEnd: end,
          disabled: widget.rangeDisabled,
          editable: editable,
          cursorPos:
              editable && widget.hoveredPos != -1 ? widget.hoveredPos : null,
          onEdit: () => widget.onEdit?.call(index),
        );
      },
    );
  }
}
