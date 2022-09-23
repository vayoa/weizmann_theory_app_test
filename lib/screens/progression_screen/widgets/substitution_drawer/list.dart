part of 'substitution_drawer.dart';

class _List extends StatefulWidget {
  const _List({
    Key? key,
    required this.variationGroups,
    required this.selectedGroup,
    required this.selected,
    required this.visible,
    required this.onSelected,
    required this.onApply,
    required this.onChangeVisibility,
  }) : super(key: key);

  final List<VariationGroup> variationGroups;
  final int selectedGroup;
  final int selected;
  final bool visible;
  final void Function(int group, int index) onSelected;
  final void Function() onApply;
  final void Function() onChangeVisibility;

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> {
  final ScrollController _controller = ScrollController();
  ExpandableController? _lastExpanded;

  /* TODO: Find a better way than saving a list of global keys...
          using a list of ExpandableControllers isn't possible since
          we need the substitution widget context to make sure it's
          visible...
   */
  late List<_ExpansionKeys> _keys;

  @override
  void initState() {
    _keys = [
      for (final group in widget.variationGroups)
        _ExpansionKeys(group.members.length),
    ];
    super.initState();
  }

  @override
  void didUpdateWidget(_List oldWidget) {
    if (oldWidget.selectedGroup != widget.selectedGroup ||
        oldWidget.selected != widget.selected) {
      _handleSelected(widget.selectedGroup, widget.selected,
          oldWidget.selectedGroup, oldWidget.selected);
    }
    super.didUpdateWidget(oldWidget);
  }

  _handleSelected(int group, int index, [int? fromGroup, int? from]) {
    final cvgs = _keys[group].groupKey?.currentState;
    fromGroup ??= 0;
    if (_keys[group].groupKey == null || (cvgs != null && cvgs.mounted)) {
      if (group != fromGroup) {
        _keys[fromGroup].groupKey?.currentState?.collapse();
      }
      if (cvgs != null && !cvgs.isExpanded) {
        cvgs.expand();
      }
      if (_keys[group].members[index].currentState?.mounted ?? false) {
        final context = _keys[group].members[index].currentContext!;
        final controller = ExpandableController.of(context);
        if (_lastExpanded == null) {
          // if it's null then we just initialized and the selected
          // index is (if we didn't get it in "from") 0...
          from ??= 0;
          final key = _keys[fromGroup].members[from];
          if (key.currentContext != null) {
            ExpandableController.of(key.currentContext!)?.toggle();
          }
        } else if (!identical(controller, _lastExpanded)) {
          _lastExpanded?.expanded = false;
        }
        controller?.toggle();
        context
            .findRenderObject()
            ?.showOnScreen(duration: const Duration(milliseconds: 500));
        _lastExpanded = controller;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _lastExpanded?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        /* TODO: Remove the SizedBox somehow...
               without it we get errors when we scroll */
        child: Column(
          children: [
            Expanded(
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
                    itemCount: widget.variationGroups.length,
                    itemBuilder: (context, index) {
                      return _DynamicEntry(
                        keys: _keys[index],
                        substitutions: widget.variationGroups[index].members,
                        initiallyExpanded: index == widget.selected,
                        visible: widget.visible,
                        onSelected: (subIndex) =>
                            widget.onSelected(index, subIndex),
                        onApply: widget.onApply,
                        onChangeVisibility: widget.onChangeVisibility,
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Constants.libraryEntryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 5.0,
                    blurRadius: 15.0,
                    offset: Offset(1.0, 0.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 2.0, thickness: 1.5),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      ' ${widget.selectedGroup + 1} (${widget.selected + 1}) / '
                      '${widget.variationGroups.length} '
                      '${widget.variationGroups[widget.selectedGroup].members.length == 1 ? '' : '(${widget.variationGroups[widget.selectedGroup].members.length})'}',
                      style: const TextStyle(fontSize: 11.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicEntry extends StatelessWidget {
  const _DynamicEntry({
    Key? key,
    required this.keys,
    required this.substitutions,
    required this.initiallyExpanded,
    required this.visible,
    required this.onSelected,
    required this.onApply,
    required this.onChangeVisibility,
  }) : super(key: key);

  final _ExpansionKeys keys;
  final List<Substitution> substitutions;
  final bool initiallyExpanded;
  final bool visible;
  final void Function(int index) onSelected;
  final void Function() onApply;
  final void Function() onChangeVisibility;

  @override
  Widget build(BuildContext context) {
    final firstVariation = _Variation(
      initiallyExpanded: initiallyExpanded,
      stateKey: keys.members.first,
      substitution: substitutions.first,
      visible: visible,
      onSelected: () => onSelected(0),
      onApply: onApply,
      onChangeVisibility: onChangeVisibility,
    );
    if (substitutions.length == 1) return firstVariation;
    return _VariationGroup(
      key: keys.groupKey,
      iconColor: Colors.black,
      showTrailing: false,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: _Wrapper.horizontalPadding),
      color: Colors.black.withAlpha(18),
      length: substitutions.length,
      titleVariation: firstVariation,
      children: [
        ListView.builder(
          itemCount: substitutions.length - 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, subIndex) {
            subIndex++;
            return _Variation(
              initiallyExpanded: initiallyExpanded,
              stateKey: keys.members[subIndex],
              substitution: substitutions[subIndex],
              visible: visible,
              onSelected: () => onSelected(subIndex),
              onApply: onApply,
              onChangeVisibility: onChangeVisibility,
            );
          },
        ),
      ],
    );
  }
}

class _Variation extends StatelessWidget {
  const _Variation({
    Key? key,
    required this.initiallyExpanded,
    required this.stateKey,
    required this.substitution,
    required this.visible,
    required this.onSelected,
    required this.onApply,
    required this.onChangeVisibility,
  }) : super(key: key);

  final bool initiallyExpanded;
  final GlobalKey<_SubstitutionState> stateKey;
  final Substitution substitution;
  final bool visible;
  final void Function() onSelected;
  final void Function() onApply;
  final void Function() onChangeVisibility;

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      initialExpanded: initiallyExpanded,
      child: _Substitution(
        key: stateKey,
        substitution: substitution,
        visible: visible,
        onPressed: (context, controller) => onSelected(),
        onApply: onApply,
        onChangeVisibility: onChangeVisibility,
      ),
    );
  }
}

class _ExpansionKeys {
  final GlobalKey<_VariationGroupState>? groupKey;
  final List<GlobalKey<_SubstitutionState>> members;

  _ExpansionKeys(int length)
      : groupKey = length == 1 ? null : GlobalKey(),
        members = [for (int i = 0; i < length; i++) GlobalKey()];
}
