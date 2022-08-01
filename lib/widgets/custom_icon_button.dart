import 'package:flutter/material.dart';

import '../constants.dart';

class TIconButton extends StatefulWidget {
  const TIconButton({
    Key? key,
    required this.size,
    required this.iconData,
    required this.onPressed,
    this.disabled = false,
    this.color,
    this.crop = false,
  }) : super(key: key);

  final double size;
  final IconData iconData;
  final void Function() onPressed;
  final Color? color;
  final bool disabled;
  final bool crop;

  @override
  State<TIconButton> createState() => _TIconButtonState();
}

class _TIconButtonState extends State<TIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Icon icon = getIcon();
    return MouseRegion(
      onEnter: (event) =>
          !widget.disabled ? setState(() => _hovered = true) : null,
      onExit: (event) =>
          !widget.disabled ? setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: (widget.crop
            ? SizedBox(
                width: widget.size * 0.5,
                height: widget.size * 0.5,
                child: OverflowBox(
                  maxWidth: widget.size,
                  maxHeight: widget.size,
                  alignment: Alignment.center,
                  child: icon,
                ),
              )
            : icon),
      ),
    );
  }

  Icon getIcon() => Icon(
    widget.iconData,
        size: widget.size,
        color:
            _hovered ? Constants.selectedColor : (widget.color ?? Colors.black),
      );
}
