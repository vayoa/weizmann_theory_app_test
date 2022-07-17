part of 'substitution_drawer.dart';

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.onClose,
    required this.popup,
  }) : super(key: key);

  final void Function() onClose;
  final bool popup;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SubstitutionDrawer.horizontalPadding,
            SubstitutionDrawer.topPadding,
            SubstitutionDrawer.horizontalPadding,
            0.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(popup: popup, onClose: onClose),
              const SizedBox(height: 7.0),
              const Divider(height: 1.0),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: ExpandablePanel(
            theme: const ExpandableThemeData(hasIcon: false),
            header: Padding(
              padding: const EdgeInsets.fromLTRB(
                SubstitutionDrawer.horizontalPadding,
                7.0,
                SubstitutionDrawer.horizontalPadding,
                0.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Preferences',
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.bold),
                      ),
                      _MiddleBar(),
                    ],
                  ),
                  const SizedBox(height: 7.0),
                  const Divider(height: 1.0),
                ],
              ),
            ),
            collapsed: const SizedBox(),
            expanded: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SubstitutionDrawer.horizontalPadding),
              child: Column(
                children: const [
                  SizedBox(height: 6.0),
                  _Preferences(),
                  SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
        ),
        const _List(),
      ],
    );
  }
}
