import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
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
  static const int maxMelody = 71; // B4.
  static const int minBass = 31; // G2.
  bool _baseControl = true;
  bool _playing = false;

  bool get baseControl => _baseControl;

  bool get playing => _playing;

  List<Progression<Chord>>? _currentMeasures;

  // Current measure.
  int _cM = 0;

  int get currentMeasure => _cM;

  // Current chord in the current measure.
  int _cC = 0;

  int get currentChord => _cC;

  int _bpm = 60;

  int get bpm => _bpm;
  static const int maxBPM = 70;
  static const int minBPM = 30;

  AudioPlayerBloc() : super(Idle()) {
    for (int i = 0; i < maxPlayers; i++) {
      _players.add(Player(id: i, commandlineArguments: ['--no-video']));
    }
    on<Play>((event, emit) async {
      if (_playing || event.basePlaying != _baseControl) {
        reset(emit);
      }
      _baseControl = event.basePlaying;
      _playing = true;
      if (_currentMeasures == null) {
        _currentMeasures = event.measures;
        _cM = 0;
        _cC = 0;
      }
      emit(Playing(_baseControl));
      await _play(emit: emit);
      if (playing) {
        reset(emit);
      }
    });
    on<Pause>((event, emit) {
      _playing = false;
      emit(Paused(_baseControl));
      // TODO: Implement this.
    });
    on<Reset>((event, emit) {
      reset(emit);
    });
    on<ChangeBPM>((event, emit) {
      _bpm = event.newBPM;
      emit(ChangedBPM(_bpm));
    });
  }

  @override
  Future<void> close() {
    for (Player player in _players) {
      player.dispose();
    }
    return super.close();
  }

  void reset(Emitter<AudioPlayerState> emit) {
    _playing = false;
    _baseControl = true;
    _currentMeasures = null;
    _cM = 0;
    _cC = 0;
    emit(Idle());
  }

  // TODO: Load the first chord before the rest.
  Future<void> _play({
    required Emitter<AudioPlayerState> emit,
    bool arpeggio = false,
  }) async {
    if (_currentMeasures != null) {
      double millisecondsPerBeat = (60 / _bpm) * 1000;
      double mult =
          millisecondsPerBeat * _currentMeasures![0].timeSignature.denominator;
      List<Pitch>? prevPitches;
      for (_cM;
          _currentMeasures != null && _cM < _currentMeasures!.length;
          _cM++) {
        Progression<Chord> prog = _currentMeasures![_cM];
        // First, load the first pitches.
        List<Pitch> _loadedP = _walk(prog[_cC]!);
        for (var p in _loadedP) {
          await rootBundle.load(pitchFileName(p));
        }
        for (_cC;
            _currentMeasures != null && _cC < _currentMeasures![_cM].length;
            _cC++) {
          if (playing) {
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

  Pitch getBase(Pitch pitch) {
    int note = pitch.midiNumber % 12;
    int minBassNote = minBass % 12;
    if (note < minBassNote) {
      return Pitch.fromMidiNumber(((12 - minBassNote) % 12) + minBass + note);
    }
    return Pitch.fromMidiNumber(minBass + note - minBassNote);
  }

  // TODO: Actually implement this...
  List<Pitch> _walk(Chord chord, [List<Pitch>? previous]) {
    List<Pitch> cPitches = chord.pitches;
    /* TODO: Since the chord could be in any pitch find a consistent way of
             calculating it's pitch. */
    List<Pitch> pitches = [getBase(cPitches[0])];
    previous?.removeAt(0);
    int found = -1;
    // First search for equal pitch classes...
    if (previous != null) {
      for (int i = cPitches.length == 3 ? 0 : 1;
          found == -1 && i < cPitches.length;
          i++) {
        for (int j = 0; found == -1 && j < previous.length; j++) {
          if (cPitches[i].midiNumber % 12 == previous[j].midiNumber % 12) {
            found = i;
            pitches.add(Pitch.fromMidiNumber(
                calcNote(cPitches[i].midiNumber, previous[j].midiNumber)));
            previous.removeAt(j);
          }
        }
      }
    }
    for (int i = cPitches.length == 3 ? 0 : 1; i < cPitches.length; i++) {
      if (i != found) {
        int note = cPitches[i].midiNumber;
        if (previous != null) {
          int closest = fixedClosest(previous, cPitches[i]);
          note = calcNote(note, previous[closest].midiNumber);
          // TODO: Find a better way other then removing...
          previous.removeAt(closest);
        } else {
          note = calcNote(note, maxMelody - 12);
        }
        pitches.add(Pitch.fromMidiNumber(note));
      }
    }
    print(pitches);
    return pitches;
  }

  static int calcNote(int note, int prev) {
    note += ((prev - note) / 12).abs().round() * 12;
    if (note > maxMelody) {
      int octaveDiff = (note / 12).ceil();
      int maxOctave = maxMelody ~/ 12;
      note -= 12 * (octaveDiff - maxOctave);
    }
    return note;
  }

  // TODO: Make binsearch...
  static int fixedClosest(List<Pitch> values, Pitch value) {
    int minI = 0;
    int minDiff = 12;
    int vAbsolute = value.midiNumber % 12;
    for (int i = 0; i < values.length; i++) {
      int pAbsolute = values[i].midiNumber % 12;
      int currentMinDiff = min((pAbsolute + 12 - vAbsolute).abs(),
          (pAbsolute.abs() - vAbsolute).abs());
      if (currentMinDiff < minDiff) {
        minDiff = currentMinDiff;
        minI = i;
      }
    }
    return minI;
  }

  String pitchFileName(Pitch pitch) => r'assets/piano-mp3/'
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
