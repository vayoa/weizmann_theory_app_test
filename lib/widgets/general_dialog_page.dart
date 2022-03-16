import 'package:flutter/material.dart';

import '../Constants.dart';
import 'TButton.dart';

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
    return FractionallySizedBox(
      widthFactor: 0.7,
      heightFactor: 0.8,
      child: Material(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
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
        ),
      ),
    );
  }
}
