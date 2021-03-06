import 'package:flutter/material.dart';

import '../../../modals/progression_type.dart';
import '../../../widgets/custom_selector.dart';

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
  final bool Function(ProgressionType newType) onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomSelector(
      value: startOnChords ? 'Chords' : 'Roman Numerals',
      values: const ['Chords', 'Roman Numerals'],
      tight: tight,
      onPressed: enabled
          ? (index) {
              return onPressed.call(index == 0
                  ? ProgressionType.chords
                  : ProgressionType.romanNumerals);
            }
          : (i) => false,
    );
  }
}
