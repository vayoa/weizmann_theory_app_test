part of 'substitution_drawer.dart';

class _PreferencesBar extends StatefulWidget {
  const _PreferencesBar({
    Key? key,
    required this.showNav,
    required this.expanded,
    required this.onNavigation,
  }) : super(key: key);

  final bool showNav;
  final bool expanded;
  final void Function(bool forward, bool longPress) onNavigation;

  @override
  State<_PreferencesBar> createState() => _PreferencesBarState();
}

class _PreferencesBarState extends State<_PreferencesBar> {
  late final ExpandableController _controller;
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
    _controller = ExpandableController(initialExpanded: widget.expanded);
    _keepHarmonicFunction =
        BlocProvider.of<SubstitutionHandlerBloc>(context).keepHarmonicFunction;
    _sound = BlocProvider.of<SubstitutionHandlerBloc>(context).sound;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _PreferencesBar oldWidget) {
    /* TODO: We might be updating it twice after pressing the "Go!"
            button since it directly calls _toggle()...
     */
    if (oldWidget.expanded != widget.expanded) {
      _toggle(widget.expanded);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _toggle(bool expanded) {
    Future.delayed(
      const Duration(milliseconds: 400),
      () => _controller.value = expanded,
    );
  }

  @override
  Widget build(BuildContext context) {
    SubstitutionHandlerBloc bloc =
        BlocProvider.of<SubstitutionHandlerBloc>(context);
    bool goDisabled = bloc.state is CalculatingSubstitutions ||
        (bloc.variationGroups != null &&
            (bloc.inSetup ||
                (_keepHarmonicFunction == bloc.keepHarmonicFunction &&
                    _sound == bloc.sound)));
    return Material(
      color: Colors.transparent,
      child: ExpandablePanel(
        controller: _controller,
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
                children: [
                  const Text(
                    'Preferences',
                    style:
                        TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  _MiddleBar(
                    showNav: widget.showNav,
                    onGo: goDisabled
                        ? null
                        : () {
                            // To reset our position to the header...
                            bloc.add(const ChangeSubstitutionIndex(0, 0));
                            bloc.add(CalculateSubstitutions(
                              sound: _sound,
                              keepHarmonicFunction: _keepHarmonicFunction,
                            ));
                            _toggle(false);
                          },
                    onNavigation: widget.onNavigation,
                  ),
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
            children: [
              const SizedBox(height: 6.0),
              Column(
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
              ),
              const SizedBox(height: 6.0),
              const Divider(height: 1.0),
            ],
          ),
        ),
      ),
    );
  }
}
