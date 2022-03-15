import 'package:flutter/material.dart';

import '../Constants.dart';

class BankProgressionButton extends StatefulWidget {
  const BankProgressionButton({
    Key? key,
    required this.onToggle,
    this.canBank = true,
  }) : super(key: key);

  final void Function(bool) onToggle;
  final bool canBank;

  @override
  _BankProgressionButtonState createState() => _BankProgressionButtonState();
}

class _BankProgressionButtonState extends State<BankProgressionButton> {
  bool hovering = false;
  bool active = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: MouseRegion(
        onEnter: (event) {
          if (!hovering) {
            setState(() => hovering = true);
          }
        },
        onExit: (event) {
          if (hovering) {
            setState(() => hovering = false);
          }
        },
        child: GestureDetector(
          onTap: () {
            if (widget.canBank) {
              setState(() {
                active = !active;
                widget.onToggle.call(active);
              });
            }
          },
          child: Row(
            children: [
              Icon(
                widget.canBank
                    ? Icons.music_note_rounded
                    : Icons.music_off_rounded,
                size: 24,
                color: widget.canBank
                    ? active
                        ? Colors.black
                        : Constants.buttonUnfocusedColor
                    : Constants.buttonUnfocusedColor,
              ),
              AnimatedOpacity(
                opacity: hovering ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const VerticalDivider(),
                    SizedBox(
                      height: 24,
                      width: 240,
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            right: hovering ? 0.0 : 30.0,
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              widget.canBank
                                  ? active
                                      ? 'Stop using for other substitutions'
                                      : 'Use for other substitutions'
                                  : 'Progression is longer than 2 - 8 chords',
                              style: TextStyle(
                                color: widget.canBank
                                    ? active
                                        ? Colors.black
                                        : Constants.buttonUnfocusedColor
                                    : Constants.buttonUnfocusedColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
