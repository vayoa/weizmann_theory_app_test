import 'dart:math';

import 'package:bloc/bloc.dart' hide Change;
import 'package:equatable/equatable.dart';
import 'package:harmony_theory/modals/progression/progression.dart';
import 'package:undo/undo.dart';
import 'package:weizmann_theory_app_test/blocs/progression_handler_bloc.dart';

import '../../utilities.dart';

part 'input_state.dart';

class InputCubit extends Cubit<InputState> {
  InputCubit(this.bloc) : super(const InputDisabled());

  final ProgressionHandlerBloc bloc;
  final ChangeStack _changeStack = ChangeStack();

  int editedPos = -1, editedMeasure = -1;

  changePos(int pos, [int? measure]) {
    editedPos = pos;
    editedMeasure = measure ?? editedMeasure;
    return emit(InputActive(editedPos, editedMeasure));
  }

  disable() {
    editedPos = -1;
    editedMeasure = -1;
    return emit(const InputDisabled());
  }

  /// Handles creating edit changes from actions (the values themselves).
  submitAction(EditAction action, int measureIndex) {
    final measure = bloc.currentlyViewedMeasures[measureIndex];
    String? input = action.input;
    final cursor = action.cursor;
    final stick = action.stick;
    final position = action.position;
    if (input == null) return _onDoneEdit(null, measureIndex, cursor, stick);

    final diffPos = position != Position.override;

    List<String> values = [];
    final double step = measure.timeSignature.step;
    final editedPos = this.editedPos;
    input = input.trim();

    /* TODO: The same effect happens when deleting the a chord
             with a duration bigger than 1. Think if it should instead
             just delete a step instead of the whole chord (because ctrl-delete
             deletes the whole chord...).
     */
    // When deleting with ctrl pressed.
    if (input.isEmpty && stick) {
      final closest = measure.getPlayingIndex(step * editedPos);
      for (int i = 0; i < measure.length; i++) {
        if (i != closest) {
          values.add('${measure[i]} ${measure.durations[i] ~/ step}');
        }
      }
    } else {
      int? num = int.tryParse(input);
      var last = '';
      int index = 0;
      final maxPos =
          min(measure.duration ~/ step, measure.timeSignature.numerator);

      for (int p = 0; p < maxPos; p++) {
        bool useIndex = index < measure.length &&
            p == measure.durations.position(index) ~/ step;
        if (!diffPos && p == editedPos) {
          if (num == null) {
            values.add(input);
            last = input;
          } else {
            values.add('$last $input');
          }
        } else {
          last = useIndex ? measure[index].toString() : last;
          values.add(last);
        }
        if (useIndex) {
          index++;
        }
      }

      if (diffPos) {
        position.insert(values, input, editedPos);
      }
    }

    print('$measure - $values');
    _onDoneEdit(values, measureIndex, cursor, stick);
  }

  focus() => emit(FocusedKeys(editedPos, editedMeasure));

  unfocus() => emit(const Unfocused());

  undo() => _changeStack.undo();

  redo() => _changeStack.redo();

  deleteRange() {
    final rangeStart = bloc.fromDur, rangeEnd = bloc.toDur;
    _changeCurr(
      DeleteRange(rangeStart, rangeEnd),
      description: "Deleted Range $rangeStart - $rangeEnd.",
    );
  }

  _changeCurr(ProgressionHandlerEvent event, {String description = ''}) =>
      _changeStack.add(
        Change<Progression>(
          bloc.currentlyViewedProgression,
          () => bloc.add(event),
          (oldValue) => bloc.add(OverrideProgression(oldValue)),
          description: description,
        ),
      );

