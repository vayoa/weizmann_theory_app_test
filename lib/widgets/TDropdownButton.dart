import 'package:flutter/material.dart';

import '../constants.dart';

class TDropdownButton<T> extends StatelessWidget {
  const TDropdownButton({
    Key? key,
    required this.value,
    this.expandIconData = Icons.expand_more_rounded,
    required this.items,
    required this.onChanged,
    this.valToString,
    this.textSize = 14,
  }) : super(key: key);

  final T value;
  final IconData? expandIconData;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? valToString;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      decoration: BoxDecoration(
        color: Constants.buttonBackgroundColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
      ),
      child: DropdownButton<T>(
        iconSize: textSize,
        value: value,
        isDense: true,
        icon: Icon(expandIconData),
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        dropdownColor: Constants.buttonBackgroundColor,
        focusColor: const Color.fromARGB(255, 227, 227, 227),
        underline: const SizedBox(),
        items: [
          for (T item in items)
            DropdownMenuItem(
              value: item,
              child: Text(
                valToString == null ? '$item' : valToString!.call(item),
                style: TextStyle(fontSize: textSize),
              ),
            )
        ],
        onChanged: onChanged,
      ),
    );
  }
}
