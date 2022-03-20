import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:tonic/tonic.dart';
import 'package:weizmann_theory_app_test/blocs/progression_handler_bloc.dart';
import 'package:weizmann_theory_app_test/blocs/substitution_handler/substitution_handler_bloc.dart';
import 'package:weizmann_theory_app_test/widgets/BankProgressionButton.dart';
import 'package:weizmann_theory_app_test/widgets/TButton.dart';
import 'package:weizmann_theory_app_test/widgets/reharmonize_range.dart';
import 'package:weizmann_theory_app_test/widgets/scale_chooser.dart';
import 'package:weizmann_theory_app_test/widgets/selectable_progression_view.dart';
import 'package:weizmann_theory_app_test/widgets/substitution_window.dart';
import 'package:weizmann_theory_app_test/widgets/view_type_selector.dart';

import 'Constants.dart';
import 'blocs/audio_player/audio_player_bloc.dart';

void main() {
  DartVLC.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        buttonTheme: ButtonThemeData(
          minWidth: Constants.minButtonWidth,
          height: Constants.minButtonHeight,
          padding: const EdgeInsets.all(4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.borderRadius),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Constants.buttonBackgroundColor,
            onPrimary: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.borderRadius),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.black,
            backgroundColor: Constants.buttonBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.borderRadius),
            ),
          ),
        ),
        toggleButtonsTheme: ToggleButtonsThemeData(
          constraints: const BoxConstraints(
            minHeight: Constants.minButtonHeight,
            maxHeight: Constants.minButtonHeight,
          ),
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          color: Constants.buttonUnfocusedTextColor,
          selectedColor: Colors.black,
          fillColor: Constants.selectedColor,
        ),
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SubstitutionHandlerBloc()),
          BlocProvider(
            create: (context) => ProgressionHandlerBloc(
                BlocProvider.of<SubstitutionHandlerBloc>(context)),
          ),
          BlocProvider(create: (_) => AudioPlayerBloc()),
        ],
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    BlocProvider.of<ProgressionHandlerBloc>(context)
        .add(OverrideProgression(ScaleDegreeProgression.empty(inMinor: false)));
    print('Hey');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 30.0, left: 30.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 700,
                    height: 140,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TButton(
                          label: 'Back',
                          tight: true,
                          size: 12,
                          iconData: Icons.arrow_back_ios_rounded,
                          onPressed: () {},
                        ),
                        Row(
                          children: [
                            const Text(
                              "My Song's Title",
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            BankProgressionButton(
                              onToggle: (active) {},
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                              builder: (context, state) {
                                return IconButton(
                                  icon: state is Playing
                                      ? const Icon(Icons.pause_rounded)
                                      : const Icon(Icons.play_arrow_rounded),
                                  iconSize: 36,
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    AudioPlayerBloc bloc =
                                        BlocProvider.of<AudioPlayerBloc>(
                                            context);
                                    if (state is Playing) {
                                      bloc.add(Pause());
                                    } else {
                                      List<Progression<Chord>> chords =
                                          BlocProvider.of<
                                                      ProgressionHandlerBloc>(
                                                  context)
                                              .chordMeasures;
                                      print(chords);
                                      bloc.add(Play(chords));
                                    }
                                  },
                                );
                              },
                            ),
                            const Text(
                              " 00 / 34s  BPM: 120, 4/4",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ViewTypeSelector(
                              tight: true,
                              onPressed: (newType) =>
                                  BlocProvider.of<ProgressionHandlerBloc>(
                                          context)
                                      .add(SwitchType(newType)),
                            ),
                            Row(
                              children: const [
                                Text(
                                  'Scale: ',
                                  style: TextStyle(fontSize: 18),
                                ),
                                ScaleChooser(),
                              ],
                            ),
                            TButton(
                              label: 'Reharmonize!',
                              iconData: Icons.bubble_chart_rounded,
                              onPressed: () {
                                BlocProvider.of<ProgressionHandlerBloc>(context)
                                    .add(Reharmonize());
                              },
                            ),
                            const ReharmonizeRange(),
                            TButton(
                              label: 'Surprise Me',
                              iconData: Icons.lightbulb,
                              onPressed: () =>
                                  BlocProvider.of<ProgressionHandlerBloc>(
                                          context)
                                      .add(SurpriseMe()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  BlocConsumer<ProgressionHandlerBloc, ProgressionHandlerState>(
                    listener: (context, state) {
                      if (state is InvalidInputReceived) {
                        Duration duration = const Duration(seconds: 4);
                        String message = 'An invalid value was inputted:'
                            '\n${state.exception}';
                        if (state.exception is NonValidDuration) {
                          NonValidDuration e =
                              state.exception as NonValidDuration;
                          String value = e.value is Chord
                              ? (e.value as Chord).getCommonName()
                              : e.value;
                          message = 'An invalid duration was inputted:'
                              '\nA value of $value in a duration of '
                              '${(e.duration * e.timeSignature.denominator).toInt()}'
                              '/${e.timeSignature.denominator} is not a valid '
                              'duration in a ${e.timeSignature} time signature.';
                          duration = const Duration(seconds: 12);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(message),
                            duration: duration,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      ProgressionHandlerBloc bloc =
                          BlocProvider.of<ProgressionHandlerBloc>(context);
                      return SelectableProgressionView(
                        measures: bloc.currentlyViewedMeasures,
                        fromChord: bloc.fromChord,
                        toChord: bloc.toChord,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SubstitutionWindow(),
        ],
      ),
    );
  }
}
