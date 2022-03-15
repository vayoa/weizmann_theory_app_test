part of 'progression_handler_bloc.dart';

abstract class ProgressionHandlerEvent extends Equatable {
  @override
  List<Object?> get props => const [];

  const ProgressionHandlerEvent();
}

class OverrideProgression extends ProgressionHandlerEvent {
  final Progression newProgression;

  @override
  List<Object?> get props => [newProgression];

  OverrideProgression(this.newProgression)
      : assert((newProgression.isEmpty || newProgression[0] is Chord ||
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
  final int index;

  @override
  List<Object?> get props => [index];

  const ChangeScale(this.index);
}

class ChangeRange extends ProgressionHandlerEvent {
  final int? fromChord;
  final int? toChord;

  @override
  List<Object?> get props => [fromChord, toString()];

  const ChangeRange({this.fromChord, this.toChord})
      : assert(!(fromChord == null && toChord == null));
}

class SetMeasure extends ProgressionHandlerEvent {
  final Progression newMeasure;
  final int index;

  @override
  List<Object?> get props => [newMeasure, index];

  SetMeasure({required this.newMeasure, required this.index})
      : assert(index >= 0 &&
            (newMeasure.isEmpty ||
                newMeasure[0] is Chord ||
                newMeasure is ScaleDegreeProgression));
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

class Reharmonize extends ProgressionHandlerEvent {}

class SurpriseMe extends ProgressionHandlerEvent {}