  /// Handles the edit changes.
  _onDoneEdit(List<String>? values, int index, Cursor cursor, bool stick) {
    if (values != null) {
      _changeCurr(
        MeasureEdited(inputs: values, measureIndex: index),
        description: "Edited $index measure to $values.",
      );
    }
    final progression = bloc.currentlyViewedProgression;
    final measures = bloc.currentlyViewedMeasures;
    final double step = progression.timeSignature.step;
    if (cursor == Cursor.done) {
      disable();
      return focus();
    }

    if (stick) {
      _handleStickPos(cursor);
    } else {
      int add = cursor.value!;
      editedPos += add;
      final numeratorIndex = progression.timeSignature.numerator - 1;
      if (editedPos > numeratorIndex || editedPos < 0) {
        editedMeasure += add;
        if (editedMeasure == measures.length) {
          _addNewMeasure();
        } else if (editedMeasure < 0) {
          editedMeasure = 0;
        }
        editedPos = cursor == Cursor.next ? 0 : numeratorIndex;
      } else if (editedMeasure == measures.length - 1 &&
          editedPos >= measures[editedMeasure].duration ~/ step) {
        _addNewVal(values);
      }
    }

    return emit(InputActive(editedPos, editedMeasure));
  }

  void _addNewMeasure() {
    // TODO: Decide what to add on empty
    final measures = bloc.currentlyViewedMeasures;
    final full = measures[editedMeasure - 1].full;
    _changeCurr(
      MeasureEdited(
        inputs: full
            ? const ['// 1']
            : ['// ${measures.last.timeSignature.numerator + 1}'],
        measureIndex: full ? editedMeasure : editedMeasure - 1,
      ),
      description: "Added a new empty measure at $editedMeasure.",
    );
  }

  void _addNewVal(List<String>? values) {
    // TODO: Decide what to add on empty
    final measures = bloc.currentlyViewedMeasures;
    final step = measures.first.timeSignature.step;
    final m = measures[editedMeasure];
    final inputs = values ?? Utilities.progressionEdit(m);
    final val = _isValidAdd(m, m.durations.last + step) ? inputs.last : null;
    inputs.add('$val ,');

    _changeCurr(
      MeasureEdited(inputs: inputs, measureIndex: editedMeasure),
      description: "Added $val at measure $editedMeasure.",
    );
  }

  void _handleStickPos(Cursor cursor) {
    final measures = bloc.currentlyViewedMeasures;
    int newM = editedMeasure;
    final m = measures[newM];
    final step = m.timeSignature.step;
    final cursorPos = step * editedPos;

    // Find the closest value to the current pos
    int closest = m.getPlayingIndex(cursorPos);

    // If the cursorPos isn't on a chord...
    if (m.durations.position(closest) != cursorPos) {
      closest++;
    }

    closest += cursor.value ?? 0;

    if (closest >= m.length) {
      // While sticking, if we're at the last value on the last measure
      // and going next, we'll always create a new measure.
      closest = 0;
      newM++;
      if (newM >= measures.length) {
        editedMeasure = measures.length;
        editedPos = 0;
        return _addNewMeasure();
      }
    } else if (closest < 0) {
      newM--;
      if (newM < 0) {
        editedMeasure = 0;
        editedPos = 0;
        return;
      }
      closest = measures[newM].length - 1;
    }

    editedMeasure = newM;
    editedPos = measures[newM].durations.position(closest) ~/ step;
  }

  bool _isValidAdd<T>(Progression<T> measure, double dur) =>
      measure.timeSignature.validDuration(dur);
}

class EditAction {
  final String? input;
  final Cursor cursor;
  final bool stick;
  final Position position;

  const EditAction(
    this.input,
    this.cursor, [
    this.stick = false,
    this.position = Position.override,
  ]);
}

enum Cursor {
  done,
  previous(-1),
  stay(0),
  next(1);

  final int? value;

  const Cursor([this.value]);
}

enum Position {
  prepend,
  override,
  append,
  appendMeasure;

  insert(List<String> values, String input, int editedPos) {
    switch (this) {
      case Position.prepend:
        return values.insert(editedPos, input);
      case Position.append:
        return values.insert(editedPos + 1, input);
      case Position.appendMeasure:
        return values.add(input);
      default:
        return;
    }
  }
}
