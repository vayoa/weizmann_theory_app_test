part of 'audio_player_bloc.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();
}

class Play extends AudioPlayerEvent {
  final List<Progression<Chord>> measures;

  @override
  List<Object?> get props => [measures];

  const Play(this.measures);
}

class PlayChord extends AudioPlayerEvent {
  final Chord chord;

  @override
  List<Object?> get props => [chord];

  const PlayChord(this.chord);
}

class Pause extends AudioPlayerEvent {
  @override
  List<Object?> get props => [];

  const Pause();
}

class Reset extends AudioPlayerEvent {
  @override
  List<Object?> get props => [];

  const Reset();
}

class ChangeBPM extends AudioPlayerEvent {
  final int newBPM;

  @override
  List<Object?> get props => [newBPM];

  const ChangeBPM(this.newBPM);
}
