part of 'audio_player_bloc.dart';

abstract class AudioPlayerState extends Equatable {
  const AudioPlayerState();
}

class Idle extends AudioPlayerState {
  @override
  List<Object> get props => [];
}

class Playing extends AudioPlayerState {
  final bool baseControl;

  @override
  List<Object?> get props => [baseControl];

  const Playing(this.baseControl);
}

class Paused extends AudioPlayerState {
  final bool baseControl;

  @override
  List<Object?> get props => [baseControl];

  const Paused(this.baseControl);
}

class ChangedBPM extends AudioPlayerState {
  final int newBPM;

  @override
  List<Object?> get props => [newBPM];

  const ChangedBPM(this.newBPM);
}
