import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/state/progression_bank.dart';

import '../../../blocs/bank/bank_bloc.dart';
import '../../../blocs/progression_handler_bloc.dart';
import '../../../constants.dart';
import '../../../utilities.dart';
import 'general_built_in_choice.dart';

class ProgressionTitle extends StatefulWidget {
  const ProgressionTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<ProgressionTitle> createState() => _ProgressionTitleState();
}

class _ProgressionTitleState extends State<ProgressionTitle> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late String title;
  late String package;
  late bool builtIn;

  @override
  void initState() {
    title = widget.title;
    package = BlocProvider.of<ProgressionHandlerBloc>(context).location.package;
    builtIn = package == ProgressionBank.builtInPackageName;
    _controller = TextEditingController(text: title);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus &&
          _controller.text != title &&
          _controller.text !=
              BlocProvider.of<ProgressionHandlerBloc>(context).location.title) {
        setState(() {
          _controller.text = title;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: BlocConsumer<ProgressionHandlerBloc, ProgressionHandlerState>(
        listenWhen: (prev, state) => state is ChangedLocation,
        buildWhen: (prev, state) => state is ChangedLocation,
        listener: (context, state) => setState(() {
          package =
              BlocProvider.of<ProgressionHandlerBloc>(context).location.package;
          builtIn = package == ProgressionBank.builtInPackageName;
        }),
        builder: (context, state) {
          return TextField(
            focusNode: _focusNode,
            controller: _controller,
            style: Constants.titleTextStyle,
            inputFormatters: [
              LengthLimitingTextInputFormatter(Constants.maxTitleCharacters)
            ],
            onSubmitted: (text) async {
              if (text != title) {
                bool? r = true;
                if (builtIn) {
                  r = await showGeneralDialog<bool>(
                    context: context,
                    pageBuilder: (context, _, __) => GeneralBuiltInChoice(
                      prefix: 'Are you sure you want to rename a ',
                      onPressed: (choice) => Navigator.pop(context, choice),
                    ),
                  );
                }
                if (r == true) {
                  final String savedTitle =
                      BlocProvider.of<ProgressionHandlerBloc>(context)
                          .location
                          .title;
                  if (text.isEmpty || RegExp(r'^\s*$').hasMatch(text)) {
                    Utilities.showSnackBar(
                      context,
                      "Can't rename to \"$text\" since entry titles can't be "
                      "empty.",
                      SnackBarType.error,
                    );
                  } else if (!ProgressionBank.canRename(
                      package: package,
                      previousTitle: savedTitle,
                      newTitle: text)) {
                    Utilities.showSnackBar(
                      context,
                      'Can\'t rename to "$text" since there\'s already an entry '
                      'with that name in the library.',
                      SnackBarType.error,
                    );
                  } else {
                    BlocProvider.of<BankBloc>(context).add(RenameEntry(
                        location: EntryLocation(package, savedTitle),
                        newTitle: text));
                    BlocProvider.of<ProgressionHandlerBloc>(context).location =
                        EntryLocation(package, text);
                    setState(() {
                      title = text;
                      _controller.text = title;
                    });
                  }
                }
              }
            },
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              focusedBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Constants.buttonUnfocusedColor)),
              suffix:
                  builtIn ? const Icon(Constants.builtInIcon, size: 12) : null,
            ),
          );
        },
      ),
    );
  }
}
