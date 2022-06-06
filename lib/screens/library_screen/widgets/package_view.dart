import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:thoery_test/state/progression_bank.dart';

import '../../../Constants.dart';
import '../../../blocs/bank/bank_bloc.dart';
import '../../../widgets/dialogs.dart';
import 'library_entry.dart';

class PackageView extends StatefulWidget {
  const PackageView({
    Key? key,
    required this.package,
    required this.titles,
    required this.searching,
    required this.onOpen,
  }) : super(key: key);

  final String package;
  final List<String> titles;
  final bool searching;
  final void Function(EntryLocation location) onOpen;
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
    _expanded = widget.titles.isNotEmpty && !_builtIn;
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      header: GestureDetector(
        onTap: () => _controller.value = !_expanded,
        child: MouseRegion(
          onEnter: (event) => setState(() => _hovered = true),
          onExit: (event) => setState(() => _hovered = false),
          child: Padding(
            padding: const EdgeInsets.only(top: PackageView.dividerHeight),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: _hovered
                  ? const EdgeInsets.symmetric(vertical: 3.0)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: _hovered
                    ? Constants.buttonBackgroundColor
                    : Theme.of(context).canvasColor,
                border: _expanded
                    ? Border(
                        bottom:
                            BorderSide(color: Colors.grey[300]!, width: 1.0),
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: widget.package,
                          style: const TextStyle(fontSize: 18.0),
                          children: [
                            if (_builtIn)
                              const WidgetSpan(
                                alignment: PlaceholderAlignment.aboveBaseline,
                                baseline: TextBaseline.ideographic,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 4.0, bottom: 1.0),
                                  child: Icon(Constants.builtInIcon, size: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '  ${widget.titles.length}',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(
                            _expanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      content: ExpandablePanel(
        controller: _controller,
        theme: const ExpandableThemeData(hasIcon: false, useInkWell: false),
        collapsed: const SizedBox(),
        expanded: Column(
          children: [
            widget.titles.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "No Entries In Package.",
                        style: Constants.valuePatternTextStyle,
                      ),
                    ),
                  )
                : GridView.builder(
                    itemCount: widget.titles.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 0.5),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: Constants.libraryEntryWidth *
                                1.1,
                            childAspectRatio: Constants.libraryEntryWidth /
                                Constants.libraryEntryHeight,
                            crossAxisSpacing: Constants.libraryEntryWidth * 0.1,
                            mainAxisSpacing:
                                Constants.libraryEntryHeight * 0.8),
                    itemBuilder: (context, index) {
                      String currentTitle =
                          widget.titles[widget.titles.length - index - 1];
                      EntryLocation currentLocation =
                          EntryLocation(widget.package, currentTitle);
                      return LibraryEntry(
                          title: currentTitle,
                          builtIn: ProgressionBank.isBuiltIn(currentLocation),
                          onOpen: () => widget.onOpen(currentLocation),
                          onDelete: () async {
                            final bool? _result = await showGeneralDialog<bool>(
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
                                  .add(DeleteEntry(currentLocation));
                            }
                          });
                    })
          ],
        ),
      ),
    );
  }
}
