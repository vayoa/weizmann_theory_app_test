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
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ExpandableNotifier(
                  controller: index == _expandedIndex ? _lastExpanded : null,
                  child: _Substitution(
                    location: EntryLocation(
                      nouns[nouns.length - index - 1].capitalize(),
                      nouns[index].capitalize(),
                    ),
                    type: index % 2 == 0
                        ? SubstitutionMatchType.dry
                        : SubstitutionMatchType.tonicization,
                    onPressed: (context, controller) {
                      if (!identical(controller, _lastExpanded)) {
                        _lastExpanded?.expanded = false;
                      }
                      controller?.toggle();
                      _expandedIndex = index;
                      context.findRenderObject()?.showOnScreen(
                          duration: const Duration(milliseconds: 500));
                      _lastExpanded = controller;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
