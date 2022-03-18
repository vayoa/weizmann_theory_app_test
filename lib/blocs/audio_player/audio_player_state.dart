part of 'audio_player_bloc.dart';

abstract class AudioPlayerState extends Equatable {
  const AudioPlayerState();
}

class Idle extends AudioPlayerState {
  @override
  List<Object> get props => [];
}

class Playing extends AudioPlayerState {
  @override
  List<Object?> get props => [];
}

class Paused extends AudioPlayerState {
  @override
  List<Object?> get props => [];
}
