import 'package:flutter/material.dart';

import '../constants.dart';

class CustomSelector extends StatefulWidget {
  const CustomSelector({
    Key? key,
    required this.values,
    required this.value,
    this.tight = false,
    required this.onPressed,
  }) : super(key: key);

  final List<String> values;
  final String value;
  final bool tight;
  final bool Function(int) onPressed;

  @override
  State<CustomSelector> createState() => _CustomSelectorState();
}

class _CustomSelectorState extends State<CustomSelector> {
  late final List<bool> _selected;
  int _selectedIndex = 0;

  @override
  void initState() {
    bool found = false;
    _selected = [];
    for (int i = 0; i < widget.values.length; i++) {
      if (widget.value == widget.values[i]) {
        found = true;
        _selectedIndex = i;
        _selected.add(true);
      } else {
        _selected.add(false);
      }
    }
    assert(found);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _selected[_selectedIndex] = false;
      _selectedIndex = widget.values.indexOf(widget.value);
      assert(_selectedIndex != -1);
      _selected[_selectedIndex] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.tight ? Constants.minButtonHeight : null,
      child: Material(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        color: Constants.buttonBackgroundColor,
        child: ToggleButtons(
          renderBorder: false,
          isSelected: _selected,
          onPressed: (index) {
            if (index != _selectedIndex && widget.onPressed.call(index)) {
              setState(() {
                _selected[_selectedIndex] = false;
                _selectedIndex = index;
                _selected[index] = true;
              });
            }
          },
          children: [
            for (String val in widget.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(val, style: const TextStyle(fontSize: 14)),
              ),
          ],
        ),
      ),
    );
  }
}
