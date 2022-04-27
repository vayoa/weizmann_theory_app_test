import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:weizmann_theory_app_test/constants.dart';
import 'package:weizmann_theory_app_test/screens/library_screen/widgets/library_entry.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/progression_screen.dart';
import 'package:weizmann_theory_app_test/widgets/TButton.dart';

import '../../blocs/bank/bank_bloc.dart';
import '../../widgets/dialogs.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
            child: SizedBox(
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text("Library", style: Constants.titleTextStyle),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: TButton(
                          label: 'Create New',
                          iconData: Icons.add,
                          tight: true,
                          onPressed: () async {
                            String? _title = await showGeneralDialog<String>(
                              context: context,
                              barrierLabel: 'Create New',
                              barrierDismissible: true,
                              pageBuilder: (context, _, __) =>
                                  GeneralDialogTextField(
                                title: const Text(
                                  'Create a new entry named...',
                                  style: Constants.valuePatternTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                                submitButtonName: 'Create',
                                onCancelled: (text) => Navigator.pop(context),
                                onSubmitted: (text) {
                                  /* TODO: Choose what characters are illegal in a title
                                  and block them here. */
                                  if (ProgressionBank.bank.containsKey(text)) {
                                    return 'Title already exists in bank.';
                                  } else {
                                    Navigator.pop(context, text);
                                    return null;
                                  }
                                },
                              ),
                            );
                            if (_title != null) {
                              BlocProvider.of<BankBloc>(context)
                                  .add(AddNewEntry(_title));
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: TButton(
                          label: 'Revert All',
                          iconData: Icons.restart_alt_rounded,
                          tight: true,
                          onPressed: () async {
                            bool? _result = await showGeneralDialog<bool>(
                              context: context,
                              barrierLabel: 'Revert All',
                              barrierDismissible: true,
                              pageBuilder: (context, _, __) =>
                                  GeneralDialogChoice(
                                title: const Text.rich(
                                  TextSpan(
                                    text: 'Permanently ',
                                    children: [
                                      TextSpan(
                                        text: 'revert all added data?',
                                        style: Constants
                                            .boldedValuePatternTextStyle,
                                      ),
                                      TextSpan(
                                          text:
                                              '\n(delete everything and revert to the '
                                              'built-in bank)'),
                                    ],
                                  ),
                                  style: Constants.valuePatternTextStyle,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                                onPressed: (choice) =>
                                    Navigator.pop(context, choice),
                                yesButtonName: 'REVERT',
                                noButtonName: 'Cancel',
                              ),
                            );

                            // Again, done in this weird way since it can be null...
                            if (_result == true) {
                              _result = await showGeneralDialog<bool>(
                                context: context,
                                pageBuilder: (context, _, __) =>
                                    GeneralDialogChoice(
                                  title: const Text(
                                    'Are you sure?',
                                    style:
                                        Constants.boldedValuePatternTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: (choice) =>
                                      Navigator.pop(context, choice),
                                  yesButtonName: 'REVERT',
                                  noButtonName: 'Cancel',
                                ),
                              );
                              if (_result!) {
                                BlocProvider.of<BankBloc>(context)
                                    .add(const RevertAll());
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1, height: 1, indent: 30.0, endIndent: 30.0),
          Expanded(
            child: BlocConsumer<BankBloc, BankState>(
              listenWhen: (previous, state) => state is AddedNewEntry,
              listener: (context, state) {
                if (state is AddedNewEntry) {
                  _pushProgressionPage(context, state.addedEntryTitle);
                }
              },
              buildWhen: (previous, state) => state is! RenamedEntry,
              builder: (context, state) {
                if (state is! BankLoading && state is! BankInitial) {
                  return Scrollbar(
                    child: GridView.builder(
                        itemCount: state.titles.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 30.0),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent:
                                    Constants.libraryEntryWidth * 1.1,
                                childAspectRatio: Constants.libraryEntryWidth /
                                    Constants.libraryEntryHeight,
                                crossAxisSpacing:
                                    Constants.libraryEntryWidth * 0.1,
                                mainAxisSpacing:
                                    Constants.libraryEntryHeight * 0.8),
                        itemBuilder: (context, index) {
                          String currentTitle =
                              state.titles[state.titles.length - index - 1];
                          return LibraryEntry(
                              title: currentTitle,
                              onOpen: () =>
                                  _pushProgressionPage(context, currentTitle),
                              onDelete: () async {
                                final bool? _result =
                                    await showGeneralDialog<bool>(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel: 'Details',
                                  pageBuilder: (context, _, __) =>
                                      GeneralDialogChoice(
                                    title: Text.rich(
                                      TextSpan(
                                        text:
                                            'Are you sure you want to permanently '
                                            'delete "',
                                        children: [
                                          TextSpan(
                                            text: currentTitle,
                                            style: Constants
                                                .boldedValuePatternTextStyle,
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
                                      .add(DeleteEntry(currentTitle));
                                }
                              });
                        }),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pushProgressionPage(
      BuildContext context, String currentTitle) async {
    BankBloc bloc = BlocProvider.of<BankBloc>(context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressionScreen(
          bankBloc: bloc,
          title: currentTitle,
          initiallyBanked:
              ProgressionBank.bank[currentTitle]!.usedInSubstitutions,
          entry: ProgressionBank.bank[currentTitle]!,
          builtIn: ProgressionBank.bank[currentTitle]!.builtIn,
        ),
      ),
    );
    bloc.add(const SaveToJson());
  }
}
