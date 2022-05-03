import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:weizmann_theory_app_test/constants.dart';
import 'package:weizmann_theory_app_test/screens/library_screen/widgets/library_entry.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/progression_screen.dart';
import 'package:weizmann_theory_app_test/widgets/TButton.dart';
import 'package:window_manager/window_manager.dart';

import '../../blocs/bank/bank_bloc.dart';
import '../../widgets/dialogs.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with WindowListener {
  List<String> titles = const [];
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    windowManager.addListener(this);
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }

  void _init() async {
    // Overrides the default close handler
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      final bool? r = await showDialog<bool>(
        context: context,
        builder: (_) => GeneralThreeChoiceDialog(
          title: const Text(
            'Save before closing?',
            style: Constants.valuePatternTextStyle,
          ),
          yesButtonLabel: 'Save & Quit',
          yesButtonIconData: Constants.saveIcon,
          noButtonLabel: 'Quit',
          cancelButtonLabel: 'Back',
          onPressed: (choice) => Navigator.pop(context, choice),
        ),
      );
      if (r != null) {
        if (r) {
          BlocProvider.of<BankBloc>(context).add(const SaveAndCloseWindow());
        } else {
          await windowManager.destroy();
        }
      }
    }
  }

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
                  Row(
                    children: [
                      const Text("Library", style: Constants.titleTextStyle),
                      const SizedBox(width: 8.0),
                      SizedBox(
                        width: 270,
                        child: TextField(
                          controller: _controller,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 13),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                                Constants.maxTitleCharacters)
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search, size: 12),
                            prefixStyle: TextStyle(fontSize: 12),
                            prefixIconConstraints: BoxConstraints(
                                minWidth: 18,
                                maxWidth: 18,
                                minHeight: 7,
                                maxHeight: 7),
                            hintText: 'Search...',
                          ),
                          onChanged: (text) {
                            List<String> _realTitles =
                                BlocProvider.of<BankBloc>(context).titles;
                            if (text.isEmpty) {
                              setState(() {
                                titles = _realTitles;
                              });
                            } else {
                              setState(() {
                                titles = _realTitles
                                    .where((String title) => title
                                        .toLowerCase()
                                        .contains(text.toLowerCase()))
                                    .toList();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
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
                                autoFocus: true,
                                submitButtonName: 'Create',
                                onCancelled: (text) => Navigator.pop(context),
                                onSubmitted: (text) {
                                  /* TODO: Choose what characters are illegal in a title
                                            and block them here. */
                                  if (text.isEmpty ||
                                      RegExp(r'^\s*$').hasMatch(text)) {
                                    return "Entry titles can't be empty.";
                                  } else if (ProgressionBank.bank
                                      .containsKey(text)) {
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
                                    widthFactor: 0.45,
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
                                  widthFactor: 0.3,
                                  heightFactor: 0.15,
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
              listenWhen: (previous, state) =>
                  state is! BankLoading && state is! BankInitial,
              listener: (context, state) async {
                if (state is ClosingWindow) {
                  await windowManager.destroy();
                }
                if (state is AddedNewEntry) {
                  _pushProgressionPage(context, state.addedEntryTitle);
                }
                setState(() {
                  _controller.text = '';
                  titles = state.titles;
                });
              },
              buildWhen: (previous, state) => state is! RenamedEntry,
              builder: (context, state) {
                if (titles.isEmpty) {
                  return const FractionallySizedBox(
                    heightFactor: 0.5,
                    child: Text(
                      "No Matching Titles Found.",
                      style: Constants.valuePatternTextStyle,
                    ),
                  );
                } else if (state is! BankLoading &&
                    state is! BankInitial &&
                    state is! ClosingWindow) {
                  return Scrollbar(
                    child: GridView.builder(
                        itemCount: titles.length,
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
                              titles[titles.length - index - 1];
                          return LibraryEntry(
                              title: currentTitle,
                              builtIn:
                                  ProgressionBank.bank[currentTitle]!.builtIn,
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
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text(
                        'Loading...',
                        style: Constants.valuePatternTextStyle,
                      ),
                    ],
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
