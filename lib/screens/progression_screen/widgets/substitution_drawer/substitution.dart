part of 'substitution_drawer.dart';

class _Substitution extends StatefulWidget {
  const _Substitution({
    Key? key,
    required this.substitution,
    required this.onPressed,
  }) : super(key: key);

  final Substitution substitution;
  final void Function(BuildContext context, ExpandableController? controller)
      onPressed;

  @override
  State<_Substitution> createState() => _SubstitutionState();
}

class _SubstitutionState extends State<_Substitution> {
  @override
  Widget build(BuildContext context) {
    return Expandable(
      theme: const ExpandableThemeData(
        hasIcon: false,
        useInkWell: true,
        tapBodyToExpand: true,
        tapBodyToCollapse: true,
      ),
      expanded: _Expanded(
        substitution: widget.substitution,
        onApply: () => BlocProvider.of<ProgressionHandlerBloc>(context)
            .add(ApplySubstitution(widget.substitution)),
        onChangeVisibility: () {},
      ),
      collapsed: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onPressed(
            context,
            ExpandableController.of(
              context,
              required: true,
              rebuildOnChange: false,
            ),
          ),
          child: _Collapsed(
            substitution: widget.substitution,
          ),
        ),
      ),
    );
  }
}

class _Expanded extends StatelessWidget {
  const _Expanded({
    Key? key,
    required this.substitution,
    required this.onApply,
    required this.onChangeVisibility,
  }) : super(key: key);

  final Substitution substitution;
  final void Function() onApply;
  final void Function() onChangeVisibility;

  @override
  Widget build(BuildContext context) {
    final DegreeProgression progression = substitution.originalSubstitution;
    final int measuresInLine = progression.measureCount == 1 ? 1 : 2;
    return Card(
      color: Constants.selectedColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: _Wrapper.horizontalPadding),
            child: Stack(
              children: [
                _Heading(substitution: substitution),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        label: null,
                        tight: true,
                        small: true,
                        size: 12.0,
                        iconSize: 16.0,
                        iconData: Icons.check_rounded,
                        onPressed: onApply,
                      ),
                      const SizedBox(width: 5.0),
                      CustomButton(
                        label: null,
                        tight: true,
                        small: true,
                        size: 12.0,
                        iconSize: 16.0,
                        iconData: Icons.visibility_rounded,
                        onPressed: onChangeVisibility,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5.0),
          Flexible(
            flex: 1,
            child: ProgressionGrid(
              progression: progression,
              measuresInLine: measuresInLine,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                left: _Wrapper.horizontalPadding,
                right: _Wrapper.horizontalPadding,
              ),
              mainAxisSpacing: 10.0,
              maxCrossAxisExtent: measuresInLine == 1 ? null : 200.0,
              mainAxisExtent: measuresInLine == 1 ? 40.0 : null,
            ),
            // child: SizedBox(
            //   height: 40.0,
            //   child: HorizontalProgressionView(
            //     progression: DegreeProgression.parse(r"I 2, V 2, I 4"),
            //     padding: const EdgeInsets.only(
            //       left: SubstitutionDrawer.horizontalPadding,
            //       right: SubstitutionDrawer.horizontalPadding * 1.4,
            //     ),
            //     extent: 200.0,
            //   ),
            // ),
          ),
          const SizedBox(height: 13.0),
          const Divider(height: 1.0),
        ],
      ),
    );
  }
}

class _Collapsed extends StatelessWidget {
  const _Collapsed({
    Key? key,
    required this.substitution,
  }) : super(key: key);

  final Substitution substitution;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: _Wrapper.horizontalPadding + 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12.0),
          _Heading(substitution: substitution),
          const SizedBox(height: 4.0),
          const Divider(height: 1.0),
        ],
      ),
    );
  }
}
