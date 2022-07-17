part of 'substitution_drawer.dart';

class _MiddleBar extends StatelessWidget {
  const _MiddleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomButton(
          label: null,
          tight: true,
          small: true,
          iconData: Icons.expand_more_rounded,
          iconSize: 16.0,
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        CustomButton(
          label: null,
          tight: true,
          small: true,
          iconData: Icons.expand_less_rounded,
          iconSize: 16.0,
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        CustomButton(
          label: 'Go!',
          tight: true,
          small: true,
          iconData: Icons.keyboard_double_arrow_right_rounded,
          size: 12.0,
          iconSize: 16.0,
          onPressed: () {},
        ),
      ],
    );
  }
}
