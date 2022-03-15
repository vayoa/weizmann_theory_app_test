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

  @override
  List<Object?> get props => [substitutions];

  const CalculatedSubstitutions(this.substitutions);
}

class ClearedSubstitutions extends SubstitutionHandlerState {
  const ClearedSubstitutions();
}
