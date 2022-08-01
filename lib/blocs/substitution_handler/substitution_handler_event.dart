part of 'substitution_handler_bloc.dart';

abstract class SubstitutionHandlerEvent extends Equatable {
  @override
  List<Object?> get props => const [];

  const SubstitutionHandlerEvent();
}

class OpenSetupPage extends SubstitutionHandlerEvent {
  final DegreeProgression progression;
  final int fromChord;
  final int? toChord;
  final double startDur;
  final double? endDur;
  final bool surpriseMe;

  @override
  List<Object?> get props => [progression, fromChord, toChord, surpriseMe];

  const OpenSetupPage({
    required this.progression,
    required this.surpriseMe,
    this.fromChord = 0,
    this.toChord,
    this.startDur = 0.0,
    this.endDur,
  }) : assert(surpriseMe || (toChord != null && endDur != null));
}

class SwitchSubType extends SubstitutionHandlerEvent {
  final ProgressionType progressionType;

  @override
  List<Object?> get props => [progressionType];

  const SwitchSubType(this.progressionType);
}

class CalculateSubstitutions extends SubstitutionHandlerEvent {
  final KeepHarmonicFunctionAmount keepHarmonicFunction;
  final Sound sound;

  @override
  List<Object?> get props => [keepHarmonicFunction, sound];

  const CalculateSubstitutions({
    required this.keepHarmonicFunction,
    required this.sound,
  });
}

class ClearSubstitutions extends SubstitutionHandlerEvent {
  const ClearSubstitutions();
}

class SetKeepHarmonicFunction extends SubstitutionHandlerEvent {
  final KeepHarmonicFunctionAmount keepHarmonicFunction;

  @override
  List<Object?> get props => [keepHarmonicFunction];

  const SetKeepHarmonicFunction(this.keepHarmonicFunction);
}

class UpdateShowSubstitutions extends SubstitutionHandlerEvent {
  final bool show;

  @override
  List<Object> get props => [show];

  const UpdateShowSubstitutions(this.show);
}

class ChangeSubstitutionIndex extends SubstitutionHandlerEvent {
  final int changeTo;

  @override
  List<Object?> get props => [changeTo];

  const ChangeSubstitutionIndex(this.changeTo);
}

class ChangeSubstitutionIndexInOrder extends SubstitutionHandlerEvent {
  final bool forward;

  @override
  List<Object?> get props => [forward];

  const ChangeSubstitutionIndexInOrder(this.forward);
}

class ChangeVisibility extends SubstitutionHandlerEvent {
  final bool visible;

  @override
  List<Object?> get props => [visible];

  const ChangeVisibility(this.visible);
}
