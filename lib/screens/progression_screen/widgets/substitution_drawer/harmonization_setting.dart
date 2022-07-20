part of 'substitution_drawer.dart';

class _HarmonizationSetting extends StatelessWidget {
  const _HarmonizationSetting({
    Key? key,
    required this.title,
    required this.values,
    required this.value,
    required this.onPressed,
  }) : super(key: key);

  final String title;
  final List<String> values;
  final String value;
  final bool Function(int) onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: Text(title, style: const TextStyle(fontSize: 13.0)),
        ),
        CustomSelector(
          tight: true,
          small: true,
          fontSize: 13.0,
          values: values,
          value: value,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
