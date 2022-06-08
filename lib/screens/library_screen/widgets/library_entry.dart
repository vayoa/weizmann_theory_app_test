import 'package:flutter/material.dart';
import 'package:weizmann_theory_app_test/constants.dart';
import 'package:weizmann_theory_app_test/widgets/custom_button.dart';

class LibraryEntry extends StatefulWidget {
  const LibraryEntry({
    Key? key,
    required this.title,
    required this.builtIn,
    this.ticked = true,
    required this.onOpen,
    required this.onDelete,
    required this.onTick,
  }) : super(key: key);

  final String title;
  final bool builtIn;
  final bool ticked;
  final void Function() onOpen;
  final void Function() onDelete;
  final void Function(bool) onTick;

  @override
  State<LibraryEntry> createState() => _LibraryEntryState();
}

class _LibraryEntryState extends State<LibraryEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animationTween;
  bool _hovered = false;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 60),
      vsync: this,
    );
    _animationTween = Tween(begin: 0.0, end: 6.0).animate(_animationController);
    _animationController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Constants.libraryEntryWidth,
      height: Constants.libraryEntryHeight,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) => setState(() {
          _animationController.forward();
          _hovered = true;
        }),
        onExit: (event) => setState(() {
          _animationController.reverse();
          _hovered = false;
        }),
        child: GestureDetector(
          onTap: widget.onOpen,
          child: Material(
            borderRadius: BorderRadius.circular(Constants.borderRadius),
            color: _hovered
                ? Constants.buttonUnfocusedTextColor
                : (widget.ticked
                    ? Constants.rangeSelectColor
                    : Constants.libraryEntryColor),
            elevation: _animationTween.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        (widget.builtIn
                            ? const Padding(
                                padding: EdgeInsets.only(right: 3.0),
                                child: Icon(Constants.builtInIcon, size: 12),
                              )
                            : const SizedBox()),
                        Flexible(
                          child: Text(
                            widget.title,
                            style: const TextStyle(fontSize: 16.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Row(
                    children: [
                      Checkbox(
                        value: widget.ticked,
                        onChanged: (ticked) => widget.onTick(ticked!),
                      ),
                      CustomButton(
                        label: null,
                        iconData: Icons.delete,
                        tight: true,
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
