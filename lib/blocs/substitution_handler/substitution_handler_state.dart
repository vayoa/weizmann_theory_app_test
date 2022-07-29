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

/* TODO: Emitting this mid loading will override the state...
         perhaps it's a better idea to have these ui-only
         states somewhere else (not the loading, the
         show/hide...)
 */
class UpdatedShowSubstitutions extends SubstitutionHandlerState {
  final bool showing;

  @override
  List<Object> get props => [showing];

  const UpdatedShowSubstitutions(this.showing);
}

class ChangedSubstitutionIndex extends SubstitutionHandlerState {
  final int fromIndex;
  final int newIndex;

  @override
  List<Object?> get props => [fromIndex, newIndex];

  const ChangedSubstitutionIndex(this.fromIndex, this.newIndex);
}

class ChangedVisibility extends SubstitutionHandlerState {
  final bool visible;

  @override
  List<Object> get props => [visible];

  const ChangedVisibility(this.visible);
}
