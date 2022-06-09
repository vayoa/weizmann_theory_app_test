import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:thoery_test/state/progression_bank_entry.dart';
import 'package:weizmann_theory_app_test/constants.dart';
import 'package:weizmann_theory_app_test/screens/library_screen/widgets/library_list.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/progression_screen.dart';
import 'package:weizmann_theory_app_test/utilities.dart';
import 'package:weizmann_theory_app_test/widgets/custom_button.dart';
import 'package:weizmann_theory_app_test/widgets/custom_dropdown_button.dart';
import 'package:window_manager/window_manager.dart';

import '../../blocs/bank/bank_bloc.dart';
import '../../widgets/dialogs.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with WindowListener {
  Map<String, Map<String, bool>> packages = const {};
  Map<String, Map<String, bool>> _realPackages = const {};
  bool _hasSelected = false;
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
                            if (text.isEmpty) {
                              setState(() {
                                packages = Map.from(_realPackages);
                              });
                            } else {
                              setState(() {
                                for (MapEntry<String, Map<String, bool>> package
                                    in _realPackages.entries) {
                                  Map<String, bool> newTitles = Map.fromEntries(
                                      package.value.keys
                                          .where((String title) => title
                                              .toLowerCase()
                                              .contains(text.toLowerCase()))
                                          .map((e) =>
                                              MapEntry(e, package.value[e]!)));
                                  if (newTitles.isNotEmpty) {
                                    packages[package.key] = newTitles;
                                  }
                                }
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
                        child: CustomDropdownButton(
                          label: 'New',
                          iconData: Icons.add_rounded,
                          tight: true,
                          options: const {
                            'Entry': Icons.add_rounded,
                            'Package': Icons.all_inbox_rounded
                          },
                          onChoice: (option) async {
                            switch (option) {
                              case 'Entry':
                                await Utilities.createNewEntryDialog(context);
                                return;
                              case 'Package':
                                await _handleNewPackage(context);
                                return;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: CustomDropdownButton(
                          label: 'Transfer',
                          iconData: Icons.checklist_rtl_rounded,
                          tight: true,
                          options: const {
                            'Move Package': Constants.moveEntryIcon,
                            'Export': Icons.download_rounded,
                          },
                          onChoice: !_hasSelected
                              ? null
                              : (option) {
                                  switch (option) {
                                    case 'Move Package':
                                      _handleMoveSelectedEntries(context);
                                      return;
                                    case 'Export':
                                      _handleExportSelectedEntries(context);
                                      return;
                                  }
                                },
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      //   child: CustomButton(
                      //     label: 'Export',
                      //     iconData: Constants.moveEntryIcon,
                      //     tight: true,
                      //     onPressed: _hasSelected
                      //         ? () => _handleExportSelectedEntries(context)
                      //         : null,
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: CustomButton(
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
                  state is ClosingWindow ||
                  (state is! BankLoading && state is! BankInitial),
              listener: (context, state) async {
                switch (state.runtimeType) {
                  case ClosingWindow:
                    await windowManager.destroy();
                    break;
                  case AddedNewEntry:
                    _pushProgressionPage(
                        context, (state as AddedNewEntry).addEntryLocation);
                    break;
                  case ImportPackagesFailed:
                    String failed = (state as ImportPackagesFailed)
                        .failedJsonFileUrls
                        .map((e) => e.split(r'\').last)
                        .toList()
                        .toString();
                    Utilities.showSnackBar(
                        context,
                        'Failed to import: '
                        '${failed.substring(1, failed.length - 1)}.');
                    break;
                  case ImportPackages:
                    String imported = (state as ImportPackages)
                        .jsonFileUrls
                        .map((e) => e.split(r'\').last)
                        .toList()
                        .toString();
                    Utilities.showSnackBar(
                        context,
                        'Imported: '
                        '${imported.substring(1, imported.length - 1)}.');
                    break;
                  case ExportedPackages:
                    var _realState = state as ExportedPackages;
                    String failed = _realState.packages.keys
                        .map((e) => e.split(r'\').last)
                        .toList()
                        .toString();
                    Utilities.showSnackBar(
                        context,
                        'Exported selected entries from: '
                        '${failed.substring(1, failed.length - 1)} '
                        'to ${_realState.directory}.');
                }
                setState(() {
                  _realPackages = _getPackages(state.titles);
                  // Clone _realPackages to not destroy it...
                  packages = Map.from(_realPackages);
                  _controller.text = '';
                });
              },
              buildWhen: (previous, state) => state is! RenamedEntry,
              builder: (context, state) {
                if (packages.isEmpty) {
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
                  return LibraryList(
                    packages: packages,
                    realPackages: _realPackages,
                    searching: _controller.text.isNotEmpty,
                    onOpen: (location) =>
                        _pushProgressionPage(context, location),
                    onTicked: () => setState(() {
                      _hasSelected = _realPackages.values
                          .any((e) => e.values.any((e2) => e2));
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

  Future<void> _handleNewPackage(BuildContext context) async {
    var _result = await showGeneralDialog(
      context: context,
      barrierLabel: 'New Package',
      barrierDismissible: true,
      pageBuilder: (context, _, __) => GeneralDialogPage(
        child: Column(
          children: [
            GeneralDialogTextField(
              title: const Text(
                'Create a new package named...',
                style: Constants.valuePatternTextStyle,
                textAlign: TextAlign.center,
              ),
              autoFocus: true,
              submitButtonName: 'Create',
              onCancelled: (text) => Navigator.pop(context),
              onSubmitted: (text) {
                text = text.trim();
                String errorText = text.length > 35 ? 'Your input' : '"$text"';
                if (text.isEmpty || RegExp(r'^\s*$').hasMatch(text)) {
                  return "Entry titles can't be empty.";
                } else if (ProgressionBank.bank.containsKey(text)) {
                  return '$errorText already exists in the library.';
                } else if (!ProgressionBank.packageNameValid(text)) {
                  return '$errorText is an invalid package name.';
                } else {
                  Navigator.pop(context, text);
                  return null;
                }
              },
            ),
            PackageFileDropDialog(
              onUrlsDropped: (urls) => Navigator.pop(context, urls),
            ),
          ],
        ),
      ),
    );
    if (_result != null) {
      if (_result is String) {
        BlocProvider.of<BankBloc>(context).add(CreatePackage(package: _result));
      } else if (_result is List<String>) {
        BlocProvider.of<BankBloc>(context)
            .add(ImportPackages(jsonFileUrls: _result));
      }
    }
  }

  void _handleSelectedPackageLocations(
      List<String> packages, List<EntryLocation> locations) {
    for (String package in _realPackages.keys) {
      bool added = false;
      for (String title in _realPackages[package]!.keys) {
        if (_realPackages[package]![title]!) {
          if (!added) {
            packages.add(package);
            added = true;
          }
          locations.add(EntryLocation(package, title));
        }
      }
    }
  }

  void _handleMoveSelectedEntries(BuildContext context) async {
    List<String> packages = [];
    List<EntryLocation> locations = [];
    _handleSelectedPackageLocations(packages, locations);

    final String? newPackage = await showGeneralDialog(
      context: context,
      barrierLabel: 'Move Selected Entries',
      barrierDismissible: true,
      pageBuilder: (context, _, __) => PackageChooserDialog(
        beforePackageName: 'Move All Selected Entries ',
        afterPackageName: 'To...',
        alreadyInPackageError: 'Your entries are already in ',
        showPackageName: false,
        packages: packages,
      ),
    );

    if (newPackage != null) {
      BlocProvider.of<BankBloc>(context).add(
        MoveEntries(
          currentLocations: locations,
          newPackage: newPackage,
        ),
      );
    }
  }

  void _handleExportSelectedEntries(BuildContext context) async {
    Map<String, List<String>> packages = {};
    for (String package in _realPackages.keys) {
      for (String title in _realPackages[package]!.keys) {
        if (_realPackages[package]![title]!) {
          if (!packages.containsKey(package)) packages[package] = [];
          packages[package]!.add(title);
        }
      }
    }

    if (packages.isNotEmpty) {
      var bloc = BlocProvider.of<BankBloc>(context);
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName:
            '${packages.length == 1 ? packages.keys.first : 'packages'}.json',
        allowedExtensions: ['.json'],
        initialDirectory: bloc.appDirectory,
      );
      if (outputFile != null) {
        print(packages);
        bloc.add(ExportPackages(packages: packages, directory: outputFile));
      }
    }
  }

  _getPackages(Map<String, List<String>> newPackages) => {
        for (var package in newPackages.entries)
          package.key: {
            for (var title in package.value)
              title: _realPackages.containsKey(package.key) &&
                      _realPackages[package.key]!.containsKey(title)
                  ? _realPackages[package.key]![title]!
                  : false
          },
      };

  Future<void> _pushProgressionPage(
      BuildContext context, EntryLocation currentLocation) async {
    final BankBloc bloc = BlocProvider.of<BankBloc>(context);
    final ProgressionBankEntry progressionBankEntry =
        ProgressionBank.getAtLocation(currentLocation)!;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProgressionScreen(
          bankBloc: bloc,
          location: currentLocation,
          entry: progressionBankEntry,
          initiallyBanked: progressionBankEntry.usedInSubstitutions,
        ),
      ),
    );
    bloc.add(const SaveToJson());
  }
}
