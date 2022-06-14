import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/state/progression_bank.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../../Constants.dart';
import '../../../blocs/bank/bank_bloc.dart';
import '../../../utilities.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/dialogs.dart';
import 'library_entry.dart';

class PackageView extends StatefulWidget {
  const PackageView({
    Key? key,
    required this.package,
    required this.titles,
    required this.searching,
    required this.hasSelected,
    required this.onOpen,
    required this.onTicked,
    required this.onTickedAll,
  }) : super(key: key);

  final String package;
  final Map<String, bool> titles;
  final bool searching;
  final bool? hasSelected;
  final void Function(EntryLocation location) onOpen;
  final void Function(String, bool) onTicked;
  final void Function(bool?) onTickedAll;
  static const double dividerHeight = 8.0;

  @override
  State<PackageView> createState() => _PackageViewState();
}

class _PackageViewState extends State<PackageView> {
  late final ExpandableController _controller;
  late bool _builtIn;
  late bool _expanded;
  bool _hovered = false;

  @override
  void initState() {
    _builtIn = widget.package == ProgressionBank.builtInPackageName;
    // We expand if we have titles selected or if we have titles and are not
    // the built-in package...
    _expanded = widget.titles.values.any((element) => element) ||
        (widget.titles.isNotEmpty && !_builtIn);
    _controller = ExpandableController(initialExpanded: _expanded);
    _controller.addListener(() {
      if (_controller.expanded != _expanded) {
        setState(() {
          _expanded = _controller.expanded;
        });
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PackageView oldWidget) {
    setState(() {
      _builtIn = widget.package == ProgressionBank.builtInPackageName;
      if (widget.searching) {
        _controller.value = true;
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      header: GestureDetector(
        onTap: () => _controller.value = !_expanded,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (event) => setState(() => _hovered = true),
          onExit: (event) => setState(() => _hovered = false),
          child: ColoredBox(
            color: Theme.of(context).canvasColor,
            child: Padding(
              padding: const EdgeInsets.only(top: PackageView.dividerHeight),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: _hovered
                    ? const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0)
                    : EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: _hovered
                      ? Constants.rangeSelectColor
                      : Theme.of(context).canvasColor,
                  borderRadius: _hovered
                      ? (_expanded
                          ? const BorderRadius.vertical(
                              top: Radius.circular(5.0))
                          : BorderRadius.circular(5.0))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text.rich(
                                  TextSpan(
                                    text: widget.package,
                                    style: const TextStyle(fontSize: 18.0),
                                    children: [
                                      if (_builtIn)
                                        const WidgetSpan(
                                          alignment: PlaceholderAlignment
                                              .aboveBaseline,
                                          baseline: TextBaseline.ideographic,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 4.0, bottom: 1.5),
                                            child: Icon(Constants.builtInIcon,
                                                size: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                '${widget.titles.length}',
                                style: const TextStyle(fontSize: 12.0),
                              ),
                              const SizedBox(width: 3.0),
                              Icon(
                                  _expanded
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  size: 14),
                            ],
                          ),
                        ),
                        if (widget.hasSelected == null ||
                            widget.hasSelected! ||
                            _hovered ||
                            _expanded)
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Row(
                              children: [
                                if (widget.titles.isNotEmpty)
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxHeight: 10),
                                    child: Checkbox(
                                      value: widget.hasSelected,
                                      tristate: true,
                                      onChanged: (ticked) => setState(
                                          () => widget.onTickedAll(ticked)),
                                    ),
                                  ),
                                CustomButton(
                                  label: null,
                                  iconData: Icons.add_rounded,
                                  tight: true,
                                  iconSize: 17.0,
                                  onPressed: () =>
                                      Utilities.createNewEntryDialog(
                                    context,
                                    package: widget.package,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                CustomButton(
                                  label: null,
                                  iconData: widget.hasSelected != false
                                      ? Icons.delete_sweep_rounded
                                      : Icons.folder_delete_rounded,
                                  iconSize: 22.0,
                                  tight: true,
                                  onPressed: () => _handleDelete(
                                    context: context,
                                    deletePackage: widget.hasSelected == false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (_expanded && !_hovered)
                      Divider(
                        height: 1.0,
                        thickness: 1.0,
                        color: Colors.grey[300]!,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      content: _PackageViewContent(
        controller: _controller,
        package: widget.package,
        titles: widget.titles,
        onOpen: widget.onOpen,
        onTicked: (title, ticked) => widget.onTicked(title, ticked),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDelete({
    required BuildContext context,
    required bool deletePackage,
  }) async {
    bool? delete = await showGeneralDialog<bool>(
      context: context,
      barrierLabel: 'Delete Package',
      barrierDismissible: true,
      pageBuilder: (context, _, __) => GeneralDialogChoice(
        title: Text.rich(
          TextSpan(
            text: deletePackage
                ? 'Permanently delete\n"'
                : 'Permanently delete selected entries from\n"',
            style: Constants.valuePatternTextStyle,
            children: [
              TextSpan(
                text: widget.package,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '"?'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        onPressed: (choice) => Navigator.pop(context, choice),
      ),
    );
    late List<EntryLocation> locations;
    if (delete != null) {
      locations = [
        for (String title in widget.titles.keys)
          if (deletePackage || widget.titles[title]!)
            EntryLocation(widget.package, title)
      ];
    }
    if (widget.titles.isNotEmpty && delete == true && deletePackage) {
      String? newPackage = await showGeneralDialog<String>(
        context: context,
        barrierLabel: 'Move Entries',
        barrierDismissible: true,
        pageBuilder: (context, _, __) => PackageChooserDialog(
          packages: [widget.package],
          submitButtonName:
              deletePackage ? 'Delete All Instead' : 'Delete Instead',
          submitButtonIcon: Icons.delete_rounded,
          differentSubmit: () => Navigator.pop(context, ''),
          beforePackageName: deletePackage
              ? 'Move all entries from '
              : 'Move selected entries from ',
          alreadyInPackageError: 'Your entries are already in ',
        ),
      );
      if (newPackage == null) {
        delete = false;
      } else if (newPackage.isNotEmpty) {
        BlocProvider.of<BankBloc>(context).add(MoveEntries(
          currentLocations: locations,
          newPackage: newPackage,
        ));
      }
    }
    if (delete == true) {
      if (deletePackage) {
        BlocProvider.of<BankBloc>(context)
            .add(DeletePackage(package: widget.package));
      } else {
        BlocProvider.of<BankBloc>(context).add(DeleteEntries(locations));
      }
    }
  }
}

class _PackageViewContent extends StatelessWidget {
  const _PackageViewContent({
    Key? key,
    required this.package,
    required this.titles,
    required this.controller,
    required this.onOpen,
    required this.onTicked,
  }) : super(key: key);

  final String package;
  final Map<String, bool> titles;
  final ExpandableController controller;
  final void Function(EntryLocation) onOpen;
  final void Function(String, bool) onTicked;

  @override
  Widget build(BuildContext context) {
    return ExpandablePanel(
      controller: controller,
      theme: const ExpandableThemeData(hasIcon: false, useInkWell: false),
      collapsed: const SizedBox(),
      expanded: Column(
        children: [
          titles.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "No Progressions In Package.",
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                )
              : GridView.builder(
                  itemCount: titles.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 0.5),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: Constants.libraryEntryWidth * 1.25,
                      childAspectRatio: Constants.libraryEntryWidth /
                          Constants.libraryEntryHeight,
                      crossAxisSpacing: Constants.libraryEntryWidth * 0.1,
                      mainAxisSpacing: Constants.libraryEntryHeight * 0.8),
                  itemBuilder: (context, index) {
                    index = titles.length - index - 1;
                    String currentTitle = titles.keys.elementAt(index);
                    EntryLocation currentLocation =
                        EntryLocation(package, currentTitle);
                    return LibraryEntry(
                        title: currentTitle,
                        builtIn: ProgressionBank.isBuiltIn(currentLocation),
                        ticked: titles.values.elementAt(index),
                        onTick: (ticked) => onTicked(currentTitle, ticked),
                        onOpen: () => onOpen(currentLocation),
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
                                .add(DeleteEntries([currentLocation]));
                          }
                        });
                  })
        ],
      ),
    );
  }
}
