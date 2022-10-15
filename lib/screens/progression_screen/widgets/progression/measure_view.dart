import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmony_theory/modals/progression/progression.dart';

import '../../../../constants.dart';
import '../../../../utilities.dart';
import '../../../../widgets/custom_button.dart';
import 'progression_value_view.dart';

class Measure extends StatelessWidget {
  const Measure({
    Key? key,
    required this.child,
    this.last = false,
  }) : super(key: key);

  final Widget child;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Constants.measureWidth,
      height: Constants.measureHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: last
              ? const [
                  Colors.black,
                  Constants.measureColor,
                  Constants.measureColor,
                  Colors.black,
                ]
              : const [Colors.black, Constants.measureColor],
          stops: last ? const [0.01, 0.01, 0.99, 0.99] : const [0.01, 0.01],
        ),
      ),
      child: FittedBox(
        child: Container(
          width: Constants.measureWidth,
          padding:
              const EdgeInsets.symmetric(horizontal: Constants.measurePadding),
          child: child,
        ),
      ),
    );
  }
}

class SelectorBloc extends StatelessWidget {
  const SelectorBloc({
    Key? key,
    required this.flex,
    this.weak = false,
    this.roundLeft = false,
    this.roundRight = false,
  }) : super(key: key);

  final int flex;
  final bool weak;
  final bool roundLeft;
  final bool roundRight;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Material(
        color: weak
            ? Constants.rangeSelectTransparentColor
            : Constants.rangeSelectColor,
        borderRadius: BorderRadius.horizontal(
          left: roundLeft
              ? const Radius.circular(Constants.borderRadius)
              : Radius.zero,
          right: roundRight
              ? const Radius.circular(Constants.borderRadius)
              : Radius.zero,
        ),
        child: const SizedBox(
          height: Constants.measureFontSize + 10.0,
          width: double.infinity,
        ),
      ),
    );
  }
}

class Selector extends StatelessWidget {
  const Selector({
    Key? key,
    required this.measure,
    this.fromChord,
    this.startDur,
    this.toChord,
    this.endDur,
    this.selectorStart = false,
    this.selectorEnd = false,
    this.startSelect = 0,
    this.endSelect = 1.0,
  }) : super(key: key);

  final Progression measure;
  final int? fromChord;
  final double? startDur;
  final int? toChord;
  final double? endDur;
  final bool selectorStart;
  final bool selectorEnd;
  final double startSelect;
  final double endSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          fromChord == null && toChord == null ? const [] : buildSelector(),
    );
  }

  List<Widget> buildSelector() {
    final double step = measure.timeSignature.step;
    final double startVal =
        measure.durations.real(fromChord!) - measure.durations[fromChord!];
    final double start = startVal + startDur!;
    double end = measure.durations.real(toChord!);
    if (endDur != null) end += endDur! - measure.durations[toChord!];
    final double endOffset = measure.durations.real(toChord!) - end;
    final double dur = end - start;
    final double endSpace =
        measure.timeSignature.decimal - measure.durations.real(toChord!);
    final bool weakLeft = startDur != 0, weakRight = endOffset > 0;
    return [
      if (startVal != 0.0) Spacer(flex: startVal ~/ step),
      if (weakLeft)
        SelectorBloc(
          flex: startDur! ~/ step,
          weak: true,
          roundLeft: selectorStart,
        ),
      SelectorBloc(
        flex: dur ~/ step,
        roundLeft: !weakLeft && selectorStart,
        roundRight: !weakRight && selectorEnd,
      ),
      if (weakRight)
        SelectorBloc(
          flex: endOffset ~/ step,
          weak: true,
          roundRight: selectorEnd,
        ),
      if (endSpace != 0) Spacer(flex: endSpace ~/ step),
    ];
  }
}

class MeasureView<T> extends StatelessWidget {
  const MeasureView({
    Key? key,
    required this.measure,
    this.last = false,
    this.editable = true,
    this.cursorPos,
    this.fromChord,
    this.startDur,
    this.toChord,
    this.endDur,
    this.selectorStart = false,
    this.selectorEnd = false,
    this.disabled = false,
    this.paintFrom,
    this.paintTo,
    this.editedPos,
    this.onSubmitChange,
  })  : assert((paintFrom == null) == (paintTo == null)),
        super(key: key);

  final Progression<T> measure;
  final bool last;
  final bool editable;
  final int? fromChord;
  final double? startDur;
  final int? toChord;
  final double? endDur;
  final int? cursorPos;
  final bool selectorStart;
  final bool selectorEnd;
  final bool disabled;
  final int? paintFrom;
  final int? paintTo;
  final int? editedPos;
  final void Function(List<String>? input, bool? next)? onSubmitChange;

