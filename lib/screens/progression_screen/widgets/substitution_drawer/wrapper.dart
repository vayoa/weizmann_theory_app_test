part of 'substitution_drawer.dart';

class _Wrapper extends StatelessWidget {
  const _Wrapper({
    Key? key,
    required this.popup,
    required this.show,
    required this.pinned,
    required this.showNav,
    required this.expandPreferences,
    required this.onUpdate,
    required this.onPin,
    required this.onQuit,
    required this.onNavigation,
    required this.child,
  }) : super(key: key);

  static const double topPadding = 24.0;
  static const double horizontalPadding = 10.0;
  static const double drawerWidth = Constants.measureWidth;

  final bool popup;
  final bool pinned;
  final bool show;
  final bool showNav;
  final bool expandPreferences;
  final void Function(bool shouldShow, bool fromHover) onUpdate;
  final void Function() onPin;
  final void Function() onQuit;
  final void Function(bool forward, bool longPress) onNavigation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const durationMilliseconds = 400;
    const Curve curve = Curves.easeInOut;
    return MouseRegion(
      onEnter: (_) {
        if (popup && !show) onUpdate(true, true);
      },
      onExit: (event) {
        if (!event.down && popup && show) onUpdate(false, true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: durationMilliseconds),
        curve: curve,
        height: double.infinity,
        width: show ? _Wrapper.drawerWidth : 20.0,
        decoration: BoxDecoration(
          color: Constants.libraryEntryColor,
          borderRadius: show
              ? const BorderRadius.only(
                  topRight: Radius.circular(Constants.borderRadius))
              : BorderRadius.zero,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: durationMilliseconds),
          switchOutCurve: curve,
          switchInCurve: curve,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .animate(animation),
              child: child,
            ),
          ),
          child: !show
              ? GestureDetector(
            onTap: () => onUpdate(!show, false),
                  child: const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: _Wrapper.topPadding),
                      child: Icon(Icons.arrow_forward_ios_rounded, size: 12.0),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    // TODO: Sort this without a sized box somehow, in a cleaner way...
                    width: _Wrapper.drawerWidth,
                    child: _Content(
                      popup: popup,
                      pinned: pinned,
                      showNav: showNav,
                      expandPreferences: expandPreferences,
                      onClose: () => onUpdate(false, false),
                      onPin: onPin,
                      onQuit: onQuit,
                      onNavigation: onNavigation,
                      child: child,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
