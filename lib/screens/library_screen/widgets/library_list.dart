import 'package:flutter/material.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:weizmann_theory_app_test/screens/library_screen/widgets/package_view.dart';

class LibraryList extends StatelessWidget {
  const LibraryList({
    Key? key,
    required this.packages,
    required this.searching,
    required this.onOpen,
  }) : super(key: key);

  final Map<String, Map<String, bool>> packages;
  final bool searching;
  final void Function(EntryLocation) onOpen;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
        itemCount: packages.length,
        padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 15.0),
        shrinkWrap: true,
        itemBuilder: (context, index) => PackageView(
          package: packages.keys.elementAt(index),
          searching: searching,
          titles: packages[packages.keys.elementAt(index)]!,
          onOpen: onOpen,
          onTicked: (title, ticked) =>
              packages[packages.keys.elementAt(index)]![title] = ticked,
        ),
      ),
    );
  }
}
