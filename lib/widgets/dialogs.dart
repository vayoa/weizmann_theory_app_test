import 'package:flutter/material.dart';

import '../constants.dart';
import 'TButton.dart';

class GeneralDialog extends StatelessWidget {
  static const double defaultWidthFactor = 0.4;
  static const double defaultHeightFactor = 0.2;

  const GeneralDialog({
    Key? key,
    required this.child,
    this.widthFactor = defaultWidthFactor,
    this.heightFactor = defaultHeightFactor,
  }) : super(key: key);

  final double widthFactor;
  final double heightFactor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: Material(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: child,
        ),
      ),
    );
  }
}

class GeneralDialogPage extends StatelessWidget {
  const GeneralDialogPage({
    Key? key,
    this.title = '',
    required this.child,
  }) : super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GeneralDialog(
      widthFactor: 0.7,
      heightFactor: 0.8,
      child: Column(
        children: [
          Row(
            children: [
              TButton(
                label: 'Back',
                tight: true,
                iconData: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }
}

class GeneralDialogChoice extends StatelessWidget {
  const GeneralDialogChoice({
    Key? key,
    required this.title,
    required this.onPressed,
    this.noButtonName = 'No',
    this.yesButtonName = 'Yes',
    this.widthFactor = GeneralDialog.defaultWidthFactor,
    this.heightFactor = GeneralDialog.defaultHeightFactor,
  }) : super(key: key);

  final Widget title;
  final String noButtonName;
  final String yesButtonName;
  final void Function(bool) onPressed;
  final double widthFactor;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    return GeneralDialog(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          title,
          SizedBox(
            width: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TButton(
                  label: noButtonName,
                  iconData: Icons.close,
                  tight: true,
                  onPressed: () => onPressed(false),
                ),
                TButton(
                  label: yesButtonName,
                  iconData: Icons.check,
                  tight: true,
                  onPressed: () => onPressed(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GeneralDialogTextField extends StatefulWidget {
  const GeneralDialogTextField({
    Key? key,
    required this.title,
    required this.onCancelled,
    required this.onSubmitted,
    this.cancelButtonName = 'Cancel',
    this.submitButtonName = 'Submit',
  }) : super(key: key);

  final Widget title;
  final String cancelButtonName;
  final String submitButtonName;
  final void Function(String) onCancelled;
  final String? Function(String) onSubmitted;

  @override
  _GeneralDialogTextFieldState createState() => _GeneralDialogTextFieldState();
}

class _GeneralDialogTextFieldState extends State<GeneralDialogTextField> {
  late final TextEditingController _controller;
  String? errorMessage;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GeneralDialogChoice(
      widthFactor: GeneralDialog.defaultWidthFactor + 0.05,
      heightFactor: GeneralDialog.defaultHeightFactor + 0.05,
      title: Column(
        children: [
          widget.title,
          TextField(
            controller: _controller,
            maxLength: Constants.maxTitleCharacters,
            maxLines: 1,
            style: Constants.boldedValuePatternTextStyle,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              constraints: const BoxConstraints(maxWidth: 36 * 11),
              errorText: errorMessage,
            ),
            onSubmitted: _submit,
            onChanged: (text) {
              if (errorMessage != null) {
                setState(() => errorMessage = null);
              }
            },
          ),
        ],
      ),
      noButtonName: widget.cancelButtonName,
      yesButtonName: widget.submitButtonName,
      onPressed: (choice) {
        if (choice) {
          _submit(_controller.text);
        } else {
          widget.onCancelled(_controller.text);
        }
      },
    );
  }

  void _submit(String text) {
    String? error = widget.onSubmitted(text);
    if (error != null) {
      setState(() => errorMessage = error);
    } else if (errorMessage != null) {
      setState(() => errorMessage = null);
    }
  }
}
