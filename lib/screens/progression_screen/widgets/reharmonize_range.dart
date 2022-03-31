import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/progression_handler_bloc.dart';
import '../../../constants.dart';

class ReharmonizeRange extends StatefulWidget {
  const ReharmonizeRange({Key? key, this.textSize = 14}) : super(key: key);

  final double textSize;

  @override
  State<ReharmonizeRange> createState() => _ReharmonizeRangeState();
}

class _ReharmonizeRangeState extends State<ReharmonizeRange> {
  final RegExp validInput = RegExp(r"[0-9 -]"),
      validSubmit = RegExp(r"^ *[1-9]{1}[\d]* *- *[1-9]{1}[\d]*");
  late TextStyle style;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    style = TextStyle(fontSize: widget.textSize - 2);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ReharmonizeRange oldWidget) {
    style = TextStyle(fontSize: widget.textSize - 2);
    super.didUpdateWidget(oldWidget);
  }

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
        ProgressionHandlerBloc bloc =
            BlocProvider.of<ProgressionHandlerBloc>(context);
        return SizedBox(
          width: widget.textSize * 3.8,
          child: TextField(
            controller: controller,
            inputFormatters: [FilteringTextInputFormatter.allow(validInput)],
            enableInteractiveSelection: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: '${bloc.fromChord + 1} - ${bloc.toChord + 1}',
              hintStyle: style,
              border: const UnderlineInputBorder(
                  borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(Constants.borderRadius)),
                  borderSide: BorderSide.none),
              fillColor: Constants.rangeSelectTransparentColor,
              filled: true,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
                bloc.add(ChangeRange(fromChord: from - 1, toChord: to - 1));
              } else {
                print('not valid');
              }
              controller.clear();
            },
          ),
        );
      },
    );
  }
}
