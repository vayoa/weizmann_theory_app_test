import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/state/progression_bank.dart';

import '../../../Constants.dart';
import '../../../blocs/bank/bank_bloc.dart';
import '../../../widgets/dialogs.dart';
import 'library_entry.dart';

class PackageView extends StatelessWidget {
  const PackageView({
    Key? key,
    required this.package,
    required this.titles,
    required this.onOpen,
  }) : super(key: key);

  final String package;
  final List<String> titles;
  final void Function(EntryLocation location) onOpen;

  @override
  Widget build(BuildContext context) {
    final bool builtIn = package == ProgressionBank.builtInPackageName;
    return ExpansionTile(
      title: Text.rich(
        TextSpan(
            text: package,
            children: builtIn
                ? const [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.aboveBaseline,
                      baseline: TextBaseline.ideographic,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Icon(Constants.builtInIcon, size: 12),
                      ),
                    )
                  ]
                : null),
      ),
      initiallyExpanded: (titles.isNotEmpty && !builtIn),
      children: [
        titles.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "No Entries In Package.",
                  style: Constants.valuePatternTextStyle,
                ),
              )
            : GridView.builder(
                itemCount: titles.length,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: Constants.libraryEntryWidth * 1.1,
                    childAspectRatio: Constants.libraryEntryWidth /
                        Constants.libraryEntryHeight,
                    crossAxisSpacing: Constants.libraryEntryWidth * 0.1,
                    mainAxisSpacing: Constants.libraryEntryHeight * 0.8),
                itemBuilder: (context, index) {
                  String currentTitle = titles[titles.length - index - 1];
                  EntryLocation currentLocation =
                      EntryLocation(package, currentTitle);
                  return LibraryEntry(
                      title: currentTitle,
                      builtIn: ProgressionBank.isBuiltIn(currentLocation),
                      onOpen: () => onOpen(currentLocation),
                      onDelete: () async {
                        final bool? _result = await showGeneralDialog<bool>(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: 'Details',
                          pageBuilder: (context, _, __) => GeneralDialogChoice(
                            title: Text.rich(
                              TextSpan(
                                text: 'Are you sure you want to permanently '
                                    'delete "',
                                children: [
                                  TextSpan(
                                    text: currentTitle,
                                    style:
                                        Constants.boldedValuePatternTextStyle,
                                  ),
                                  const TextSpan(text: '"?'),
                                ],
                              ),
                              style: Constants.valuePatternTextStyle,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              softWrap: true,
                            ),
                            onPressed: (deleted) =>
                                Navigator.pop(context, deleted),
                            noButtonName: 'Cancel',
                            yesButtonName: 'DELETE!',
                          ),
                        );
                        // When a choice was made...
                        // This is done like this (and not "if (_result) ..."
                        // since it can be null...
                        if (_result == true) {
                          BlocProvider.of<BankBloc>(context)
                              .add(DeleteEntry(currentLocation));
                        }
                      });
                })
      ],
    );
  }
}
