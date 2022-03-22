import 'package:flutter/material.dart';
import 'package:weizmann_theory_app_test/constants.dart';
import 'package:weizmann_theory_app_test/screens/library_screen/widgets/library_entry.dart';
import 'package:weizmann_theory_app_test/widgets/TButton.dart';

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
        ],
      ),
      body: Scrollbar(
        child: GridView.builder(
            itemCount: 54,
            shrinkWrap: true,
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: Constants.libraryEntryWidth * 1.1,
                childAspectRatio:
                    Constants.libraryEntryWidth / Constants.libraryEntryHeight,
                crossAxisSpacing: Constants.libraryEntryWidth * 0.2,
                mainAxisSpacing: Constants.libraryEntryHeight * 0.8),
            itemBuilder: (context, index) {
              return LibraryEntry(
                title: "My Song's Title",
                onDelete: () => showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: 'Details',
                  pageBuilder: (context, _, __) => GeneralDialogPage(
                    title: 'Delete Progression',
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                              'Are you sure you want to permanently delete "My Song\'s title?'),
                          SizedBox(
                            width: 200,
                            child: Row(
                              children: [
                                TButton(
                                  label: 'No',
                                  iconData: Icons.close,
                                  tight: true,
                                  onPressed: () {},
                                ),
                                TButton(
                                  label: 'Yes',
                                  iconData: Icons.check,
                                  tight: true,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                onOpen: () {},
              );
            }),
      ),
    );
  }
}
