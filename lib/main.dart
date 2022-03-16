import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/chord_progression.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
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
  int bassAdd = 24;
  int noteAdd = 48;
  int maxMelody = 81;
  List<Player> players = [];
  static const int maxPlayers = 4;
  bool _playing = false;

  @override
  void initState() {
    BlocProvider.of<ProgressionHandlerBloc>(context)
        .add(OverrideProgression(ScaleDegreeProgression.empty(inMinor: false)));
    for (int i = 0; i < maxPlayers; i++) {
      players.add(Player(id: i, commandlineArguments: ['--no-video']));
    }
    super.initState();
  }

  void load(String asset) async {
    ByteData byte = await rootBundle.load(asset);
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
                            IconButton(
                              icon: const Icon(Icons.play_arrow_rounded),
                              iconSize: 36,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                play(
                                  progression:
                                      BlocProvider.of<ProgressionHandlerBloc>(
                                              context)
                                          .currentChords,
                                  mult: 2000,
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

  void play({
    required ChordProgression progression,
    bool arpeggio = false,
    int mult = 4000,
  }) async {
    // TODO(CRITICAL): Instead of splitting like this make an algorithm!!
    List<Progression> progressions = progression.splitToMeasures();
    for (Progression prog in progressions) {
      for (int i = 0; i < prog.length; i++) {
        if (prog[i] != null) {
          Duration duration =
              Duration(milliseconds: (prog.durations[i] * mult).toInt());
          print(prog[i]);
          if (arpeggio) {
            playChordArpeggio(
                chord: prog[i]!,
                duration: duration,
                noteLength:
                    Duration(milliseconds: ((0.125 / 2) * mult).toInt()));
          } else {
            playChord(prog[i]!);
          }
          // 2 seconds...
          await Future.delayed(duration);
        }
      }
    }
  }

  void playChord(Chord chord) async {
    List<Pitch> pitches = walk(chord);
    for (int i = 0; i < maxPlayers; i++) {
      try {
        players[i].open(Media.asset(pitchFileName(pitches[i])));
        players[i].play();
      } catch (e) {
        print('Faild to play ${pitches[i]} from $chord');
        rethrow;
      }
    }
  }

  void playChordArpeggio({
    required Chord chord,
    required Duration duration,
    required Duration noteLength,
  }) async {
    int times = duration.inMilliseconds ~/ noteLength.inMilliseconds;
    List<Pitch> pitches = walk(chord);
    for (int i = 0; i < times; i++) {
      // _flutterMidi.playMidiNote(midi: pitches[i % pitches.length].midiNumber);
      try {
        players[i].open(Media.asset(pitchFileName(pitches[i % maxPlayers])));
        players[i].play();
        await Future.delayed(noteLength);
      } catch (e) {
        print('Faild to play ${pitches[i]} from $chord');
        rethrow;
      }
    }
  }

  // TODO: Actually implement this...
  List<Pitch> walk(Chord chord, [Chord? next]) {
    List<Pitch> prev = chord.pitches;
    List<Pitch> pitches = [
      Pitch.fromMidiNumber(prev.first.midiNumber + bassAdd)
    ];
    for (int i = 0; i < prev.length; i++) {
      int note = prev[i].midiNumber;
      int diff = noteAdd ~/ 12;
      if (note + noteAdd > maxMelody) {
        diff = ((note + noteAdd - maxMelody) / 12).floor();
      }
      pitches.add(Pitch.fromMidiNumber(note + (diff * 12)));
    }
    return pitches;
  }

  String pitchFileName(Pitch pitch) =>
      r'C:\Users\ew0nd\StudioProjects\weizmann_theory_app_test\assets\piano-mp3\'
      '${fileAcceptable(pitch)}.mp3';

  Pitch fileAcceptable(Pitch pitch) {
    if (pitch.accidentalSemitones > 0) {
      return Pitch.parse(
          (pitch.pitchClass + Interval.m2).toPitch().toString()[0] +
              'b${pitch.octave - 1}');
    }
    return pitch;
  }
}
