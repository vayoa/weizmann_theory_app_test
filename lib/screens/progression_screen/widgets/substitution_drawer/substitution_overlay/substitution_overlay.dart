import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/progression_handler_bloc.dart';
import '../../../../../blocs/substitution_handler/substitution_handler_bloc.dart';
import '../../../../../constants.dart';
import '../../../../../screens/progression_screen/widgets/substitution_drawer/navigation_buttons.dart';
import '../../../../../widgets/custom_button.dart';

class SubstitutionOverlay extends StatefulWidget {
  const SubstitutionOverlay({
    Key? key,
    required this.visible,
    required this.inSetup,
    required this.group,
    required this.index,
    required this.onNavigation,
    required this.onApply,
    required this.onOpenDrawer,
    required this.onChangeVisibility,
    required this.onQuit,
  }) : super(key: key);

  final bool visible;
  final bool inSetup;
  final int group;
  final int index;
  final void Function(bool forward, bool long) onNavigation;
  final void Function() onApply;
  final void Function() onOpenDrawer;
  final void Function() onChangeVisibility;
  final void Function() onQuit;

  @override
  State<SubstitutionOverlay> createState() => _SubstitutionOverlayState();
}

class _SubstitutionOverlayState extends State<SubstitutionOverlay> {
  bool _locked = false;

  static const double horizontalPadding = 10.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomButton(
            label: 'Apply',
            tight: true,
            color: Constants.substitutionColor,
            iconData: Icons.check_rounded,
            onPressed: widget.inSetup ? null : widget.onApply,
          ),
          const SizedBox(width: horizontalPadding),
          SizedBox(
            width: 85,
            child: CustomButton(
              label: widget.visible ? " Showing" : " Hiding",
              tight: true,
              iconData: widget.visible
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              onPressed: widget.inSetup ? null : _lock,
              onHover: (entered) {
                if (_locked && entered) {
                  _lock();
                }
                if (entered || !_locked) {
                  widget.onChangeVisibility();
                }
              },
            ),
          ),
          const SizedBox(width: horizontalPadding),
          NavigationButtonsBar(
            onNavigation: widget.onNavigation,
            small: false,
            disable: widget.inSetup,
          ),
          const SizedBox(width: horizontalPadding),
          SizedBox(
            width: 35,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${widget.group + 1} / ${widget.index + 1}',
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: horizontalPadding),
          CustomButton(
            label: "Drawer",
            tight: true,
            iconSize: 14.0,
            iconData: Icons.read_more_rounded,
            onPressed: widget.onOpenDrawer,
          ),
          const SizedBox(width: horizontalPadding),
          CustomButton(
            label: "Quit",
            tight: true,
            iconSize: 14.0,
            iconData: Icons.disabled_by_default_rounded,
            onPressed: widget.onQuit,
          ),
        ],
      ),
    );
  }

  void _lock() => setState(() => _locked = !_locked);
}

class SetSubstitutionOverlay extends StatelessWidget {
  const SetSubstitutionOverlay({
    Key? key,
    this.bloc,
    this.progBloc,
  }) : super(key: key);

  final SubstitutionHandlerBloc? bloc;
  final ProgressionHandlerBloc? progBloc;

  @override
  Widget build(BuildContext context) {
    final SubstitutionHandlerBloc _bloc =
        bloc ?? BlocProvider.of<SubstitutionHandlerBloc>(context);
    final ProgressionHandlerBloc _progBloc =
        progBloc ?? BlocProvider.of<ProgressionHandlerBloc>(context);
    return BlocBuilder<SubstitutionHandlerBloc, SubstitutionHandlerState>(
      bloc: bloc,
      buildWhen: (prev, state) => state is ChangedVisibility,
      builder: (context, state) {
        final bool visible = state is ChangedVisibility ? state.visible : true;
        return SubstitutionOverlay(
          visible: visible,
          inSetup: _bloc.inSetup,
          group: _bloc.currentGroupIndex,
          index: _bloc.currentSubIndex,
          onApply: () {
            final sub = _bloc.currentSubstitution;
            if (sub != null) {
              _progBloc.add(ApplySubstitution(sub));
            }
          },
          onNavigation: (bool forward, bool long) => _bloc.add(
            long
                ? ChangeGroupIndexInOrder(forward)
                : ChangeSubstitutionIndexInOrder(forward),
          ),
          onChangeVisibility: () => _bloc.add(ChangeVisibility(!visible)),
          onOpenDrawer: () => _bloc.add(const UpdateShowSubstitutions(true)),
          onQuit: () => _bloc.add(const ClearSubstitutions()),
        );
      },
    );
  }
}
