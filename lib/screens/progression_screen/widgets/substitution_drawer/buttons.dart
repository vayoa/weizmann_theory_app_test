part of 'substitution_drawer.dart';

class _Buttons extends StatelessWidget {
  const _Buttons({
    Key? key,
    required this.visible,
    required this.onApply,
    required this.onChangeVisibility,
    required this.onInspect,
  }) : super(key: key);

  final bool visible;
  final void Function() onApply;
  final void Function() onChangeVisibility;
  final void Function() onInspect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            label: null,
            tight: true,
            small: true,
            size: 11.0,
            iconSize: 14.0,
            iconData: Icons.tune_rounded,
            onPressed: onInspect,
          ),
          const SizedBox(width: 5.0),
          CustomButton(
            label: null,
            tight: true,
            small: true,
            size: 10.0,
            iconSize: 16.0,
            color: Constants.substitutionColor,
            iconData: Icons.check_rounded,
            onPressed: onApply,
          ),
          const SizedBox(width: 5.0),
          CustomButton(
            label: null,
            tight: true,
            small: true,
            size: 10.0,
            iconSize: 16.0,
            iconData: visible
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            onPressed: onChangeVisibility,
          ),
        ],
      ),
    );
  }
}
