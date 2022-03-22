import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:weizmann_theory_app_test/blocs/progression_handler_bloc.dart';
import 'package:weizmann_theory_app_test/blocs/substitution_handler/substitution_handler_bloc.dart';
import 'package:weizmann_theory_app_test/screens/progression_screen/progression_screen.dart';

import 'blocs/audio_player/audio_player_bloc.dart';
import 'constants.dart';

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
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const ProgressionScreen();
  }
}
