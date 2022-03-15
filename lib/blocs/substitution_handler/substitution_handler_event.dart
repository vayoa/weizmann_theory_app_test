part of 'substitution_handler_bloc.dart';

abstract class SubstitutionHandlerEvent extends Equatable {
  @override
  List<Object?> get props => const [];

  const SubstitutionHandlerEvent();
}

class SwitchSubType extends SubstitutionHandlerEvent {
  final ProgressionType progressionType;

  @override
  List<Object?> get props => [progressionType];

  const SwitchSubType(this.progressionType);
}

class ReharmonizeSubs extends SubstitutionHandlerEvent {
  final ScaleDegreeProgression progression;
  final int fromChord;
  final int toChord;

  @override
  List<Object?> get props => [progression, fromChord, toChord];

  const ReharmonizeSubs(
      {required this.progression,
      required this.fromChord,
      required this.toChord});
}

class SurpriseMeSubs extends SubstitutionHandlerEvent {
  final ChordProgression progression;
  final Scale scale;

  @override
  List<Object?> get props => [progression, scale];

  const SurpriseMeSubs({required this.progression, required this.scale});
}

class ClearSubstitutions extends SubstitutionHandlerEvent {}
