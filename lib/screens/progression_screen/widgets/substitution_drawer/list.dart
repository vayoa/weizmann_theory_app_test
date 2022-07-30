part of 'substitution_drawer.dart';

class _List extends StatefulWidget {
  const _List({
    Key? key,
    required this.substitutions,
    required this.selected,
    required this.visible,
    required this.onSelected,
    required this.onApply,
    required this.onChangeVisibility,
  }) : super(key: key);

  final List<Substitution> substitutions;
  final int selected;
  final bool visible;
  final void Function(int index) onSelected;
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
  late List<GlobalKey<_SubstitutionState>> _keys;
  static const double entryHeight = 57.0;

  @override
  void initState() {
    _keys = [for (var i = 0; i < widget.substitutions.length; i++) GlobalKey()];
    super.initState();
  }

  @override
  void didUpdateWidget(_List oldWidget) {
    if (oldWidget.selected != widget.selected) {
      _handleSelected(widget.selected, oldWidget.selected);
    }
    super.didUpdateWidget(oldWidget);
  }

  _handleSelected(int index, [int? from]) {
    if (_keys[index].currentState?.mounted ?? false) {
      var context = _keys[index].currentContext!;
      var controller = ExpandableController.of(context);
      if (_lastExpanded == null) {
        // if it's null then we just initialized and the selected
        // index is (if we didn't get it in "from") 0...
        int index = from ?? 0;
        if (_keys[index].currentContext != null) {
          ExpandableController.of(_keys[index].currentContext!)?.toggle();
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
                      itemCount: widget.substitutions.length,
                      itemBuilder: (context, index) {
                        return ExpandableNotifier(
                          initialExpanded: index == widget.selected,
                          child: _Substitution(
                            key: _keys[index],
                            substitution: widget.substitutions[index],
                            visible: widget.visible,
                            onPressed: (context, controller) {
                              print(
                                  '${widget.substitutions[index].changedStart} - '
                                  '${widget.substitutions[index].changedEnd}');
                              widget.onSelected(index);
                            },
                            onApply: widget.onApply,
                            onChangeVisibility: widget.onChangeVisibility,
                          ),
                        );
                      }),
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
                      ' ${widget.selected + 1} / '
                      '${widget.substitutions.length}',
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
