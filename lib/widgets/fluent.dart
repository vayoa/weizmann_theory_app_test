import 'package:fluent_ui/fluent_ui.dart';
import 'package:weizmann_theory_app_test/widgets/TSuggestionsFrame.dart';

class FluentHome extends StatelessWidget {
  const FluentHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const FluentApp(
      title: 'Weizmann Demo',
      home: ScaffoldPage(
        header: Text('Cool'),
        content: Center(
          child: TSuggestionFrame(),
        ),
      ),
    );
  }
}
