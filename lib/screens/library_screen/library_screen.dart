import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:weizmann_theory_app_test/constants.dart';
import 'package:weizmann_theory_app_test/screens/library_screen/widgets/library_entry.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/progression_screen.dart';
import 'package:weizmann_theory_app_test/widgets/TButton.dart';

import '../../blocs/bank/bank_bloc.dart';
import '../../widgets/general_dialog_page.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        toolbarHeight: 35.0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: TButton(
              label: 'Add New',
              iconData: Icons.add,
              tight: true,
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: TButton(
              label: 'Revert All',
              iconData: Icons.add,
              tight: true,
              onPressed: () async {
                bool? _result = await showGeneralDialog<bool>(
                  context: context,
                  barrierLabel: 'Revert All',
                  barrierDismissible: true,
                  pageBuilder: (context, _, __) => GeneralDialogChoice(
                    title: const Text.rich(
                      TextSpan(
                        text: 'Permanently ',
                        children: [
                          TextSpan(
                            text: 'revert all added data?',
                            style: Constants.boldedValuePatternTextStyle,
                          ),
                          TextSpan(
                              text: '\n(delete everything and revert to the '
                                  'built-in bank)'),
                        ],
                      ),
                      style: Constants.valuePatternTextStyle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    onPressed: (choice) => Navigator.pop(context, choice),
                    yesButtonName: 'REVERT',
                    noButtonName: 'Cancel',
                  ),
                );

                // Again, done in this weird way since it can be null...
                if (_result == true) {
                  _result = await showGeneralDialog<bool>(
                    context: context,
                    pageBuilder: (context, _, __) => GeneralDialogChoice(
                      title: const Text(
                        'Are you sure?',
                        style: Constants.boldedValuePatternTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      onPressed: (choice) => Navigator.pop(context, choice),
                      yesButtonName: 'REVERT',
                      noButtonName: 'Cancel',
                    ),
                  );
                  if (_result!) {
                    BlocProvider.of<BankBloc>(context).add(const RevertAll());
                  }
                }
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<BankBloc, BankState>(
        builder: (context, state) {
          if (state is BankLoading || state is BankInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is BankLoaded) {
            return Scrollbar(
              child: GridView.builder(
                  itemCount: state.titles.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 30.0),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: Constants.libraryEntryWidth * 1.1,
                      childAspectRatio: Constants.libraryEntryWidth /
                          Constants.libraryEntryHeight,
                      crossAxisSpacing: Constants.libraryEntryWidth * 0.1,
                      mainAxisSpacing: Constants.libraryEntryHeight * 0.8),
                  itemBuilder: (context, index) {
                    return LibraryEntry(
                        title: state.titles[index],
                        onOpen: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProgressionScreen(
                                  title: state.titles[index],
                                  initiallyBanked: ProgressionBank
                                      .bank[state.titles[index]]!
                                      .usedInSubstitutions,
                                  entry: ProgressionBank
                                      .bank[state.titles[index]]!,
                                ),
                              ),
                            ),
                        onDelete: () async {
                          final bool? _result = await showGeneralDialog<bool>(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: 'Details',
                            pageBuilder: (context, _, __) =>
                                GeneralDialogChoice(
                              title: Text.rich(
                                TextSpan(
                                  text: 'Are you sure you want to permanently '
                                      'delete "',
                                  children: [
                                    TextSpan(
                                      text: state.titles[index],
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
                                .add(DeleteEntry(state.titles[index]));
                          }
                        });
                  }),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
