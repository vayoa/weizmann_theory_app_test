part of 'substitution_drawer.dart';

class _Heading extends StatelessWidget {
  const _Heading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        TextAndIcon(
          textBefore: 'From',
          icon: Constants.packageIcon,
          text: 'Package',
          style: TextStyle(fontSize: 14.0),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: '"Title" ',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  )),
              TextSpan(
                  text: 'tonicization',
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 14.0)),
              WidgetSpan(
                baseline: TextBaseline.ideographic,
                alignment: PlaceholderAlignment.aboveBaseline,
                child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child:
                        const SizedBox() // WeightPreviewButton(substitution: substitution),
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
