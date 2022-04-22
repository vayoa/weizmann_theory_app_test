import 'package:flutter/material.dart';

import '../constants.dart';
import 'TButton.dart';

class GeneralDialog extends StatelessWidget {
  const GeneralDialog({
    Key? key,
    required this.child,
    this.widthFactor = 0.4,
    this.heightFactor = 0.2,
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
  }) : super(key: key);

  final Widget title;
  final String noButtonName;
  final String yesButtonName;
  final void Function(bool) onPressed;

  @override
  Widget build(BuildContext context) {
    return GeneralDialog(
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
