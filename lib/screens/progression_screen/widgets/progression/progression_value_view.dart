import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../blocs/input/input_cubit.dart';
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

class EditedValueView<T> extends StatefulWidget {
  const EditedValueView({
    Key? key,
    required this.value,
    required this.position,
    required this.onSubmitChange,
  }) : super(key: key);

  final T value;

  // Used for equality purposes
  final int position;

  final void Function(EditAction) onSubmitChange;

  @override
  State<EditedValueView> createState() => _EditedValueViewState();
}

class _EditedValueViewState extends State<EditedValueView> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late String _initial;

  @override
  void initState() {
    _initial = Utilities.progressionValueToEditString(widget.value);
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _setController(_initial);
    super.initState();
  }

  @override
  void didUpdateWidget(EditedValueView oldWidget) {
    if (oldWidget.value != widget.value ||
        oldWidget.position != widget.position) {
      _initial = Utilities.progressionValueToEditString(widget.value);
      _setController(_initial);
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
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          final text = _controller.text;
          bool ctrl = RawKeyboard.instance.keysPressed
              .contains(LogicalKeyboardKey.controlLeft);
          if (key == LogicalKeyboardKey.backspace) {
            if (ctrl || text.isEmpty) {
              widget.onSubmitChange(EditAction('', Cursor.previous, ctrl));
            }
          } else if (key == LogicalKeyboardKey.arrowRight) {
            if (ctrl || _controller.selection.baseOffset == text.length) {
              widget.onSubmitChange(EditAction(null, Cursor.next, ctrl));
            }
          } else if (key == LogicalKeyboardKey.arrowLeft) {
            if (ctrl || _controller.selection.baseOffset == 0) {
              widget.onSubmitChange(EditAction(null, Cursor.previous, ctrl));
            }
          } else if (key == LogicalKeyboardKey.space) {
            if (ctrl) {
              widget.onSubmitChange(const EditAction(
                'm',
                Cursor.stay,
                true,
                Position.appendMeasure,
              ));
            }
          } else if (key == LogicalKeyboardKey.keyV) {
            if (ctrl) print('hey');
          }
        }
      },
      child: TextField(
        autofocus: true,
        controller: _controller,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[\w\d, /^/+°øØ#b♯♭𝄪𝄫]"))
        ],
        decoration: InputDecoration(
          hintText: _initial,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        style: Constants.valueTextStyle,
        onSubmitted: (input) {
          input = input.trim();
          widget.onSubmitChange(EditAction(
            input != _initial ? input : null,
            Cursor.done,
          ));
        },
        onChanged: (input) {
          if (input.isNotEmpty) {
            if (input[input.length - 1] == ' ') {
              input = input.trim();
              widget.onSubmitChange(
                  EditAction(input != _initial ? input : null, Cursor.next));
            } else if (input[0] == ' ') {
              widget.onSubmitChange(
                  const EditAction('', Cursor.stay, false, Position.prepend));
            }
          }
        },
      ),
    );
  }
}
