part of 'progression_handler_bloc.dart';

abstract class ProgressionHandlerEvent extends Equatable {
  @override
  List<Object?> get props => const [];

  const ProgressionHandlerEvent();
}

class OverrideProgression extends ProgressionHandlerEvent {
  final Progression newProgression;
  final bool overrideOther;

  @override
  List<Object?> get props => [newProgression, overrideOther];

  OverrideProgression(this.newProgression, {this.overrideOther = true})
      : assert((newProgression.isEmpty ||
            newProgression[0] is Chord ||
            newProgression[0] == null ||
            newProgression is ScaleDegreeProgression));
}

class SwitchType extends ProgressionHandlerEvent {
  final ProgressionType progressionType;

  @override
  List<Object?> get props => [progressionType];

  const SwitchType(this.progressionType);
}

class CalculateScale extends ProgressionHandlerEvent {}

class ChangeScale extends ProgressionHandlerEvent {
  final PitchScale newScale;

  @override
  List<Object?> get props => [newScale];

  const ChangeScale(this.newScale);
}

class ChangeRangeDuration extends ProgressionHandlerEvent {
  final double start;
  final double end;

  @override
  List<Object?> get props => [start, end];

  const ChangeRangeDuration({required this.start, required this.end})
      : assert(start < end);
}

class DisableRange extends ProgressionHandlerEvent {
  final bool disable;

  @override
  List<Object?> get props => [disable];

  const DisableRange({required this.disable});
}

class MeasureEdited extends ProgressionHandlerEvent {
  final List<String> inputs;
  final int measureIndex;

  @override
  List<Object?> get props => [inputs];

  const MeasureEdited({required this.inputs, required this.measureIndex});
}

class ApplySubstitution extends ProgressionHandlerEvent {
  final Substitution substitution;

  @override
  List<Object?> get props => [substitution];

  const ApplySubstitution(this.substitution);
}

class Reharmonize extends ProgressionHandlerEvent {
  const Reharmonize();
}

class SurpriseMe extends ProgressionHandlerEvent {
  const SurpriseMe();
}

class ChangeTimeSignature extends ProgressionHandlerEvent {
  const ChangeTimeSignature();
}
