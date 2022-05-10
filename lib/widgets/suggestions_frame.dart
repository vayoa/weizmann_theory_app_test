import 'package:flutter/material.dart';

import '../constants.dart';

class SuggestionFrame extends StatelessWidget {
  const SuggestionFrame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Reharmonize!'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Constants.rangeSelectColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('2-5'),
          ),
          const Icon(Icons.expand_more_rounded),
        ],
      ),
      icon: const Icon(Icons.bubble_chart),
      onPressed: () {},
    );
  }
}
