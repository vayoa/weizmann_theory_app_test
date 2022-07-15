part of 'substitution_drawer.dart';

class _Heading extends StatelessWidget {
  const _Heading({
    Key? key,
    required this.location,
    required this.type,
  }) : super(key: key);

  final EntryLocation location;
  final SubstitutionMatchType type;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextAndIcon(
          icon: Constants.packageIcon,
          text: location.package,
          style: const TextStyle(fontSize: 12.0),
          iconSize: 12.0,
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: '${location.title} ',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  )),
              TextSpan(
                  text: type.name,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 13.0)),
              const WidgetSpan(
                baseline: TextBaseline.ideographic,
                alignment: PlaceholderAlignment.aboveBaseline,
                child: Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Icon(
                    Icons.notes_rounded,
                    size: 13.0,
                  ),
                  // WeightPreviewButton(substitution: substitution),
                ),
              ),
            ],
          ),
          maxLines: 2,
        ),
      ],
    );
  }
}
