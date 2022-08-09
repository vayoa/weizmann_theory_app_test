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
    required this.onNavigation,
    required this.onApply,
    required this.onOpenDrawer,
    required this.onChangeVisibility,
    required this.onQuit,
  }) : super(key: key);

  final bool visible;
  final void Function(bool forward) onNavigation;
  final void Function() onApply;
  final void Function() onOpenDrawer;
  final void Function() onChangeVisibility;
  final void Function() onQuit;

  @override
  State<SubstitutionOverlay> createState() => _SubstitutionOverlayState();
}

class _SubstitutionOverlayState extends State<SubstitutionOverlay> {
  bool _locked = false;

  static const double horizontalPadding = 4.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            label: 'Apply',
            tight: true,
            small: true,
            size: 12.0,
            iconSize: 14.0,
            color: Constants.substitutionColor,
            iconData: Icons.check_rounded,
            onPressed: widget.onApply,
          ),
          const SizedBox(width: horizontalPadding),
          CustomButton(
            label: null,
            tight: true,
            small: true,
            iconSize: 14.0,
            iconData: widget.visible
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            onPressed: _lock,
            onHover: (entered) {
              if (_locked && entered) {
                _lock();
              }
              if (entered || !_locked) {
                widget.onChangeVisibility();
              }
            },
          ),
          const SizedBox(width: horizontalPadding),
          NavigationButtonsBar(
            onNavigation: widget.onNavigation,
          ),
          const SizedBox(width: horizontalPadding),
          CustomButton(
            label: null,
            tight: true,
            small: true,
            iconSize: 14.0,
            iconData: Icons.read_more_rounded,
            onPressed: widget.onOpenDrawer,
          ),
          const SizedBox(width: horizontalPadding),
          CustomButton(
            label: null,
            tight: true,
            small: true,
            iconSize: 16.0,
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
          onApply: () {
            final sub = _bloc.currentSubstitution;
            if (sub != null) {
              _progBloc.add(ApplySubstitution(sub));
            }
          },
          onNavigation: (bool forward) =>
              _bloc.add(ChangeSubstitutionIndexInOrder(forward)),
          onChangeVisibility: () => _bloc.add(ChangeVisibility(!visible)),
          onOpenDrawer: () => _bloc.add(const UpdateShowSubstitutions(true)),
          onQuit: () => _bloc.add(const ClearSubstitutions()),
        );
      },
    );
  }
}
