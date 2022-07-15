part of 'substitution_drawer.dart';

class _Preferences extends StatefulWidget {
  const _Preferences({Key? key}) : super(key: key);

  @override
  State<_Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<_Preferences> {
  late KeepHarmonicFunctionAmount _keepHarmonicFunction;
  late Sound _sound;

  static final amountNames = [
    for (KeepHarmonicFunctionAmount amount in KeepHarmonicFunctionAmount.values)
      amount.name
  ];

  static final soundNames = [
    for (Sound sound in Sound.values) sound.name.capitalize()
  ];

  @override
  void initState() {
    _keepHarmonicFunction =
        BlocProvider.of<SubstitutionHandlerBloc>(context).keepHarmonicFunction;
    _sound = BlocProvider.of<SubstitutionHandlerBloc>(context).sound;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HarmonizationSetting(
          title: 'Keep Harmonic Function:',
          values: amountNames,
          value: _keepHarmonicFunction.name,
          onPressed: (index) {
            KeepHarmonicFunctionAmount amount =
                KeepHarmonicFunctionAmount.values[index];
            if (_keepHarmonicFunction != amount) {
              setState(() {
                _keepHarmonicFunction = amount;
              });
            }
            return true;
          },
        ),
        const SizedBox(height: 6.0),
        _HarmonizationSetting(
          title: 'Sound:',
          values: soundNames,
          value: _sound.name.capitalize(),
          onPressed: (index) {
            Sound newSound = Sound.values[index];
            if (_sound != newSound) {
              setState(() {
                _sound = newSound;
              });
            }
            return true;
          },
        ),
      ],
    );
  }
}

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
