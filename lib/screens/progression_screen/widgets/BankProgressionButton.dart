import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/state/progression_bank.dart';

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
  _BankProgressionButtonState createState() => _BankProgressionButtonState();
}

class _BankProgressionButtonState extends State<BankProgressionButton> {
  bool hovering = false;
  late bool active;
  late bool canBank;
  String error = '';

  @override
  void initState() {
    String? _error = _getError(context);
    canBank = widget.initiallyBanked || _error == null;
    error = _error ?? '';
    active = canBank && widget.initiallyBanked;
    super.initState();
  }

  String? _getError(BuildContext context) {
    String? _error;
    ProgressionHandlerBloc _bloc =
        BlocProvider.of<ProgressionHandlerBloc>(context);
    int id = _bloc.currentProgression.id;
    print(id);
    print(ProgressionBank.substitutionsIDBank[id]);
    if (ProgressionBank.idFreeInSubs(_bloc.title, id)) {
      if (!ProgressionBank.canBeSubstitution(_bloc.currentProgression)) {
        _error = 'Progression is does not consist of 2 - 8 chords';
      }
    } else {
      String title =
          ProgressionBank.substitutionsIDBank[_bloc.currentProgression.id]!;
      _error = 'Progression already exists as "$title".';
    }
    return _error;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProgressionHandlerBloc, ProgressionHandlerState>(
      listenWhen: (previous, state) => state is ProgressionChanged,
      listener: (context, state) {
        var bloc = BlocProvider.of<ProgressionHandlerBloc>(context);
        ScaleDegreeProgression prog = bloc.currentProgression;
        String title = bloc.title;
        String? _error = _getError(context);
        bool _canBank = _error == null;
        if (!_canBank && ProgressionBank.bank[title]!.usedInSubstitutions) {
          BlocProvider.of<BankBloc>(context).add(ChangeUseInSubstitutions(
              title: title, useInSubstitutions: false));
        }
        setState(() {
          canBank = _canBank;
          error = _error ?? '';
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
            child: Row(
              children: [
                Icon(
                  canBank ? Icons.music_note_rounded : Icons.music_off_rounded,
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
                        height: error.length > 40 ? double.infinity : 18,
                        width: 190,
                        child: Stack(
                          children: [
                            AnimatedPositioned(
                              left: hovering ? 0.0 : -20.0,
                              duration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                width: 190,
                                child: Text(
                                  canBank
                                      ? active
                                          ? 'Stop using for other substitutions'
                                          : 'Use for other substitutions'
                                      : error,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: error.length > 40 ? 11.0 : 12.0,
                                    color: canBank
                                        ? active
                                            ? Colors.black
                                            : Constants.buttonUnfocusedColor
                                        : Constants.buttonUnfocusedColor,
                                  ),
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
    );
  }
}
