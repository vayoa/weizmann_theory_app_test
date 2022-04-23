import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weizmann_theory_app_test/constants.dart';

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

  @override
  void initState() {
    _controller = TextEditingController(text: widget.title);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
        controller: _controller,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        inputFormatters: [
          LengthLimitingTextInputFormatter(Constants.maxTitleCharacters)
        ],
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
