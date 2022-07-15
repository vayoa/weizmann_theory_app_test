part of 'substitution_drawer.dart';

class _Substitution extends StatelessWidget {
  const _Substitution({
    Key? key,
    required this.location,
    required this.type,
    required this.onPressed,
  }) : super(key: key);

  final EntryLocation location;
  final SubstitutionMatchType type;
  final void Function(BuildContext context, ExpandableController? controller)
      onPressed;

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
        location: location,
        type: type,
        progression: [
          DegreeProgression.parse(r"I 2, V 2"),
          DegreeProgression.parse(r"I 2, V 2, I 4"),
          DegreeProgression.parse(r"I 2, V 2, I 4, vi 2, V 2, I 4"),
        ][location.package.codeUnitAt(0) % 3],
      ),
      collapsed: InkWell(
        onTap: () => onPressed(
          context,
          ExpandableController.of(
            context,
            required: true,
            rebuildOnChange: false,
          ),
        ),
        child: _Collapsed(location: location, type: type),
      ),
    );
  }
}

class _Expanded extends StatelessWidget {
  const _Expanded({
    Key? key,
    required this.location,
    required this.type,
    required this.progression,
  }) : super(key: key);

  final EntryLocation location;
  final SubstitutionMatchType type;
  final Progression progression;

  @override
  Widget build(BuildContext context) {
    final int measuresInLine = progression.measureCount == 1 ? 1 : 2;
    return Material(
      color: Constants.selectedColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: SubstitutionDrawer.horizontalPadding),
            child: Stack(
              children: [
                _Heading(location: location, type: type),
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
                        onPressed: () {},
                      ),
                      const SizedBox(width: 5.0),
                      CustomButton(
                        label: null,
                        tight: true,
                        small: true,
                        size: 12.0,
                        iconSize: 16.0,
                        iconData: Icons.visibility_rounded,
                        onPressed: () {},
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
            child: ProgressionView.fromProgression(
              progression: progression,
              interactable: false,
              measuresInLine: measuresInLine,
              padding: const EdgeInsets.only(
                left: SubstitutionDrawer.horizontalPadding,
                right: SubstitutionDrawer.horizontalPadding,
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
    required this.location,
    required this.type,
  }) : super(key: key);

  final EntryLocation location;
  final SubstitutionMatchType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SubstitutionDrawer.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8.0),
          _Heading(location: location, type: type),
          const SizedBox(height: 4.0),
          const Divider(height: 1.0),
        ],
      ),
    );
  }
}