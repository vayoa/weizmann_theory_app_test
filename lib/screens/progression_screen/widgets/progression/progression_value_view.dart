import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../constants.dart';
import '../../../../utilities.dart';

class ProgressionValueView<T> extends StatelessWidget {
  const ProgressionValueView({
    Key? key,
    required this.value,
    this.highlight = false,
  }) : super(key: key);

  final T? value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    List<String> cut = Utilities.cutProgressionValue(value);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Text.rich(
          TextSpan(
            text: cut[0],
            children: [
              TextSpan(
                text: cut[1],
                style: _handleHighlight(Constants.valuePatternTextStyle),
              )
            ],
          ),
          style: _handleHighlight(Constants.valueTextStyle),
        ),
      ),
    );
  }

  TextStyle _handleHighlight(TextStyle style) => highlight
      ? style.copyWith(
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          color: Constants.substitutionColor,
          shadows: const [
            Shadow(
              offset: Offset(2.0, 2.0),
              blurRadius: 15.0,
              color: Colors.black38,
            )
          ],
        )
      : style;
}

class EditedValueView extends StatefulWidget {
  const EditedValueView({
    Key? key,
    required this.initial,
    required this.onSubmitChange,
  }) : super(key: key);

  final String initial;
  final void Function(String? input, bool? next) onSubmitChange;

  @override
  State<EditedValueView> createState() => _EditedValueViewState();
}

class _EditedValueViewState extends State<EditedValueView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    _setController(widget.initial);
    super.initState();
  }

  @override
  void didUpdateWidget(EditedValueView oldWidget) {
    if (oldWidget.initial != widget.initial) {
      _setController(widget.initial);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _setController(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: _controller,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[\w\d, /^/+°øØ#b♯♭𝄪𝄫]"))
      ],
      decoration: InputDecoration(
        hintText: widget.initial,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
      ),
      style: Constants.valueTextStyle,
      onSubmitted: (input) {
        input = input.trim();
        widget.onSubmitChange(
          input != widget.initial ? input : null,
          null,
        );
      },
      onChanged: (input) {
        if (input.isNotEmpty && input[input.length - 1] == ' ') {
          input = input.trim();
          widget.onSubmitChange(
            input != widget.initial ? input : null,
            true,
          );
        }
      },
    );
  }
}
