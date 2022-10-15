part of 'substitution_drawer.dart';

class _Heading extends StatelessWidget {
  const _Heading({
    Key? key,
    required this.substitution,
  }) : super(key: key);

  final Substitution substitution;

  @override
  Widget build(BuildContext context) {
    EntryLocation location = substitution.subContext.location!;
    SubstitutionMatchType type = substitution.subContext.match.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextAndIcon(
          icon: Constants.packageIcon,
          text: location.package,
          style: const TextStyle(fontSize: 12.0),
          iconSize: 12.0,
        ),
        OverflowBar(
          children: [
            Text(
              '${location.title} ',
              maxLines: 2,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: type.name,
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 13.0)),
                  WidgetSpan(
                    baseline: TextBaseline.ideographic,
                    alignment: PlaceholderAlignment.aboveBaseline,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: WeightPreviewButton(
                        substitution: substitution,
                        size: 13.0,
                      ),
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
