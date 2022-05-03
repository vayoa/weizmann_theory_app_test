part of 'substitution_handler_bloc.dart';

abstract class SubstitutionHandlerEvent extends Equatable {
  @override
  List<Object?> get props => const [];

  const SubstitutionHandlerEvent();
}

class SetupReharmonization extends SubstitutionHandlerEvent {
  final ScaleDegreeProgression progression;
  final int fromChord;
  final int toChord;
  final double startDur;
  final double endDur;

  @override
  List<Object?> get props => [progression, fromChord, toChord];

  const SetupReharmonization({
    required this.progression,
    required this.fromChord,
    required this.toChord,
    this.startDur = 0.0,
    required this.endDur,
  });
}

class SwitchSubType extends SubstitutionHandlerEvent {
  final ProgressionType progressionType;

  @override
  List<Object?> get props => [progressionType];

  const SwitchSubType(this.progressionType);
}

class ReharmonizeSubs extends SubstitutionHandlerEvent {
  final KeepHarmonicFunctionAmount? keepHarmonicFunction;

  @override
  List<Object?> get props => [keepHarmonicFunction];

  const ReharmonizeSubs({this.keepHarmonicFunction});
}

class SurpriseMeSubs extends SubstitutionHandlerEvent {
  final ChordProgression progression;
  final PitchScale scale;

  @override
  List<Object?> get props => [progression, scale];

  const SurpriseMeSubs({required this.progression, required this.scale});
}

class ClearSubstitutions extends SubstitutionHandlerEvent {}

class SetKeepHarmonicFunction extends SubstitutionHandlerEvent {
  final KeepHarmonicFunctionAmount keepHarmonicFunction;

  @override
  List<Object?> get props => [keepHarmonicFunction];

  const SetKeepHarmonicFunction(this.keepHarmonicFunction);
}
