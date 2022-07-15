part of 'substitution_drawer.dart';

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.onClose,
    required this.popup,
  }) : super(key: key);

  final void Function() onClose;
  final bool popup;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SubstitutionDrawer.horizontalPadding,
            SubstitutionDrawer.topPadding,
            SubstitutionDrawer.horizontalPadding,
            0.0,
          ),
          child: Column(
            children: [
              _TopBar(popup: popup, onClose: onClose),
              const Divider(height: 14),
              const _Preferences(),
              const SizedBox(height: 10),
              const _MiddleBar(),
              const SizedBox(
                  height: SubstitutionDrawer.horizontalPadding / 2.0),
            ],
          ),
        ),
        const _List(),
      ],
    );
  }
}
