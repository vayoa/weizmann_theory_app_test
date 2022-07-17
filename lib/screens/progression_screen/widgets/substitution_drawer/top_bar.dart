part of 'substitution_drawer.dart';

class _TopBar extends StatelessWidget {
  const _TopBar({
    Key? key,
    required this.onClose,
    required this.popup,
  }) : super(key: key);

  final void Function() onClose;
  final bool popup;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomButton(
          label: 'Collapse',
          tight: true,
          iconData: Constants.backIcon,
          // TODO: Once a block controls this don't pass this function and just call the block.
          size: 12,
          onPressed: onClose,
        ),
        if (popup) ...[
          const SizedBox(width: 8.0),
          CustomButton(
            label: 'Pin',
            tight: true,
            iconData: Icons.push_pin_rounded,
            size: 12,
            onPressed: () {},
          ),
        ],
        const Spacer(),
        CustomButton(
          label: ' Quit',
          tight: true,
          iconData: Icons.disabled_by_default_rounded,
          size: 12,
          iconSize: 16.0,
          onPressed: () {},
        ),
      ],
    );
  }
}
