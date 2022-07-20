part of 'substitution_drawer.dart';

class _List extends StatefulWidget {
  const _List({
    Key? key,
    required this.substitutions,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  final List<Substitution> substitutions;
  final int selected;
  final void Function(int index) onSelected;

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> {
  final ScrollController _controller = ScrollController();
  ExpandableController? _lastExpanded =
      ExpandableController(initialExpanded: true);

  /* TODO: Find a better way than saving a list of global keys...
          using a list of ExpandableControllers isn't possible since
          we need the substitution widget context to make sure it's
          visible...
   */
  late List<GlobalKey<_SubstitutionState>> _keys;

  @override
  void initState() {
    _keys = [for (var i = 0; i < widget.substitutions.length; i++) GlobalKey()];
    super.initState();
  }

  @override
  void didUpdateWidget(_List oldWidget) {
    if (oldWidget.selected != widget.selected) {
      _handleSelected(widget.selected);
    }
    super.didUpdateWidget(oldWidget);
  }

  _handleSelected(int index) {
    if (_keys[index].currentState?.mounted ?? false) {
      setState(() {
        var context = _keys[index].currentContext!;
        var controller = ExpandableController.of(context);
        if (!identical(controller, _lastExpanded)) {
          _lastExpanded?.expanded = false;
        }
        controller?.toggle();
        context
            .findRenderObject()
            ?.showOnScreen(duration: const Duration(milliseconds: 500));
        _lastExpanded = controller;
      });
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
      /* TODO: Remove the SizedBox somehow...
               without it we get errors when we scroll */
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Flexible(
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
                          controller:
                              index == widget.selected ? _lastExpanded : null,
                          child: _Substitution(
                            key: _keys[index],
                            substitution: widget.substitutions[index],
                            onPressed: (context, controller) {
                              widget.onSelected(index);
                            },
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
                      style: TextStyle(fontSize: 11.0),
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
