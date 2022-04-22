import 'package:flutter/material.dart';

import '../../../modals/progression_type.dart';
import '../../../widgets/TSelector.dart';

class ViewTypeSelector extends StatelessWidget {
  const ViewTypeSelector({
    Key? key,
    required this.onPressed,
    this.enabled = true,
    this.tight = false,
    this.startOnChords = true,
  }) : super(key: key);

  final bool enabled;
  final bool tight;
  final bool startOnChords;
  final void Function(ProgressionType newType) onPressed;

  @override
  Widget build(BuildContext context) {
    return TSelector(
      value: startOnChords ? 'Chords' : 'Roman Numerals',
      values: const ['Chords', 'Roman Numerals'],
      tight: tight,
      onPressed: enabled
          ? (index) {
              onPressed.call(index == 0
                  ? ProgressionType.chords
                  : ProgressionType.romanNumerals);
              return true;
            }
          : (i) => false,
    );
  }
}
