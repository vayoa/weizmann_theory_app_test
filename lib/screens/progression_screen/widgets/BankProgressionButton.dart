import 'package:flutter/material.dart';

import '../../../constants.dart';

class BankProgressionButton extends StatefulWidget {
  const BankProgressionButton({
    Key? key,
    required this.onToggle,
    this.initiallyBanked = false,
    this.canBank = true,
  }) : super(key: key);

  final void Function(bool) onToggle;
  final bool initiallyBanked;
  final bool canBank;

  @override
  _BankProgressionButtonState createState() => _BankProgressionButtonState();
}

class _BankProgressionButtonState extends State<BankProgressionButton> {
  bool hovering = false;
  late bool active;

  @override
  void initState() {
    active = widget.canBank && widget.initiallyBanked;
    super.initState();
  }

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const VerticalDivider(thickness: 0.5, width: 8),
                    SizedBox(
                      height: 18,
                      width: 210,
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            left: hovering ? 0.0 : -20.0,
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              widget.canBank
                                  ? active
                                      ? 'Stop using for other substitutions'
                                      : 'Use for other substitutions'
                                  : 'Progression is longer than 2 - 8 chords',
                              style: TextStyle(
                                fontSize: 12.0,
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
