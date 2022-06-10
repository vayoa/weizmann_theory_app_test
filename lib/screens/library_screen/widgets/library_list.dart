import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:weizmann_theory_app_test/screens/library_screen/widgets/package_view.dart';

import '../../../Constants.dart';
import '../../../blocs/bank/bank_bloc.dart';
import '../../../widgets/file_dropper.dart';

class LibraryList extends StatelessWidget {
  const LibraryList({
    Key? key,
    required this.packages,
    required this.hasSelected,
    required this.searching,
    required this.onOpen,
  }) : super(key: key);

  final Map<String, Map<String, bool>> packages;
  final Map<String, bool?> hasSelected;
  final bool searching;
  final void Function(EntryLocation) onOpen;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scrollbar(
          child: ListView.builder(
            itemCount: packages.length,
            padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 15.0),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final String package = packages.keys.elementAt(index);
              return PackageView(
                package: package,
                searching: searching,
                hasSelected: hasSelected.containsKey(package)
                    ? hasSelected[package]
                    : false,
                titles: packages[package]!,
                onOpen: onOpen,
                onTicked: (title, ticked) =>
                    BlocProvider.of<BankBloc>(context).add(
                  SelectEntry(
                    location: EntryLocation(package, title),
                    selected: ticked,
                  ),
                ),
                onTickedAll: (ticked) => BlocProvider.of<BankBloc>(context).add(
                  SelectPackage(
                    package: package,
                    selected: ticked ?? false,
                  ),
                ),
              );
            },
          ),
        ),
        FileDropper(
          onUrlsDropped: (urls) => BlocProvider.of<BankBloc>(context)
              .add(ImportPackages(jsonFileUrls: urls)),
          boxDecoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Constants.rangeSelectTransparentColor,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
