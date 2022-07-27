part of 'substitution_drawer.dart';

class _TopBar extends StatelessWidget {
  const _TopBar({
    Key? key,
    required this.popup,
    required this.pinned,
    required this.onClose,
    required this.onPin,
    required this.onQuit,
  }) : super(key: key);

  final bool popup;
  final bool pinned;
  final void Function() onClose;
  final void Function() onPin;
  final void Function() onQuit;

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
            label: null,
            tight: true,
            iconData:
                pinned ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
            size: 14,
            onPressed: onPin,
          ),
        ],
        const Spacer(),
        CustomButton(
          label: ' Quit',
          tight: true,
          iconData: Icons.disabled_by_default_rounded,
          size: 12,
          iconSize: 16.0,
          onPressed: onQuit,
        ),
      ],
    );
  }
}
