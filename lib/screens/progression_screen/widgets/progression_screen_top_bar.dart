import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony_theory/state/progression_bank.dart';

import '../../../Constants.dart';
import '../../../blocs/bank/bank_bloc.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/text_and_icon.dart';

class ProgressionScreenTopBar extends StatelessWidget {
  const ProgressionScreenTopBar({
    Key? key,
    required this.location,
  }) : super(key: key);

  final EntryLocation location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomButton(
          label: 'Back',
          tight: true,
          size: 12,
          iconData: Constants.backIcon,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        BlocBuilder<BankBloc, BankState>(
          builder: (context, state) {
            final bool loading = state is BankLoading;
            return CustomButton(
              label: loading ? 'Saving...' : 'Save',
              tight: true,
              size: 12,
              iconData:
                  loading ? Icons.hourglass_bottom_rounded : Constants.saveIcon,
              onPressed: loading
                  ? null
                  : () => BlocProvider.of<BankBloc>(context)
                      .add(const SaveToJson()),
            );
          },
        ),
        const SizedBox(width: 8),
        TextAndIcon(
          textBefore: 'In',
          text: location.package,
          icon: Constants.packageIcon,
          iconSize: 12,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
