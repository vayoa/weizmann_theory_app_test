part of 'substitution_drawer.dart';

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.onClose,
    required this.popup,
    required this.child,
  }) : super(key: key);

  final void Function() onClose;
  final bool popup;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            _Wrapper.horizontalPadding,
            _Wrapper.topPadding,
            _Wrapper.horizontalPadding,
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
                _Wrapper.horizontalPadding,
                7.0,
                _Wrapper.horizontalPadding,
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
                  horizontal: _Wrapper.horizontalPadding),
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
        child,
      ],
    );
  }
}
