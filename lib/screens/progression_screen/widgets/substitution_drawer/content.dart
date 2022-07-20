part of 'substitution_drawer.dart';

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.popup,
    required this.showNav,
    required this.goDisabled,
    required this.onClose,
    required this.onQuit,
    required this.onNavigation,
    required this.child,
  }) : super(key: key);

  final bool popup;
  final bool showNav;
  final bool goDisabled;
  final void Function() onClose;
  final void Function() onQuit;
  final void Function(bool forward) onNavigation;
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
              _TopBar(popup: popup, onClose: onClose, onQuit: onQuit),
              const SizedBox(height: 7.0),
              const Divider(height: 1.0),
            ],
          ),
        ),
        _PreferencesBar(showNav: showNav, onNavigation: onNavigation),
        child,
      ],
    );
  }
}
