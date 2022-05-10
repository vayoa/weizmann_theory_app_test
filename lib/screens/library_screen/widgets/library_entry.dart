import 'package:flutter/material.dart';
import 'package:weizmann_theory_app_test/constants.dart';
import 'package:weizmann_theory_app_test/widgets/custom_button.dart';

class LibraryEntry extends StatelessWidget {
  const LibraryEntry({
    Key? key,
    required this.title,
    required this.builtIn,
    required this.onOpen,
    required this.onDelete,
  }) : super(key: key);

  final String title;
  final bool builtIn;
  final void Function() onOpen;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Constants.libraryEntryWidth,
      height: Constants.libraryEntryHeight,
      child: Material(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        color: Constants.libraryEntryColor,
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
                    (builtIn
                        ? const Padding(
                            padding: EdgeInsets.only(right: 3.0),
                            child: Icon(Constants.builtInIcon, size: 12),
                          )
                        : const SizedBox()),
                    Flexible(
                      child: Text(
                        title,
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
                  CustomButton(
                    label: 'Delete',
                    iconData: Icons.delete,
                    tight: true,
                    onPressed: onDelete,
                  ),
                  const SizedBox(width: 10),
                  CustomButton(
                    label: 'Open',
                    iconData: Icons.edit,
                    tight: true,
                    onPressed: onOpen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
