import 'package:flutter/material.dart';

import '../Constants.dart';
import 'custom_button.dart';

class CustomDropdownButton extends StatefulWidget {
  const CustomDropdownButton({
    Key? key,
    required this.label,
    required this.iconData,
    this.tight = false,
    this.itemHeight = 22.0,
    required this.options,
    required this.onChoice,
  }) : super(key: key);

  final String label;
  final IconData iconData;
  final bool tight;
  final double itemHeight;
  final Map<String, IconData> options;
  final void Function(String option)? onChoice;

  @override
  State<CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      key: _globalKey,
      label: widget.label,
      tight: widget.tight,
      iconData: widget.iconData,
      onPressed: widget.onChoice == null
          ? null
          : () async {
              final RenderBox renderBox =
                  (_globalKey.currentContext!.findRenderObject() as RenderBox);
              final Offset off = renderBox.localToGlobal(Offset.zero);
              String? result = await showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(
                    off.dx, off.dy + renderBox.size.height + 5, off.dx, 1),
                color: Constants.buttonBackgroundColor,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    widget.tight
                        ? Constants.tightBorderRadius
                        : Constants.borderRadius,
                  ),
                ),
                items: [
                  for (String option in widget.options.keys)
                    PopupMenuItem(
                      onTap: () => {},
                      height: widget.itemHeight,
                      value: option,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.options[option]!, size: 14.0),
                          const SizedBox(width: 5.0),
                          Text(option, style: const TextStyle(fontSize: 14.0))
                        ],
                      ),
                    ),
                ],
              );
              if (result != null) {
                widget.onChoice!(result);
              }
            },
    );
  }
}
