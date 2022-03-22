import 'package:flutter/material.dart';
import 'package:weizmann_theory_app_test/constants.dart';

class ProgressionTitle extends StatefulWidget {
  const ProgressionTitle({Key? key}) : super(key: key);

  @override
  State<ProgressionTitle> createState() => _ProgressionTitleState();
}

class _ProgressionTitleState extends State<ProgressionTitle> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: "My Song's Title");
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
