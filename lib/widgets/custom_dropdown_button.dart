import 'package:flutter/material.dart';

import 'custom_button.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  const CustomDropdownButton({
    Key? key,
    required this.label,
    required this.iconData,
    this.tight = false,
    required this.items,
    required this.onChoice,
  }) : super(key: key);

  final String label;
  final IconData iconData;
  final bool tight;
  final List<PopupMenuEntry<T>> items;
  final void Function(T?) onChoice;

  @override
  Widget build(BuildContext context) {
    final GlobalKey globalKey = GlobalKey();
    return CustomButton(
      key: globalKey,
      label: label,
      tight: tight,
      iconData: iconData,
      onPressed: () async {
        final RenderBox renderBox =
            (globalKey.currentContext!.findRenderObject() as RenderBox);
        final Offset off =
            renderBox.localToGlobal(Offset(-800, renderBox.size.height + 5));
        await showMenu<T>(
          context: context,
          position: RelativeRect.fromLTRB(off.dx, off.dy, 100, 100),
          items: items,
          elevation: 8.0,
        ).then(onChoice);
      },
    );
  }
}
