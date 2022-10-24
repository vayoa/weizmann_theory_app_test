import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Change;
import 'package:harmony_theory/modals/progression/progression.dart';

import '../../../../blocs/input/input_cubit.dart';
import '../../../../constants.dart';
import '../../../../screens/progression_screen/widgets/progression/progression_grid.dart';

class SelectableProgressionView<T> extends StatelessWidget {
  const SelectableProgressionView({
    Key? key,
    required this.progression,
    this.measures,
    this.rangeSelectPadding = 8.0,
    required this.onChangeRange,
    required this.startRange,
    required this.endRange,
    required this.rangeDisabled,
    this.interactable = true,
    this.highlightFrom,
    this.highlightTo,
  }) : super(key: key);

  final Progression progression;
  final List<Progression>? measures;
  final double rangeSelectPadding;
  final double startRange;
  final double endRange;
  final double? highlightFrom;
  final double? highlightTo;
  final void Function(double? start, double? end) onChangeRange;
  final bool rangeDisabled;
  final bool interactable;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxMeasures = constraints.maxWidth / Constants.measureWidth;
          int measuresInLine = 1;
          if (maxMeasures > 8) {
            measuresInLine = 8;
          } else if (maxMeasures > 4) {
            measuresInLine = 4;
          } else if (maxMeasures > 2) {
            measuresInLine = 2;
          }
          double width = Constants.measureWidth * measuresInLine;
          return SizedBox(
            width: width + rangeSelectPadding,
            child: Padding(
              padding: EdgeInsets.all(rangeSelectPadding),
              child: _SelectableProgression(
                measuresInLine: measuresInLine,
                progression: progression,
                measures: measures,
                startRange: startRange,
                endRange: endRange,
                onChangeRange: onChangeRange,
                rangeDisabled: rangeDisabled,
                interactable: interactable,
                highlightFrom: highlightFrom,
                highlightTo: highlightTo,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SelectableProgression extends StatefulWidget {
  const _SelectableProgression({
    Key? key,
    required this.measuresInLine,
    required this.progression,
    required this.measures,
    required this.startRange,
    required this.endRange,
    required this.onChangeRange,
    required this.rangeDisabled,
    this.interactable = true,
    required this.highlightFrom,
    required this.highlightTo,
  }) : super(key: key);

  final Progression progression;
  final List<Progression>? measures;
  final int measuresInLine;
  final double startRange;
  final double endRange;
  final double? highlightFrom;
  final double? highlightTo;
  final bool rangeDisabled;
  final void Function(double? start, double? end) onChangeRange;
  final bool interactable;

  @override
  State<_SelectableProgression> createState() => _SelectableProgressionState();
}

class _SelectableProgressionState extends State<_SelectableProgression> {
  late List<Progression> _measures;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late double stepW;
  late double minSelectDur;
  int hoveredMeasure = -1;
  int hoveredPos = -1;
  double startHold = -1;
  int holdMeasure = -1;
  int holdPos = -1;
  late double maxDur;

  static const double max =
      Constants.measureWidth - 2 * Constants.measurePadding;

  int _getIndexFromPosition(Offset localPosition) {
    const height = Constants.measureHeight + Constants.measureSpacing;
    final dy = localPosition.dy + _scrollController.offset;
    if (dy % height > Constants.measureHeight) {
      return -1;
    }
    return (localPosition.dx ~/ Constants.measureWidth) +
        (widget.measuresInLine * (dy ~/ height));
  }

  int _getMeasureDur(Offset localPosition) {
    double x =
        (localPosition.dx % Constants.measureWidth) - Constants.measurePadding;
    return x >= 0 && x <= max ? x ~/ stepW : -1;
  }

  double _calcPosDur(int measure, int duration) =>
      measure != -1 && _measures.length > measure && duration != -1
          ? (measure * _measures[0].timeSignature.decimal) +
              (duration * _measures[0].timeSignature.step)
          : -1;

  _setup() {
    _measures = widget.measures ?? widget.progression.splitToMeasures();
    stepW = max / _measures[0].timeSignature.numerator;
    minSelectDur = _measures[0].timeSignature.step * 2;
    maxDur =
        math.max(_measures.length - 1, 0) * _measures[0].timeSignature.decimal +
            (_measures.last.duration);
  }

  @override
  void initState() {
    _setup();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _SelectableProgression oldWidget) {
    _setup();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.measuresInLine * Constants.measureWidth,
      child: Listener(
        onPointerMove: (event) {
          if (widget.interactable) _onPointerMove(event, context);
        },
        onPointerHover: (event) {
          if (widget.interactable) _onPointerHover(event, context);
        },
        onPointerDown: (event) {
          if (widget.interactable) _onPointerDown(event, context);
        },
        onPointerUp: (event) {
          /* TODO: We don't really need to recalculate this since it's
                   supposed to be known to us, figure out how to use it.
           */
          final endMeasure = _getIndexFromPosition(event.localPosition);
          final endPos = _getMeasureDur(event.localPosition);
          final bloc = BlocProvider.of<InputCubit>(context);
          if ((bloc.editedMeasure != endMeasure || bloc.editedPos != endPos) &&
              hoveredMeasure == endMeasure &&
              hoveredPos == endPos) {
            bloc.unfocus();
            widget.onChangeRange.call(null, null);
            bloc.changePos(endPos, endMeasure);
          }
        },
        child: KeyboardListener(
          autofocus: true,
          focusNode: _focusNode,
          onKeyEvent: (event) {
            final inputBloc = BlocProvider.of<InputCubit>(context);
            if (event is KeyDownEvent) {
              final key = event.logicalKey;
              bool ctrl = RawKeyboard.instance.keysPressed
                  .contains(LogicalKeyboardKey.controlLeft);
              if (key == LogicalKeyboardKey.backspace) {
                if (!widget.rangeDisabled) {
                  inputBloc.deleteRange();
                }
              } else if (ctrl) {
                if (key == LogicalKeyboardKey.keyZ) {
                  inputBloc.undo();
                } else if (key == LogicalKeyboardKey.keyR) {
                  inputBloc.redo();
                }
              }
            }
          },
          child: BlocConsumer<InputCubit, InputState>(
            listener: (context, state) {
              if (state is FocusedKeys) {
                _focusNode.requestFocus();
              } else if (state is Unfocused) {
                _focusNode.unfocus();
              }
            },
            builder: (context, state) {
              int editedPos = -1, editedMeasure = -1;
              if (state is InputActive) {
                editedPos = state.editedPos;
                editedMeasure = state.editedMeasure;
              }
              return ProgressionGrid(
                scrollController: _scrollController,
                progression: widget.progression,
                measures: widget.measures,
                measuresInLine: widget.measuresInLine,
                startRange: widget.startRange,
                endRange: widget.endRange,
                rangeDisabled: widget.rangeDisabled,
                hoveredMeasure: widget.interactable ? hoveredMeasure : null,
                hoveredPos: widget.interactable ? hoveredPos : null,
                editedMeasure: widget.interactable ? editedMeasure : null,
                editedPos: editedPos,
                highlightFrom: widget.highlightFrom,
                highlightTo: widget.highlightTo,
                onDoneEdit: widget.interactable ? _onDoneEdit : null,
              );
            },
          ),
        ),
      ),
    );
  }

  void _onDoneEdit(EditAction action, int measureIndex) =>
      BlocProvider.of<InputCubit>(context).submitAction(action, measureIndex);

  void _onPointerMove(PointerMoveEvent event, BuildContext context) {
    BlocProvider.of<InputCubit>(context).disable();

    if (event.buttons == kPrimaryButton) {
      if (holdMeasure != -1 && holdPos != -1) {
        _focusNode.requestFocus();
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
              widget.onChangeRange(selectorStartDur, selectorEndDur);
            } else {
              widget.onChangeRange(null, null);
            }
          }
        }
      }
    }
  }

  void _onPointerHover(PointerHoverEvent event, BuildContext context) {
    int index = _getIndexFromPosition(event.localPosition);
    setState(() {
      hoveredPos = _getMeasureDur(event.localPosition);
    });
    if (index != hoveredMeasure) {
      setState(() {
        hoveredMeasure = index;
      });
    }
  }

  void _onPointerDown(PointerDownEvent event, BuildContext context) {
    if (event.buttons == kPrimaryButton) {
      double hold = _calcPosDur(hoveredMeasure, hoveredPos);
      if (hold >= 0 && hold <= maxDur) {
        setState(() {
          holdMeasure = hoveredMeasure;
          holdPos = hoveredPos;
          startHold = hold;
        });
      }
    }
  }
}
