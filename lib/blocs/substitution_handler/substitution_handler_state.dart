part of 'substitution_handler_bloc.dart';

abstract class SubstitutionHandlerState extends Equatable {
  @override
  List<Object?> get props => const [];

  const SubstitutionHandlerState();
}

class SubstitutionHandlerInitial extends SubstitutionHandlerState {
  @override
  List<Object> get props => [];
}

class SetupPage extends SubstitutionHandlerState {
  final bool surpriseMe;

  @override
  List<Object?> get props => [surpriseMe];

  const SetupPage({required this.surpriseMe});
}

class TypeChanged extends SubstitutionHandlerState {
  final ProgressionType newType;

  @override
  List<Object?> get props => [newType];

  const TypeChanged(this.newType);
}

class CalculatingSubstitutions extends SubstitutionHandlerState {
  final int fromChord;
  final int toChord;

  const CalculatingSubstitutions(
      {required this.fromChord, required this.toChord});
}

class CalculatedSubstitutions extends SubstitutionHandlerState {
  final List<Substitution> substitutions;
  final bool surpriseMe;

  @override
  List<Object?> get props => [substitutions, surpriseMe];

  const CalculatedSubstitutions({
    required this.substitutions,
    required this.surpriseMe,
  });
}

class ClearedSubstitutions extends SubstitutionHandlerState {
  const ClearedSubstitutions();
}

class ChangedSubstitutionSettings extends SubstitutionHandlerState {
  @override
  List<Object?> get props => [];
}

class HidSubstitutions extends SubstitutionHandlerState {
  const HidSubstitutions();
}

class ShowingSubstitutions extends SubstitutionHandlerState {
  const ShowingSubstitutions();
}

class ChangedSubstitutionIndex extends SubstitutionHandlerState {
  final int fromIndex;
  final int newIndex;

  @override
  List<Object?> get props => [fromIndex, newIndex];

  const ChangedSubstitutionIndex(this.fromIndex, this.newIndex);
}
