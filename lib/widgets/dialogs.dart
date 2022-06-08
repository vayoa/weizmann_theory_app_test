import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:weizmann_theory_app_test/widgets/text_and_icon.dart';

import '../constants.dart';
import 'custom_button.dart';

class GeneralDialog extends StatelessWidget {
  static const double defaultWidthFactor = 0.4;
  static const double defaultHeightFactor = 0.2;

  const GeneralDialog({
    Key? key,
    required this.child,
    this.widthFactor = defaultWidthFactor,
    this.heightFactor = defaultHeightFactor,
  }) : super(key: key);

  final double widthFactor;
  final double heightFactor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widthFactor * 1100,
        height: heightFactor * 750,
        child: Material(
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GeneralDialogPage extends StatelessWidget {
  const GeneralDialogPage({
    Key? key,
    this.title = '',
    required this.child,
  }) : super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GeneralDialog(
      widthFactor: 0.7,
      heightFactor: 0.8,
      child: Column(
        children: [
          Row(
            children: [
              CustomButton(
                label: 'Back',
                tight: true,
                iconData: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }
}

class GeneralDialogChoice extends StatelessWidget {
  const GeneralDialogChoice({
    Key? key,
    required this.title,
    required this.onPressed,
    this.noButtonName = 'No',
    this.yesButtonName = 'Yes',
    this.yesButtonIcon = Icons.check_rounded,
    this.widthFactor = GeneralDialog.defaultWidthFactor,
    this.heightFactor = GeneralDialog.defaultHeightFactor,
  }) : super(key: key);

  final Widget title;
  final String noButtonName;
  final String yesButtonName;
  final IconData yesButtonIcon;
  final void Function(bool) onPressed;
  final double widthFactor;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    return GeneralDialog(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          title,
          SizedBox(
            width: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  label: noButtonName,
                  iconData: Icons.close_rounded,
                  tight: true,
                  onPressed: () => onPressed(false),
                ),
                CustomButton(
                  label: yesButtonName,
                  iconData: yesButtonIcon,
                  tight: true,
                  onPressed: () => onPressed(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GeneralDialogTextField extends StatefulWidget {
  const GeneralDialogTextField({
    Key? key,
    required this.title,
    this.maxLength,
    this.options,
    this.invalidOptions,
    required this.onCancelled,
    required this.onSubmitted,
    this.cancelButtonName = 'Cancel',
    this.submitButtonName = 'Submit',
    this.submitButtonIcon = Icons.check_rounded,
    this.autoFocus = false,
    this.optionTitleBuilder,
    this.uniqueOption,
    this.differentSubmit,
  }) : super(key: key);

  final Widget title;
  final int? maxLength;
  final List<String>? options;
  final List<String>? invalidOptions;
  final String cancelButtonName;
  final String submitButtonName;
  final IconData submitButtonIcon;
  final void Function(String) onCancelled;
  final String? Function(String) onSubmitted;
  final bool autoFocus;
  final Widget Function(BuildContext, String)? optionTitleBuilder;
  final Widget? uniqueOption;
  final void Function()? differentSubmit;

  @override
  _GeneralDialogTextFieldState createState() => _GeneralDialogTextFieldState();
}

class _GeneralDialogTextFieldState extends State<GeneralDialogTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? errorMessage;
  late final bool _uniqueShown;

  @override
  void initState() {
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _uniqueShown = widget.uniqueOption != null;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GeneralDialogChoice(
      widthFactor: GeneralDialog.defaultWidthFactor + 0.05,
      heightFactor: GeneralDialog.defaultHeightFactor + 0.05,
      yesButtonIcon: widget.submitButtonIcon,
      title: Column(
        children: [
          widget.title,
          RawAutocomplete<String>(
            textEditingController: _controller,
            focusNode: _focusNode,
            onSelected: _submit,
            optionsViewBuilder: (BuildContext context,
                void Function(String) onSelected, Iterable<String> options) {
              final int highlighted = AutocompleteHighlightedOption.of(context);
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(maxHeight: 200, maxWidth: 396),
                    child: ListView.builder(
                      itemCount: options.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        late final Widget title;
                        bool unique = false;
                        if (_uniqueShown &&
                            index == options.length - 1 &&
                            !widget.options!.contains(option)) {
                          // If a unique option was given it'll always be the last.
                          title = widget.uniqueOption!;
                          unique = true;
                        } else if (widget.optionTitleBuilder != null) {
                          title =
                              widget.optionTitleBuilder!.call(context, option);
                        } else {
                          title = Text(option);
                        }
                        return InkWell(
                          onTap: () =>
                              onSelected(unique ? _controller.text : option),
                          child: ListTile(
                            title: title,
                            tileColor:
                            index == highlighted ? Colors.grey[400]! : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            optionsBuilder: (TextEditingValue textEditingValue) {
              final String text = textEditingValue.text;
              if (text == '' ||
                  widget.options == null ||
                  widget.options!.isEmpty) {
                return const Iterable<String>.empty();
              } else {
                List<String> r = widget.options!
                    .where((element) =>
                    element.toLowerCase().contains(text.toLowerCase()))
                    .toList();
                if (_uniqueShown && !(r.length == 1 && r.first == text)) {
                  r.add(text);
                }
                if (widget.invalidOptions != null) {
                  r = r
                      .where(
                          (option) => !widget.invalidOptions!.contains(option))
                      .toList();
                }
                return r;
              }
            },
            fieldViewBuilder: (context, controller, node, onSubmit) {
              return TextField(
                controller: controller,
                focusNode: node,
                autofocus: widget.autoFocus,
                maxLength: widget.maxLength,
                maxLines: 1,
                style: Constants.boldedValuePatternTextStyle,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  isDense: true,
                  constraints: const BoxConstraints(maxWidth: 396),
                  errorText: errorMessage,
                ),
                onSubmitted: (input) =>
                widget.options == null ? _submit(input) : onSubmit(),
                onChanged: (text) {
                  if (errorMessage != null) {
                    setState(() => errorMessage = null);
                  }
                },
              );
            },
          ),
        ],
      ),
      noButtonName: widget.cancelButtonName,
      yesButtonName: widget.submitButtonName,
      onPressed: (choice) {
        if (choice) {
          if (widget.differentSubmit == null) {
            _submit(_controller.text);
          } else {
            widget.differentSubmit!();
          }
        } else {
          widget.onCancelled(_controller.text);
        }
      },
    );
  }

  void _submit(String text) {
    String? error = widget.onSubmitted(text);
    if (error != null) {
      setState(() => errorMessage = error);
    } else if (errorMessage != null) {
      setState(() => errorMessage = null);
    }
  }
}

class GeneralThreeChoiceDialog extends StatelessWidget {
  const GeneralThreeChoiceDialog({
    Key? key,
    required this.title,
    required this.onPressed,
    this.yesButtonLabel = 'Yes',
    this.yesButtonIconData = Icons.check_rounded,
    this.noButtonLabel = 'No',
    this.noButtonIconData = Icons.close_rounded,
    this.cancelButtonLabel = 'Cancel',
    this.cancelButtonIconData = Constants.backIcon,
  }) : super(key: key);

  final Widget title;
  final Function(bool?) onPressed;
  final String yesButtonLabel;
  final IconData yesButtonIconData;
  final String noButtonLabel;
  final IconData noButtonIconData;
  final String cancelButtonLabel;
  final IconData cancelButtonIconData;

  @override
  Widget build(BuildContext context) {
    return GeneralDialog(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          title,
          SizedBox(
            width: 280,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  label: cancelButtonLabel,
                  iconData: cancelButtonIconData,
                  tight: true,
                  onPressed: () => onPressed(null),
                ),
                CustomButton(
                  label: noButtonLabel,
                  iconData: noButtonIconData,
                  tight: true,
                  onPressed: () => onPressed(false),
                ),
                CustomButton(
                  label: yesButtonLabel,
                  iconData: yesButtonIconData,
                  tight: true,
                  onPressed: () => onPressed(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PackageChooserDialog extends StatelessWidget {
  const PackageChooserDialog({
    Key? key,
    required this.packages,
    this.showPackageName = true,
    this.beforePackageName = 'Move Entry From ',
    this.afterPackageName = ' To ...',
    this.submitButtonName = 'Submit',
    this.alreadyInPackageError = 'Your entry is already in ',
    this.submitButtonIcon = Icons.check_rounded,
    this.differentSubmit,
  }) : super(key: key);

  final List<String> packages;
  final String beforePackageName;
  final String afterPackageName;
  final String submitButtonName;
  final IconData submitButtonIcon;
  final String alreadyInPackageError;
  final void Function()? differentSubmit;
  final bool showPackageName;

  @override
  Widget build(BuildContext context) {
    final String? package = packages.length == 1 ? packages[0] : null;
    return GeneralDialogTextField(
      title: Text.rich(
        TextSpan(text: beforePackageName, children: [
          if (showPackageName && package != null)
            TextSpan(
              text: '"$package"',
              style: Constants.boldedValuePatternTextStyle,
            ),
          TextSpan(text: afterPackageName),
        ]),
        style: Constants.valuePatternTextStyle,
        textAlign: TextAlign.center,
      ),
      submitButtonName: submitButtonName,
      submitButtonIcon: submitButtonIcon,
      differentSubmit: differentSubmit,
      options: _buildOptionsList(),
      invalidOptions: packages,
      autoFocus: true,
      uniqueOption:
      const TextAndIcon(text: 'Create New', icon: Icons.add_rounded),
      optionTitleBuilder: (context, option) {
        if (option == ProgressionBank.builtInPackageName) {
          return TextAndIcon(text: option, icon: Constants.builtInIcon);
        }
        return Text(option);
      },
      onCancelled: (_) => Navigator.pop(context),
      onSubmitted: (input) {
        if (packages.contains(input)) {
          return '$alreadyInPackageError"$input".';
        } else if (ProgressionBank.packageNameValid(input)) {
          Navigator.pop(context, input);
          return null;
        } else {
          return '"$input" is an invalid package name.';
        }
      },
    );
  }

  List<String> _buildOptionsList() {
    List<String> options = ProgressionBank.bank.keys
        .where((element) => !packages.contains(element))
        .toList();
    if (!packages.contains(ProgressionBank.builtInPackageName) &&
        !options.contains(ProgressionBank.builtInPackageName)) {
      options.add(ProgressionBank.builtInPackageName);
    }
    return options;
  }
}

class PackageFileDropDialog extends StatefulWidget {
  const PackageFileDropDialog({
    Key? key,
    required this.onUrlsDropped,
  }) : super(key: key);

  final void Function(List<String>) onUrlsDropped;

  @override
  State<PackageFileDropDialog> createState() => _PackageFileDropDialogState();
}

class _PackageFileDropDialogState extends State<PackageFileDropDialog> {
  bool _hovered = false;
  bool? _valid;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return GeneralDialog(
        child: DropTarget(
      onDragEntered: (detail) => setState(() => _hovered = true),
      onDragExited: (detail) => setState(() => _hovered = false),
      onDragDone: (details) => setState(() {
        _setValid(details);
        if (_valid != null && _valid!) {
          widget.onUrlsDropped(details.files.map((file) => file.path).toList());
        }
      }),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(Constants.borderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _valid == null
                ? const Text('Drop .json package files here!')
                : (_valid!
                    ? const Text('Importing package...')
                    : const Text('Can only import .json package files.')),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Choose Files',
              iconData: Icons.upload_rounded,
              tight: true,
              onPressed: () => _pickFiles(),
            )
          ],
        ),
      ),
    ));
  }

  _setValid(DropDoneDetails details) {
    _valid = details.files.every((file) => file.name.split('.').last == 'json');
  }

  _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['json'],
    );
    if (result == null) return;
    widget.onUrlsDropped(result.files.map((file) => file.path!).toList());
  }
}
