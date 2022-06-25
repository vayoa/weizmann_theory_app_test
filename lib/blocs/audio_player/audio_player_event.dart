part of 'audio_player_bloc.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();
}

class Play extends AudioPlayerEvent {
  final List<Progression<PitchChord>> measures;
  final bool basePlaying;

  @override
  List<Object?> get props => [measures, basePlaying];

  const Play({required this.measures, required this.basePlaying});
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
