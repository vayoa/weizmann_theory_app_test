import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:weizmann_theory_app_test/constants.dart';
import 'package:weizmann_theory_app_test/utilities.dart';

import '../../../blocs/bank/bank_bloc.dart';

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
  late String savedTitle;

  @override
  void initState() {
    title = widget.title;
    savedTitle = title;
    _controller = TextEditingController(text: title);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus &&
          _controller.text != title &&
          _controller.text != savedTitle) {
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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: TextField(
        focusNode: _focusNode,
        controller: _controller,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        inputFormatters: [
          LengthLimitingTextInputFormatter(Constants.maxTitleCharacters)
        ],
        onSubmitted: (text) {
          if (ProgressionBank.canRename(
              previousTitle: savedTitle, newTitle: text)) {
            BlocProvider.of<BankBloc>(context)
                .add(RenameEntry(previousTitle: savedTitle, newTitle: text));
            setState(() {
              title = text;
              savedTitle = text;
            });
          } else {
            Utilities.showSnackBar(
                context,
                'Can\'t rename to "$text" since there\'s already an entry '
                'with that name in the library.');
          }
        },
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Constants.buttonUnfocusedColor)),
        ),
      ),
    );
  }
}
