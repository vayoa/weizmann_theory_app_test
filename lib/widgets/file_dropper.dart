import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:weizmann_theory_app_test/utilities.dart';

import '../Constants.dart';
import 'custom_button.dart';

class FileDropper extends StatefulWidget {
  const FileDropper({
    Key? key,
    required this.onUrlsDropped,
    this.boxDecoration,
    this.allowedExtensions = const ['json'],
    this.hideWhenNotValid = true,
    this.showFilePickButton = false,
  }) : super(key: key);

  final void Function(List<String>) onUrlsDropped;
  final List<String> allowedExtensions;
  final BoxDecoration? boxDecoration;
  final bool hideWhenNotValid;
  final bool showFilePickButton;

  @override
  State<FileDropper> createState() => _FileDropperState();
}

class _FileDropperState extends State<FileDropper> {
  bool _dragging = false;
  bool? _valid;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    // TODO: When there's a dialog on screen, this still receives drops...
    return DropTarget(
      onDragEntered: (detail) => _onDragEntered(),
      onDragExited: (detail) => _onDragExited(),
      onDragDone: (details) => setState(() {
        _setValid(details);
        if (_valid != null && _valid!) {
          widget.onUrlsDropped(details.files.map((file) => file.path).toList());
        }
        if (widget.hideWhenNotValid) {
          _valid = null;
        }
      }),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: !(!widget.hideWhenNotValid || _dragging || _loading)
            ? const SizedBox.expand()
            : Container(
                constraints: const BoxConstraints.expand(),
                decoration: widget.boxDecoration ??
                    BoxDecoration(
                      color: Constants.rangeSelectTransparentColor,
                      border: Border.all(width: 0.5, color: Colors.black12),
                      borderRadius:
                          BorderRadius.circular(Constants.borderRadius),
                    ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_valid == null) ...[
                      const Icon(Icons.upload_file_rounded),
                      const SizedBox(height: 10.0),
                      if (!_dragging)
                        const Text('Drop .json package files here!'),
                    ],
                    if (_valid != null && !_valid!)
                      const Text('Can only import .json package files.'),
                    if ((_dragging && _valid == null) ||
                        (_valid != null && _valid!))
                      AnimatedTextKit(
                        isRepeatingAnimation: true,
                        repeatForever: true,
                        pause: Duration.zero,
                        animatedTexts: [
                          if (_dragging && _valid == null)
                            ColorizeAnimatedText(
                              'Drop .json package files here!',
                              colors: [
                                Colors.black,
                                Colors.blue,
                                Colors.black,
                              ],
                              textStyle: const TextStyle(fontSize: 14.0),
                            ),
                          if (_valid != null && _valid!)
                            ColorizeAnimatedText(
                              'Importing package...',
                              colors: [
                                Colors.black,
                                Colors.blue,
                                Colors.black,
                              ],
                              textStyle: const TextStyle(fontSize: 14.0),
                            ),
                        ],
                      ),
                    if (widget.showFilePickButton) const SizedBox(height: 10),
                    if (widget.showFilePickButton)
                      CustomButton(
                        label: 'Choose Files',
                        iconData: Icons.upload_rounded,
                        tight: true,
                        onPressed: () => _pickFiles(),
                      )
                  ],
                ),
              ),
      ),
    );
  }

  void _onDragExited() => setState(() => _dragging = false);

  void _onDragEntered() => setState(() => _dragging = true);

  _setValid(DropDoneDetails details) {
    _valid = details.files.every(
        (file) => widget.allowedExtensions.contains(file.name.split('.').last));
    if (!_valid!) {
      var str = widget.allowedExtensions.toString();
      Utilities.showSnackBar(context,
          "Invalid import, make sure all entries are of type: ${str.substring(1, str.length - 1)}.");
    }
  }

  _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: widget.allowedExtensions,
    );
    if (result == null) return;
    widget.onUrlsDropped(result.files.map((file) => file.path!).toList());
  }
}
