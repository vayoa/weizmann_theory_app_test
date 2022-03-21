import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Constants.dart';
import '../../blocs/progression_handler_bloc.dart';

class ReharmonizeRange extends StatefulWidget {
  const ReharmonizeRange({Key? key, this.textSize = 14}) : super(key: key);

  final double textSize;

  @override
  State<ReharmonizeRange> createState() => _ReharmonizeRangeState();
}

class _ReharmonizeRangeState extends State<ReharmonizeRange> {
  final RegExp validInput = RegExp(r"[0-9 -]"),
      validSubmit = RegExp(r"^[0-9]+ ?- ?[0-9]+");

  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressionHandlerBloc, ProgressionHandlerState>(
      buildWhen: (_, state) => state is RangeChanged,
      builder: (context, state) {
        TextStyle style = TextStyle(fontSize: widget.textSize);
        ProgressionHandlerBloc bloc =
            BlocProvider.of<ProgressionHandlerBloc>(context);
        double height = widget.textSize * 1.5;
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: height,
            maxHeight: height,
            maxWidth: widget.textSize * 4.8,
            minWidth: widget.textSize * 3.8,
          ),
          child: TextField(
            controller: controller,
            inputFormatters: [FilteringTextInputFormatter.allow(validInput)],
            enableInteractiveSelection: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: '${bloc.fromChord} - ${bloc.toChord}',
              hintStyle: style,
              fillColor: Constants.rangeSelectTransparentColor,
              filled: true,
            ),
            style: style,
            textAlign: TextAlign.center,
            autocorrect: false,
            onSubmitted: (input) {
              input = input.trim();
              if (validSubmit.hasMatch(input)) {
                List<String> values = input.split('-');
                int from = int.parse(values[0].trim());
                int to = int.parse(values.last.trim());
                bloc.add(ChangeRange(fromChord: from, toChord: to));
              }
              controller.clear();
            },
          ),
        );
      },
    );
  }
}
