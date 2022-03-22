import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:weizmann_theory_app_test/Constants.dart';

import '../../../utilities.dart';
import '../../../widgets/TButton.dart';
import 'progression_value_view.dart';

class Measure extends StatelessWidget {
  const Measure({
    Key? key,
    required this.child,
    this.last = false,
    this.fromChord,
    this.toChord,
  }) : super(key: key);

  final Widget child;
  final bool last;
  final int? fromChord;
  final int? toChord;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
        ),
      ],
    );
  }
}

class MeasureView<T> extends StatelessWidget {
  const MeasureView({
    Key? key,
    required this.measure,
    required this.onEdit,
    this.last = false,
    this.editable = true,
    this.fromChord,
    this.toChord,
  }) : super(key: key);

  final Progression<T> measure;
  final void Function() onEdit;
  final bool last;
  final bool editable;
  final int? fromChord;
  final int? toChord;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Measure(
          last: last,
          fromChord: fromChord,
          toChord: toChord,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: buildList(),
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
    for (int i = 0; i < measure.length; i++) {
      _addProgressionValueView(
        widgets: widgets,
        value: measure[i],
        duration: measure.durations[i],
        minDuration: measure.minDuration,
        index: i,
        paint: fromChord != null &&
            toChord != null &&
            i >= fromChord! &&
            i <= toChord!,
      );
    }
    if (!measure.full && last) {
      widgets.add(const SizedBox(
        height: Constants.measureHeight - (Constants.measureFontSize * 0.8),
        child: VerticalDivider(thickness: 4),
      ));
      widgets.add(Spacer(
          flex: (measure.timeSignature.decimal - measure.duration) ~/
              measure.timeSignature.step));
    }
    return widgets;
  }

  _addProgressionValueView({
    required List<Widget> widgets,
    required T? value,
    required double duration,
    required double minDuration,
    required int index,
    required bool paint,
  }) {
    widgets.add(
      Flexible(
        flex: duration ~/ minDuration,
        child: Material(
          // TODO: Do it without the material widget.
          color: paint ? Constants.rangeSelectColor : Colors.transparent,
          // TODO: Find a way without a row...
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [ProgressionValueView(value: value)],
          ),
        ),
      ),
    );
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
    this.fromChord,
    this.toChord,
  }) : super(key: key);

  final Progression<T> measure;
  final void Function(bool rebuild, List<String> inputs) onDone;
  final bool last;
  final int? fromChord;
  final int? toChord;

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
          fromChord: widget.fromChord,
          toChord: widget.toChord,
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
