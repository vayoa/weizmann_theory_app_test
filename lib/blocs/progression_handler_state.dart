part of 'progression_handler_bloc.dart';

abstract class ProgressionHandlerState extends Equatable {
  final Progression progression;

  @override
  List<Object?> get props => [progression];

  const ProgressionHandlerState(this.progression);
}

class ProgressionHandlerInitial extends ProgressionHandlerState {
  ProgressionHandlerInitial() : super(Progression.empty());
}

class ProgressionChanged extends ProgressionHandlerState {
  const ProgressionChanged(Progression newProgression) : super(newProgression);
}

class TypeChanged extends ProgressionHandlerState {
  final ProgressionType newType;

  @override
  List<Object?> get props => [...super.props, newType];

  const TypeChanged({
    required Progression progression,
    required this.newType,
  }) : super(progression);
}

class RecalculatedScales extends ProgressionHandlerState {
  final PitchScale scale;

  @override
  List<Object?> get props => [...super.props, scale];

  const RecalculatedScales(
      {required Progression progression, required this.scale})
      : super(progression);
}

class ScaleChanged extends ProgressionHandlerState {
  final PitchScale scale;

  @override
  List<Object?> get props => [...super.props, scale];

  const ScaleChanged({required Progression progression, required this.scale})
      : super(progression);
}

class RangeChanged extends ProgressionHandlerState {
  final bool rangeDisabled;
  final int? newFromChord;
  final int? newToChord;
  final double startDur;
  final double? endDur;

  @override
  List<Object?> get props =>
      [...super.props, newFromChord, newToChord, startDur, endDur];

  const RangeChanged({
    required Progression progression,
    required this.rangeDisabled,
    this.newToChord,
    this.newFromChord,
    this.startDur = 0.0,
    this.endDur,
  }) : super(progression);
}

class InvalidInputReceived extends ProgressionHandlerState {
  final Exception exception;

  @override
  List<Object?> get props => [...super.props, exception];

  const InvalidInputReceived(
      {required Progression progression, required this.exception})
      : super(progression);
}