  @override
  Widget build(BuildContext context) {
    return Measure(
      last: last,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (!disabled)
            Selector(
              measure: measure,
              fromChord: fromChord,
              startDur: startDur,
              toChord: toChord,
              endDur: endDur,
              selectorStart: selectorStart,
              selectorEnd: selectorEnd,
            ),
          Row(
            children: buildList(),
          ),
          cursorPos == null
              ? const SizedBox()
              : Row(
                  children: buildCursor(),
                )
        ],
      ),
    );
  }

  List<Widget> buildList() {
    List<Widget> widgets = [];
    final double step = measure.timeSignature.step;
    final bool shouldPaint = paintFrom != null && paintTo != null;
    final editedPos = this.editedPos ?? -1;

    for (int i = 0; i < measure.length; i++) {
      final bool highlight = shouldPaint && i >= paintFrom! && i <= paintTo!;
      final pos = measure.durations.position(i) ~/ step;
      final absolute = (measure.durations.real(i) ~/ step) - 1;
      final edited = pos == editedPos;
      final stepDuration = measure.duration ~/ step;
      int flex = measure.durations[i] ~/ step;

      bool addTextBetween = false;
      bool addSpacer = false;

      if (!edited && pos < editedPos && absolute >= editedPos) {
        flex -= 1;
        addTextBetween = true;
        // If the measure has a duration of more than 1 we need to space it...
        if (editedPos != stepDuration - 1 && absolute >= 2) {
          flex = editedPos - pos;
          addSpacer = true;
        }
      }
      widgets.add(
        Flexible(
          flex: flex,
          child: SizedBox(
            width: double.infinity,
            child: edited
                ? EditedValueView(
              value: measure[i],
                    onSubmitChange: _submittedChange,
                    position: editedPos,
                  )
                : ProgressionValueView(
                    value: measure[i],
                    highlight: highlight,
                  ),
          ),
        ),
      );
      if (addTextBetween) {
        widgets.add(
          Flexible(
            flex: addSpacer ? stepDuration - editedPos : 1,
            child: SizedBox(
              width: double.infinity,
              child: EditedValueView(
                value: 1,
                position: editedPos,
                onSubmitChange: _submittedChange,
              ),
            ),
          ),
        );
      }
    }
    if (!measure.full && last) {
      widgets.add(Flexible(
        flex: (measure.timeSignature.decimal - measure.duration) ~/ step,
        child: const SizedBox(
          height: Constants.measureFontSize * 1.6,
          child: VerticalDivider(thickness: 4, width: 4),
        ),
      ));
    }
    return widgets;
  }

  List<Widget> buildCursor() {
    List<Widget> widgets = [];
    final int max = measure.timeSignature.numerator;
    if (cursorPos != 0) {
      widgets.add(Spacer(flex: cursorPos!));
    }
    widgets.add(
      const SelectorBloc(
        flex: 1,
        weak: true,
        roundLeft: true,
        roundRight: true,
      ),
    );
    if (cursorPos != max - 1) {
      widgets.add(Spacer(flex: max - 1 - cursorPos!));
    }
    return widgets;
  }

  // TODO: Optimize...
  void _submittedChange(String? input, bool? next) {
    if (input == null) return onSubmitChange?.call(null, next);

    List<String> values = [];
    final double step = measure.timeSignature.step;
    final editedPos = this.editedPos ?? -1;
    input = input.trim();
    int? num = int.tryParse(input);
    var last = '';
    int index = 0;
    for (int p = 0; p < measure.timeSignature.numerator; p++) {
      bool useIndex = index < measure.length &&
          p == measure.durations.position(index) ~/ step;
      if (p == editedPos) {
        if (num == null) {
          values.add(input);
          last = input;
        } else {
          values.add('$last $input');
        }
      } else {
        last = useIndex ? measure[index].toString() : last;
        values.add(last);
      }
      if (useIndex) {
        index++;
      }
    }
    print(values);
    onSubmitChange?.call(values, next);
  }
}

class EmptyMeasure extends StatelessWidget {
  const EmptyMeasure({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Measure(
      last: true,
      child: Center(
        child: Text('...'),
      ),
    );
  }
}

class EditedMeasure<T> extends StatefulWidget {
  const EditedMeasure({
    Key? key,
    required this.measure,
    required this.onDone,
    this.last = false,
  }) : super(key: key);

  final Progression<T> measure;
  final void Function(bool rebuild, List<String> inputs) onDone;
  final bool last;

  @override
  State<EditedMeasure<T>> createState() => _EditedMeasureState<T>();
}

class _EditedMeasureState<T> extends State<EditedMeasure<T>> {
  late final TextEditingController controller;
  String initial = '';

  @override
  void initState() {
    controller = TextEditingController();
    controller.text = text();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Measure(
          last: widget.last,
          child: TextField(
            controller: controller,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r"[\w\d, /^/+°øØ#b♯♭𝄪𝄫]"))
            ],
            decoration: InputDecoration(
              hintText: initial,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: 1,
            style: Constants.valueTextStyle,
            onSubmitted: (input) => _submit(),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 3, bottom: 3),
            child: CustomButton(
              label: 'Done',
              iconData: Icons.check_rounded,
              onPressed: _submit,
              tight: true,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }

  String text() {
    const String sep = ',    ';
    initial = '';
    final double step = widget.measure.timeSignature.step;
    for (int i = 0; i < widget.measure.length; i++) {
      initial += Utilities.progressionValueToEditString(widget.measure[i]);
      int times = widget.measure.durations[i] ~/ step;
      if (times > 1) initial += ' $times';
      initial += sep;
    }
    return initial.isEmpty
        ? ''
        : initial.substring(0, initial.length - sep.length);
  }

  void _submit() {
    if (controller.text != initial) {
      List<String> values = [
        for (String value in controller.text.split(',')) value.trim()
      ];
      widget.onDone.call(true, values);
    } else {
      widget.onDone.call(false, const []);
    }
  }
}

class InputPart {
  String val;
  int dur;

  InputPart(this.val, this.dur);

  addTo(List<InputPart> parts) {
    int? p = int.tryParse(val);
    if (p != null) {
      // TDC: If parts is empty and we typed a number (dur) this will crash...
      parts.last.dur += p;
    } else {
      parts.add(this);
    }
  }

  @override
  String toString() => '$val $dur';
}
