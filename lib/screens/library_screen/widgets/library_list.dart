import 'package:flutter/material.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:weizmann_theory_app_test/screens/library_screen/widgets/package_view.dart';

class LibraryList extends StatelessWidget {
  const LibraryList({
    Key? key,
    required this.packages,
    required this.realPackages,
    required this.searching,
    required this.onOpen,
    required this.onTicked,
  }) : super(key: key);

  final Map<String, Map<String, bool>> packages;
  final Map<String, Map<String, bool>> realPackages;
  final bool searching;
  final void Function(EntryLocation) onOpen;
  final void Function() onTicked;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
          itemCount: packages.length,
          padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 15.0),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final String package = packages.keys.elementAt(index);
            return PackageView(
              package: package,
              searching: searching,
              titles: packages[package]!,
              onOpen: onOpen,
              onUpdatedSelection: onTicked,
              onTicked: (title, ticked) {
                packages[package]![title] = ticked;
                realPackages[package]![title] = ticked;
                onTicked();
              },
              onTickedAll: (ticked) {
                ticked ??= false;
                for (var title in packages[package]!.keys) {
                  packages[package]![title] = ticked;
                  realPackages[package]![title] = ticked;
                }
                onTicked();
              },
            );
          }),
    );
  }
}
