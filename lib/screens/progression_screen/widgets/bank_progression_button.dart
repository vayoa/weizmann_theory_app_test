import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/state/progression_bank.dart';

import '../../../blocs/bank/bank_bloc.dart';
import '../../../blocs/progression_handler_bloc.dart';
import '../../../constants.dart';

class BankProgressionButton extends StatefulWidget {
  const BankProgressionButton({
    Key? key,
    required this.onToggle,
    this.initiallyBanked = false,
  }) : super(key: key);

  final void Function(bool) onToggle;
  final bool initiallyBanked;

  @override
  BankProgressionButtonState createState() => BankProgressionButtonState();
}

class BankProgressionButtonState extends State<BankProgressionButton> {
  bool hovering = false;
  late bool active;
  late bool canBank;
  String error = '';

  @override
  void initState() {
    String? error = _getError(context);
    canBank = widget.initiallyBanked || error == null;
    error = error ?? '';
    active = canBank && widget.initiallyBanked;
    super.initState();
  }

  String? _getError(BuildContext context) {
    String? error;
    ProgressionHandlerBloc bloc =
        BlocProvider.of<ProgressionHandlerBloc>(context);
    int id = bloc.currentProgression.id;
    if (ProgressionBank.idFreeInSubs(location: bloc.location, id: id)) {
      if (!ProgressionBank.canBeSubstitution(bloc.currentProgression)) {
        error = 'Progression does not consist of 2 - 8 chords';
      }
    } else {
      String title = ProgressionBank
          .substitutionsIDBank[bloc.currentProgression.id]!
          .toString();
      error = 'Progression already exists as "$title".';
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProgressionHandlerBloc, ProgressionHandlerState>(
      listenWhen: (previous, state) => state is ProgressionChanged,
      listener: (context, state) {
        EntryLocation location =
            BlocProvider.of<ProgressionHandlerBloc>(context).location;
        String? error = _getError(context);
        bool canBank = error == null;
        if (!canBank &&
            ProgressionBank
                .bank[location.package]![location.title]!.usedInSubstitutions) {
          BlocProvider.of<BankBloc>(context).add(ChangeUseInSubstitutions(
              location: location, useInSubstitutions: false));
        }
        setState(() {
          canBank = canBank;
          error = error ?? '';
        });
      },
      child: SizedBox(
        height: 30,
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
              if (canBank) {
                setState(() {
                  active = !active;
                  widget.onToggle.call(active);
                });
              }
            },
            child: Tooltip(
              message: canBank
                  ? active
                      ? 'Stop using for other substitutions'
                      : 'Use for other substitutions'
                  : error,
              waitDuration: canBank ? const Duration(seconds: 3) : null,
              preferBelow: true,
              child: Row(
                children: [
                  Icon(
                    canBank
                        ? Icons.music_note_rounded
                        : Icons.music_off_rounded,
                    size: 24,
                    color: canBank
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
                          width: 62,
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                left: hovering ? 0.0 : -20.0,
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  canBank
                                      ? active
                                          ? 'In Use'
                                          : 'Not In Use'
                                      : "Can't Use",
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: active
                                        ? Colors.black
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
        ),
      ),
    );
  }
}
