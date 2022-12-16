part of 'substitution_drawer.dart';

class _Heading extends StatelessWidget {
  const _Heading({
    Key? key,
    required this.substitution,
    this.onApply,
    this.onChangeVisibility,
    this.visible,
  })  : assert((onApply == null) == (onChangeVisibility == null) &&
            (onApply == null) == (visible == null)),
        super(key: key);

  final Substitution substitution;
  final void Function()? onApply;
  final void Function()? onChangeVisibility;
  final bool? visible;

  @override
  Widget build(BuildContext context) {
    EntryLocation location = substitution.subContext.location!;
    SubstitutionMatchType type = substitution.subContext.match.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextAndIcon(
              icon: Constants.packageIcon,
              text: location.package,
              style: const TextStyle(fontSize: 12.0),
              iconSize: 12.0,
            ),
            if (onApply != null)
              _Buttons(
                visible: visible!,
                onApply: onApply!,
                onChangeVisibility: onChangeVisibility!,
                onInspect: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: 'Details',
                    pageBuilder: (context, _, __) => GeneralDialogPage(
                      title: 'Details',
                      child: Expanded(
                          child: WeightsPreview(score: substitution.score)),
                    ),
                  );
                },
              ),
          ],
        ),
        OverflowBar(
          children: [
            Text.rich(
              TextSpan(
                text: '${location.title} ',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: type.name,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
            ),
          ],
        ),
      ],
    );
  }
}
