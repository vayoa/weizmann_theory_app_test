import 'package:flutter/material.dart';

import '../modals/progression_type.dart';
import 'TSelector.dart';

class ViewTypeSelector extends StatelessWidget {
  const ViewTypeSelector(
      {Key? key, required this.onPressed, this.tight = false})
      : super(key: key);

  final bool tight;
  final void Function(ProgressionType newType) onPressed;

  @override
  Widget build(BuildContext context) {
    return TSelector(
      value: 'Chords',
      values: const ['Chords', 'Roman Numerals'],
      tight: tight,
      onPressed: (index) {
        onPressed.call(index == 0
            ? ProgressionType.chords
            : ProgressionType.romanNumerals);
        return true;
      },
    );
  }
}
