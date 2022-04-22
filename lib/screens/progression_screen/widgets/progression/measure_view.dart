import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:weizmann_theory_app_test/constants.dart';

import '../../../../utilities.dart';
import '../../../../widgets/TButton.dart';
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
          padding: const EdgeInsets.all(Constants.measurePadding),
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
  }) : super(key: key);

  final Progression measure;
  final int? fromChord;
  final double? startDur;
  final int? toChord;
  final double? endDur;
  final bool selectorStart;
  final bool selectorEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          fromChord == null && toChord == null ? const [] : buildSelector(),
    );
  }

  List<Widget> buildSelector() {
    final List<Widget> widgets = [];
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
    if (startVal != 0.0) {
      widgets.add(Spacer(flex: startVal ~/ step));
    }
    if (weakLeft) {
      widgets.add(
        SelectorBloc(
          flex: startDur! ~/ step,
          weak: true,
          roundLeft: selectorStart,
        ),
      );
    }
    widgets.add(SelectorBloc(
      flex: dur ~/ step,
      roundLeft: !weakLeft && selectorStart,
      roundRight: !weakRight && selectorEnd,
    ));
    if (weakRight) {
      widgets.add(SelectorBloc(
        flex: endOffset ~/ step,
        weak: true,
        roundRight: selectorEnd,
      ));
    }
    if (endSpace != 0) {
      widgets.add(Spacer(flex: endSpace ~/ step));
    }
    return widgets;
  }
}

class MeasureView<T> extends StatelessWidget {
  const MeasureView({
    Key? key,
    required this.measure,
    required this.onEdit,
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
  }) : super(key: key);

  final Progression<T> measure;
  final void Function() onEdit;
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Measure(
          last: last,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              (disabled
                  ? const SizedBox()
                  : Selector(
                      measure: measure,
                      fromChord: fromChord,
                      startDur: startDur,
                      toChord: toChord,
                      endDur: endDur,
                      selectorStart: selectorStart,
                      selectorEnd: selectorEnd,
                    )),
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
        ),
        AnimatedOpacity(
          opacity: editable ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 3, bottom: 3),
              child: TButton(
                label: 'Edit',
                iconData: Icons.edit_rounded,
                onPressed: editable ? onEdit : () {},
                tight: true,
                size: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildList() {
    List<Widget> widgets = [];
    final double step = measure.timeSignature.step;
    for (int i = 0; i < measure.length; i++) {
      widgets.add(
        Flexible(
          flex: measure.durations[i] ~/ step,
          child: SizedBox(
            width: double.infinity,
            child: ProgressionValueView(value: measure[i]),
          ),
        ),
      );
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
    final int max = measure.timeSignature.denominator;
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
                  RegExp(r"[\w\d, /+°øØ#b♯♭𝄪𝄫]"))
            ],
            decoration: InputDecoration(hintText: initial),
            style: Constants.valueTextStyle,
            onSubmitted: (input) => _submit(),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 3, bottom: 3),
            child: TButton(
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
    initial = '';
    final double step = widget.measure.timeSignature.step;
    for (int i = 0; i < widget.measure.length; i++) {
      final String value =
          Utilities.progressionValueToString(widget.measure[i]);
      double duration = widget.measure.durations[i];
      while (duration > 0) {
        duration -= step;
        initial += value +
            (duration <= 0 && i == widget.measure.length - 1 ? '' : ',    ');
      }
    }
    return initial;
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
