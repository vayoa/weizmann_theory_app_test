import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../blocs/update/update_cubit.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/dialogs.dart';

class UpdateButton extends StatelessWidget {
  const UpdateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateCubit, UpdateState>(
      builder: (context, state) {
        return CustomButton(
          iconData: Icons.update_rounded,
          label: null,
          tight: true,
          color: state is UpdateAvailable
              ? state.update.beta
                  ? Colors.orange
                  : Colors.lightBlue
              : null,
          onPressed: state is UpdateLoading
              ? null
              : () => showGeneralDialog(
                    context: context,
                    barrierLabel: 'update-dialog',
                    barrierDismissible: true,
                    pageBuilder: (_, __, ___) => buildDialog(context),
                  ),
        );
      },
    );
  }

  BlocProvider<UpdateCubit> buildDialog(BuildContext context) =>
      BlocProvider.value(
        value: BlocProvider.of<UpdateCubit>(context),
        child: GeneralDialog(
          heightFactor: 0.35,
          child: BlocBuilder<UpdateCubit, UpdateState>(
            builder: (context, state) {
              final hasUpdate = state is UpdateAvailable;
              var inBeta;
              var color = Colors.black;
              if (hasUpdate) {
                inBeta = state.update.beta;
                color = state.update.beta ? Colors.orange : Colors.lightBlue;
              }
              return Column(
                children: [
                  Text(
                    "Weizmann Theory App ${state.version}.",
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasUpdate)
                    Text(
                      'A new ${inBeta ? 'beta' : ''} update is '
                      'available: ${state.update}.',
                      style: TextStyle(color: color),
                    ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: SingleChildScrollView(
                        child: hasUpdate
                            ? MarkdownBody(
                                data: '**Release Notes**:\n\n'
                                    '${state.update.releaseNotes}',
                              )
                            : const Text('No updates are available.')),
                  ),
                  const SizedBox(height: 8.0),
                  _BottomSection(
                    state: state,
                    color: color,
                  ),
                  const SizedBox(height: 12.0),
                ],
              );
            },
          ),
        ),
      );
}

class _BottomSection extends StatelessWidget {
  final UpdateState state;
  final Color color;

  const _BottomSection({
    Key? key,
    required this.state,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Since we can't promote state, a class member...
    final state = this.state;
    if (state is UpdateAvailable) {
      if (state is StepFinished) {
        return Text.rich(
          TextSpan(
            text: state.finished,
            style: const TextStyle(fontSize: 16.0),
            children: [
              TextSpan(
                text: "\n${state.message}",
                style: const TextStyle(fontSize: 12.0),
              ),
            ],
          ),
        );
      } else if (state is StepInProgress) {
        return Column(
          children: [
            Text(state.message),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  CustomButton(
                    label: null,
                    tight: true,
                    iconData: Icons.cancel_rounded,
                    onPressed: () =>
                        BlocProvider.of<UpdateCubit>(context).cancelDownload(),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 0.0),
                        disabledThumbColor: color,
                        disabledActiveTrackColor: color,
                      ),
                      child: Slider(
                        value: state.progress,
                        onChanged: null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        return CustomButton(
          label: "Update",
          iconData: Icons.update_rounded,
          color: color,
          onPressed: () {
            BlocProvider.of<UpdateCubit>(context)
                .downloadNewVersion(state.update);
          },
        );
      }
    }
    return CustomButton(
        label: "Refresh",
        iconData: Icons.refresh_rounded,
        onPressed: () =>
            BlocProvider.of<UpdateCubit>(context).checkForUpdates());
  }
}
