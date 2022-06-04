import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:weizmann_theory_app_test/blocs/progression_handler_bloc.dart';
import 'package:weizmann_theory_app_test/constants.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/widgets/general_built_in_choice.dart';
import 'package:weizmann_theory_app_test/utilities.dart';

import '../../../blocs/bank/bank_bloc.dart';

class ProgressionTitle extends StatefulWidget {
  const ProgressionTitle({
    Key? key,
    required this.location,
  }) : super(key: key);

  final EntryLocation location;

  @override
  State<ProgressionTitle> createState() => _ProgressionTitleState();
}

class _ProgressionTitleState extends State<ProgressionTitle> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late String title;
  late final String package;
  late final bool builtIn;

  @override
  void initState() {
    title = widget.location.title;
    package = widget.location.package;
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
      child: TextField(
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
                    "empty.");
              } else if (!ProgressionBank.canRename(
                  package: package,
                  previousTitle: savedTitle,
                  newTitle: text)) {
                Utilities.showSnackBar(
                    context,
                    'Can\'t rename to "$text" since there\'s already an entry '
                    'with that name in the library.');
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
              borderSide: BorderSide(color: Constants.buttonUnfocusedColor)),
          suffix: builtIn ? const Icon(Constants.builtInIcon, size: 12) : null,
        ),
      ),
    );
  }
}
