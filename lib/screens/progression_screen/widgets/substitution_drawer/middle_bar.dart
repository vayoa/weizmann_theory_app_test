part of 'substitution_drawer.dart';

class _MiddleBar extends StatelessWidget {
  const _MiddleBar({
    Key? key,
    required this.showNav,
    required this.onGo,
    required this.onNavigation,
  }) : super(key: key);

  final bool showNav;
  final void Function()? onGo;
  final void Function(bool forward, bool longPress) onNavigation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showNav) ...[
          NavigationButtonsBar(
            vertical: true,
            onNavigation: onNavigation,
          ),
          const SizedBox(width: 8),
        ],
        CustomButton(
          label: 'Go!',
          tight: true,
          small: true,
          iconData: Icons.keyboard_double_arrow_right_rounded,
          size: 12.0,
          iconSize: 16.0,
          onPressed: onGo,
        ),
      ],
    );
  }
}
