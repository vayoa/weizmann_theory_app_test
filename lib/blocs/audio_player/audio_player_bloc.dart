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
  static const int bassAdd = 24;
  static const int noteAdd = 48;
  static const int maxMelody = 81;
  bool _playing = false;
  List<Progression<Chord>>? _currentMeasures;
  int _currentMeasure = 0, _currentChord = 0;

  AudioPlayerBloc() : super(Idle()) {
    for (int i = 0; i < maxPlayers; i++) {
      _players.add(Player(id: i, commandlineArguments: ['--no-video']));
    }
    on<Play>((event, emit) async {
      _playing = true;
      if (_currentMeasures == null) {
        _currentMeasures = event.measures;
        _currentMeasure = 0;
        _currentChord = 0;
      }
      emit(Playing());
      await _play();
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
      _currentMeasure = 0;
      _currentChord = 0;
      emit(Idle());
    });
  }

  Future<void> _playPlaylist(List<Progression<Chord>> progressions) async {
    List<List<Media>> media = [[], [], [], []];
    for (Progression<Chord> prog in progressions) {
      for (int i = 0; i < prog.length; i++) {
        if (prog[i] != null) {
          List<Pitch> pitches = _walk(
            prog[i]!,
            i == prog.length - 1 ? null : prog[i + 1],
          );
          for (int j = 0; j < pitches.length; j++) {
            media[j]
                .add(Media.asset(pitchFileName(fileAcceptable(pitches[j]))));
          }
        }
      }
    }
    for (int i = 0; i < maxPlayers; i++) {
      _players[i].open(Playlist(medias: media[i]), autoStart: false);
    }
    for (int i = 0; i < maxPlayers; i++) {
      _players[i].play();
    }
  }

  Future<void> _play({
    bool arpeggio = false,
    int mult = 6000,
  }) async {
    if (_currentMeasures != null) {
      for (int m = _currentMeasure; m < _currentMeasures!.length; m++) {
        _currentMeasure = m;
        Progression<Chord> prog = _currentMeasures![m];
        for (int c = _currentChord;
            c < _currentMeasures![_currentMeasure].length;
            c++) {
          if (_playing) {
            _currentChord = c;
            Duration duration =
                Duration(milliseconds: (prog.durations[c] * mult).toInt());
            if (prog[c] != null) {
              print(prog[c]);
              if (arpeggio) {
                _playChordArpeggio(
                    chord: prog[c]!,
                    duration: duration,
                    noteLength:
                        Duration(milliseconds: ((0.125 / 2) * mult).toInt()));
              } else {
                _playChord(prog[c]!);
              }
            }
            await Future.delayed(duration);
          } else {
            return;
          }
        }
      }
    }
  }

  void _playChord(Chord chord) async {
    List<Pitch> pitches = _walk(chord);
    for (int i = 0; i < maxPlayers; i++) {
      try {
        _players[i].open(Media.asset(pitchFileName(pitches[i])));
      } catch (e) {
        print('Faild to play ${pitches[i]} from $chord');
        rethrow;
      }
    }
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
  List<Pitch> _walk(Chord chord, [Chord? next]) {
    List<Pitch> prev = chord.pitches;
    List<Pitch> pitches = [
      Pitch.fromMidiNumber(prev.first.midiNumber + bassAdd)
    ];
    for (int i = prev.length == 3 ? 0 : 1; i < prev.length; i++) {
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
