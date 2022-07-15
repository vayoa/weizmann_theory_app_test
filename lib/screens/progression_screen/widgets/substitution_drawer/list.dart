part of 'substitution_drawer.dart';

class _List extends StatefulWidget {
  const _List({Key? key}) : super(key: key);

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> {
  final ScrollController _controller = ScrollController();
  int _expandedIndex = 0;
  ExpandableController? _lastExpanded =
      ExpandableController(initialExpanded: true);

  @override
  void dispose() {
    _controller.dispose();
    _lastExpanded?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      /* TODO: Remove the SizedBox somehow...
               without it we get errors when we scroll */
      child: SizedBox(
        width: double.infinity,
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            interactive: true,
            // thumbVisibility: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.)),
            trackVisibility: MaterialStateProperty.all(true),
          ),
          child: Scrollbar(
            controller: _controller,
            child: ListView.builder(
              controller: _controller,
              shrinkWrap: true,
              itemCount: 40,
              padding: const EdgeInsets.only(
                  top: SubstitutionDrawer.horizontalPadding / 2),
              itemBuilder: (context, index) => ExpandableNotifier(
                controller: index == _expandedIndex ? _lastExpanded : null,
                child: _Substitution(
                  onPressed: (context, controller) {
                    if (controller != null && !controller.expanded) {
                      if (!identical(controller, _lastExpanded)) {
                        _lastExpanded?.expanded = false;
                      }
                      controller.toggle();
                      _expandedIndex = index;
                      context.findRenderObject()?.showOnScreen(
                          duration: const Duration(milliseconds: 500));
                    }
                    _lastExpanded = controller;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Substitution extends StatelessWidget {
  const _Substitution({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

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
      expanded: InkWell(
        onTap: () => onPressed(
          context,
          ExpandableController.of(
            context,
            required: true,
            rebuildOnChange: false,
          ),
        ),
        child: _Expanded(),
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
        child: _Collapsed(),
      ),
    );
  }
}

class _Collapsed extends StatelessWidget {
  const _Collapsed({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SubstitutionDrawer.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Heading(),
          const Divider(height: 5.0),
        ],
      ),
    );
  }
}

class _Expanded extends StatelessWidget {
  const _Expanded({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Constants.selectedColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: SubstitutionDrawer.horizontalPadding),
            child: Stack(
              children: [
                _Heading(),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        label: null,
                        tight: true,
                        size: 12.0,
                        iconSize: 16.0,
                        iconData: Icons.check_rounded,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 5.0),
                      CustomButton(
                        label: null,
                        tight: true,
                        size: 12.0,
                        iconData: Icons.visibility_rounded,
                        iconSize: 16.0,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40.0,
            width: double.infinity,
            child: HorizontalProgressionView(
              padding: const EdgeInsets.only(
                left: SubstitutionDrawer.horizontalPadding,
                right: SubstitutionDrawer.horizontalPadding * 1.4,
              ),
              extent: 200.0,
              progression: DegreeProgression.parse(r"I 2, V 2, I 4"),
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

class _HoverBackground extends StatefulWidget {
  const _HoverBackground({
    Key? key,
    required this.child,
    required this.hovered,
    required this.background,
  }) : super(key: key);

  final Widget child;
  final Color hovered;
  final Color background;

  @override
  State<_HoverBackground> createState() => _HoverBackgroundState();
}

class _HoverBackgroundState extends State<_HoverBackground> {
  late Color _color;

  @override
  void initState() {
    _color = widget.background;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _color = widget.hovered),
      onExit: (_) => setState(() => _color = widget.background),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _color,
        child: widget.child,
      ),
    );
  }
}
