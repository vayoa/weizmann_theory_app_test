import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:weizmann_theory_app_test/utilities.dart';

import '../../../blocs/progression_handler_bloc.dart';
import '../../../constants.dart';

class ReharmonizeRange extends StatefulWidget {
  const ReharmonizeRange({
    Key? key,
    this.textSize = 14,
    this.enabled = true,
  }) : super(key: key);

  final double textSize;
  final bool enabled;

  @override
  State<ReharmonizeRange> createState() => _ReharmonizeRangeState();
}

class _ReharmonizeRangeState extends State<ReharmonizeRange> {
  final RegExp validInput = RegExp(r"[\d -.]"),
      validSubmit = RegExp(r"^ *[\d]*.?[\d]+ *-* *[\d]*.{1}[\d]+ *$");
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
          width: widget.textSize * 4.8,
          child: TextField(
            controller: controller,
            enabled: widget.enabled,
            inputFormatters: [FilteringTextInputFormatter.allow(validInput)],
            enableInteractiveSelection: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: bloc.rangeDisabled
                  ? '...'
                  : '${bloc.fromDur} - ${bloc.toDur}',
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
              bool showSnackBar = true;
              if (validSubmit.hasMatch(input)) {
                List<String> values = input.split('-');
                double? start = double.tryParse(values[0].trim());
                double? end = double.tryParse(values.last.trim());
                if (start != null && end != null) {
                  Progression prog = bloc.currentlyViewedProgression;
                  final double step = prog.timeSignature.step;
                  if (start >= 0.0 &&
                      end <= prog.duration &&
                      end - start >= step * 2) {
                    // round both numbers according to step;
                    start = (start / step).ceil() * step;
                    end = (end / step).ceil() * step;
                    showSnackBar = false;
                    bloc.add(ChangeRangeDuration(start: start, end: end));
                  }
                }
              }
              controller.clear();
              if (showSnackBar) {
                Utilities.showSnackBar(
                  context,
                  "Invalid range inputted.",
                  SnackBarType.error,
                );
              }
            },
          ),
        );
      },
    );
  }
}
