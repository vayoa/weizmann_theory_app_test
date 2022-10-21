part of 'input_cubit.dart';

abstract class InputState extends Equatable {
  const InputState();
}

class InputDisabled extends InputState {
  @override
  List<Object> get props => [];

  const InputDisabled();
}

class Unfocused extends InputDisabled {
  const Unfocused();
}

class InputActive extends InputState {
  final int editedPos;
  final int editedMeasure;

  @override
  List<Object?> get props => [editedPos, editedMeasure];

  const InputActive(this.editedPos, this.editedMeasure);
}

class FocusedKeys extends InputActive {
  const FocusedKeys(int editedPos, int editedMeasure)
      : super(editedPos, editedMeasure);
}
