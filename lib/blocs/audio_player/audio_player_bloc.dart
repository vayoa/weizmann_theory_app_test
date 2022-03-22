import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:equatable/equatable.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:tonic/tonic.dart';

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  static const maxPlayers = 4;
  final List<Player> _players = [];
  static const int defaultBassOctave = 2;
  static const int defaultBassOctaves = defaultBassOctave * 12;
  static const int defaultNoteOctave = 4;
  static const int defaultNoteOctaves = defaultNoteOctave * 12;
  static const int maxMelody = 81;
  bool _playing = false;
  List<Progression<Chord>>? _currentMeasures;

  // Current measure.
  int _cM = 0;

  int get currentMeasure => _cM;

  // Current chord in the current measure.
  int _cC = 0;

  int get currentChord => _cC;

  AudioPlayerBloc() : super(Idle()) {
    for (int i = 0; i < maxPlayers; i++) {
      _players.add(Player(id: i, commandlineArguments: ['--no-video']));
    }
    on<Play>((event, emit) async {
      _playing = true;
      if (_currentMeasures == null) {
        _currentMeasures = event.measures;
        _cM = 0;
        _cC = 0;
      }
      emit(Playing());
      await _play(emit: emit);
      if (_playing) {
        add(const Reset());
      }
    });
    on<PlayChord>((event, emit) {
      _playing = true;
      emit(Playing());
      _playChord(event.chord);
      if (_playing) {
        _playing = false;
        emit(Idle());
      }
    });
    on<Pause>((event, emit) {
      _playing = false;
      emit(Paused());
      // TODO: Implement this.
    });
    on<Reset>((event, emit) {
      _playing = false;
      _currentMeasures = null;
      _cM = 0;
      _cC = 0;
      emit(Idle());
    });
  }

  // TODO: Load the first chord before the rest.
  Future<void> _play({
    required Emitter<AudioPlayerState> emit,
    bool arpeggio = false,
    int mult = 6000,
  }) async {
    if (_currentMeasures != null) {
      List<Pitch>? prevPitches;
      for (_cM;
          _currentMeasures != null && _cM < _currentMeasures!.length;
          _cM++) {
        Progression<Chord> prog = _currentMeasures![_cM];
        for (_cC;
            _currentMeasures != null && _cC < _currentMeasures![_cM].length;
            _cC++) {
          if (_playing) {
            Duration duration =
                Duration(milliseconds: (prog.durations[_cC] * mult).toInt());
            if (prog[_cC] != null) {
              print(prog[_cC]);
              if (arpeggio) {
                _playChordArpeggio(
                    chord: prog[_cC]!,
                    duration: duration,
                    noteLength:
                        Duration(milliseconds: ((0.125 / 2) * mult).toInt()));
              } else {
                prevPitches = _playChord(prog[_cC]!, prevPitches);
              }
            }
            await Future.delayed(duration);
          } else {
            return;
          }
        }
        _cC = 0;
      }
    }
  }

  List<Pitch> _playChord(Chord chord, [List<Pitch>? prev]) {
    List<Pitch> pitches = _walk(chord, prev);
    for (int i = 0; i < maxPlayers; i++) {
      try {
        _players[i].open(Media.asset(pitchFileName(pitches[i])));
      } catch (e) {
        print('Faild to play ${pitches[i]} from $chord');
        rethrow;
      }
    }
    return pitches;
  }

  void _playChordArpeggio({
    required Chord chord,
    required Duration duration,
    required Duration noteLength,
  }) async {
    int times = duration.inMilliseconds ~/ noteLength.inMilliseconds;
    List<Pitch> pitches = _walk(chord);
    for (int i = 0; i < times; i++) {
      try {
        _players[i].open(Media.asset(pitchFileName(pitches[i % maxPlayers])));
        _players[i].play();
        await Future.delayed(noteLength);
      } catch (e) {
        print('Faild to play ${pitches[i]} from $chord');
        rethrow;
      }
    }
  }

  // TODO: Actually implement this...
  List<Pitch> _walk(Chord chord, [List<Pitch>? previous]) {
    List<Pitch> cPitches = chord.pitches;
    List<Pitch> pitches = [
      /* TODO: Since the chord could be in any pitch find a consistent way of
                calculating it's pitch. */
      Pitch.fromMidiNumber(cPitches.first.midiNumber + defaultBassOctaves)
    ];
    previous?.removeAt(0);
    for (int i = cPitches.length == 3 ? 0 : 1; i < cPitches.length; i++) {
      int note = cPitches[i].midiNumber;
      // in default we add noteAdd octaves...
      int add = defaultNoteOctaves;
      if (previous != null) {
        int closest = searchClosestPitch(previous, cPitches[i]);
        int octaveDiff =
            ((previous[closest].midiNumber ~/ 12) - (note ~/ 12)).abs();
        add = 12 * octaveDiff;
        // TODO: Find a better way other then removing...
        previous.removeAt(closest);
      }
      note = note + add;
      if (note > maxMelody) {
        int octaveDiff = (note / 12).ceil();
        int maxOctave = maxMelody ~/ 12;
        note -= 12 * (octaveDiff - maxOctave);
      }
      pitches.add(Pitch.fromMidiNumber(note));
    }
    print(pitches);
    return pitches;
  }

  // TODO: Took it from stack overflow...
  static int searchClosestPitch(List<Pitch> values, Pitch value) {
    int valueM = value.midiNumber % 12;
    if (valueM < values[0].midiNumber % 12) {
      return 0;
    }
    if (valueM > values[values.length - 1].midiNumber % 12) {
      return values.length - 1;
    }
    int low = 0, high = values.length - 1;
    while (low <= high) {
      int mid = (high + low) ~/ 2;
      int midM = values[mid].midiNumber % 12;
      if (valueM < midM) {
        high = mid - 1;
      } else if (valueM > midM) {
        low = mid + 1;
      } else {
        return mid;
      }
    }
    return ((values[low].midiNumber % 12) - valueM) <
            (valueM - (values[high].midiNumber % 12))
        ? low
        : high;
  }

  String pitchFileName(Pitch pitch) =>
      r'C:\Users\ew0nd\StudioProjects\weizmann_theory_app_test\assets\piano-mp3\'
      '${fileAcceptable(pitch).toString().replaceFirst('♭', 'b')}.mp3';

  Pitch fileAcceptable(Pitch pitch) {
    if (pitch.accidentalSemitones > 0) {
      return Pitch.parse(
          (pitch.pitchClass + Interval.m2).toPitch().toString()[0] +
              'b${pitch.octave - 1}');
    }
    return pitch;
  }
}
