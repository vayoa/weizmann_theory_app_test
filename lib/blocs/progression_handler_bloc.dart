import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/chord_progression.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:tonic/tonic.dart';
import 'package:weizmann_theory_app_test/blocs/substitution_handler/substitution_handler_bloc.dart';
import 'package:weizmann_theory_app_test/utilities.dart';

import '../modals/progression_type.dart';

part 'progression_handler_event.dart';
part 'progression_handler_state.dart';

class ProgressionHandlerBloc
    extends Bloc<ProgressionHandlerEvent, ProgressionHandlerState> {
  late final SubstitutionHandlerBloc _substitutionHandlerBloc;
  PitchScale? _currentScale;
  ChordProgression currentChords = ChordProgression.empty();
  ScaleDegreeProgression currentProgression =
      ScaleDegreeProgression.empty(inMinor: false);
  List<Progression<Chord>>? _chordMeasures;
  List<Progression<ScaleDegreeChord>>? _progressionMeasures;
  ProgressionType type = ProgressionType.chords;
  int fromChord = 0, toChord = 1;
  int startMeasure = -1, startIndex = 0;
  int endMeasure = -1, endIndex = 0;

  ProgressionHandlerBloc(this._substitutionHandlerBloc)
      : super(ProgressionHandlerInitial()) {
    on<OverrideProgression>((event, emit) {
      // TODO: Add an OverrideChords event...
      if (_currentScale == null) _calculateScales();
      _chordMeasures = null;
      _progressionMeasures = null;
      if (!event.newProgression.isEmpty) {
        if (event.newProgression[0] is Chord) {
          currentChords = ChordProgression.fromProgression(
              event.newProgression as Progression<Chord>);
          currentProgression =
              ScaleDegreeProgression.fromChords(_currentScale!, currentChords);
        } else {
          currentProgression = event.newProgression as ScaleDegreeProgression;
          currentChords = currentProgression.inScale(_currentScale!);
        }
      }
      _substitutionHandlerBloc.add(ClearSubstitutions());
      emit(ProgressionChanged(currentlyViewedProgression));
      return emit(RangeChanged(
        progression: currentlyViewedProgression,
        newFromChord: fromChord,
        newToChord: toChord,
      ));
    });
    on<SwitchType>((event, emit) {
      type = event.progressionType;
      return emit(
          TypeChanged(progression: currentlyViewedProgression, newType: type));
    });
    on<CalculateScale>((event, emit) {
      _calculateScales();
      return emit(RecalculatedScales(
          progression: currentlyViewedProgression, scale: _currentScale!));
    });
    on<ChangeScale>((event, emit) {
      if (_currentScale == null) {
        _calculateScales();
        emit(RecalculatedScales(
            progression: currentlyViewedProgression, scale: _currentScale!));
      }
      _currentScale = event.newScale;
      currentProgression =
          ScaleDegreeProgression.fromChords(_currentScale!, currentChords);
      _progressionMeasures = null;
      emit(ProgressionChanged(currentlyViewedProgression));
      return emit(ScaleChanged(
          progression: currentlyViewedProgression, scale: _currentScale!));
    });
    on<ChangeRange>((event, emit) {
      int newFromChord = fromChord, newToChord = toChord;
      if (event.fromChord != null) newFromChord = event.fromChord!;
      if (event.toChord != null) newToChord = event.toChord!;
      if (!(event.fromChord == null && event.toChord == null) &&
          newToChord - newFromChord > 0) {
        fromChord = newFromChord;
        toChord = newToChord;
        _calculateRangePositions();
        return emit(RangeChanged(
            progression: currentlyViewedProgression,
            newToChord: toChord,
            newFromChord: fromChord));
      }
    });
    on<MeasureEdited>((event, emit) {
      try {
        Progression progression;
        if (type == ProgressionType.chords) {
          progression = _parseInputs<Chord>(
              event.inputs, (input) => ChordExtension.parse(input));
        } else {
          progression = ScaleDegreeProgression.fromProgression(
              _parseInputs<ScaleDegreeChord>(
                  event.inputs, (input) => ScaleDegreeChord.parse(input)),
              inMinor: _currentScale!.isMinor);
        }
        add(SetMeasure(newMeasure: progression, index: event.measureIndex));
      } on Exception catch (e) {
        return emit(InvalidInputReceived(
            progression: currentlyViewedProgression, exception: e));
      }
    });
    on<SetMeasure>((event, emit) {
      if (event.newMeasure.isEmpty || event.newMeasure[0] is Chord) {
        add(
          OverrideProgression(
            ScaleDegreeProgression.fromChords(
              _currentScale!,
              currentChords.replaceMeasure(
                event.index,
                event.newMeasure as Progression<Chord>,
                measures: chordMeasures,
              ),
            ),
          ),
        );
      } else {
        add(
          OverrideProgression(
            ScaleDegreeProgression.fromProgression(
              currentProgression.replaceMeasure(
                event.index,
                event.newMeasure as Progression<ScaleDegreeChord>,
                measures: progressionMeasures,
              ),
              inMinor: currentProgression.inMinor,
            ),
          ),
        );
      }
    });
    on<Reharmonize>(
      (event, emit) => _substitutionHandlerBloc.add(ReharmonizeSubs(
        progression: currentProgression,
        fromChord: fromChord,
        toChord: toChord,
      )),
    );
    on<SurpriseMe>(
          (event, emit) => _substitutionHandlerBloc.add(
          SurpriseMeSubs(progression: currentChords, scale: currentScale!)),
    );
    on<ApplySubstitution>(
      (event, emit) =>
          add(OverrideProgression(event.substitution.substitutedBase)),
    );
  }

  Progression get currentlyViewedProgression {
    if (type == ProgressionType.romanNumerals) {
      return currentProgression;
    }
    return currentChords;
  }

  List<Progression> get currentlyViewedMeasures {
    if (type == ProgressionType.romanNumerals) {
      return progressionMeasures;
    }
    return chordMeasures;
  }

  List<Progression<Chord>> get chordMeasures {
    _chordMeasures ??= currentChords.splitToMeasures();
    return _chordMeasures!;
  }

  List<Progression<ScaleDegreeChord>> get progressionMeasures {
    _progressionMeasures ??= currentProgression.splitToMeasures();
    return _progressionMeasures!;
  }

  PitchScale? get currentScale => _currentScale;

  SubstitutionHandlerBloc get substitutionHandlerBloc =>
      _substitutionHandlerBloc;

  bool get progressionEmpty => currentlyViewedProgression.isEmpty;

  void _calculateScales() {
    _currentScale = currentChords.krumhanslSchmucklerScales.first;
  }

  // TODO: Optimize this.
  void _calculateRangePositions() {
    List<int> results = Utilities.calculateRangePositions(
        progression: currentlyViewedProgression,
        measures: currentlyViewedMeasures,
        fromChord: fromChord,
        toChord: toChord);
    startMeasure = results[0];
    startIndex = results[1];
    endMeasure = results[2];
    endIndex = results[3];
  }

  Progression<T> _parseInputs<T>(
      List<String> inputs, T Function(String input) parse) {
    // TODO: Make a delete measure method instead...
    if (inputs.length == 1 && inputs[0].isEmpty) {
      return Progression.empty();
    }
    List<String> unique = [];
    List<double> durations = [];
    final double step = currentProgression.timeSignature.step;
    int count = -1;
    double duration = 0.0;
    List<T?> newValues = [];
    for (int i = 0; i < inputs.length; i++) {
      if (unique.isNotEmpty &&
          Progression.adjacentValuesEqual(inputs[i], unique[count])) {
        durations[count] += step;
      } else {
        String value = inputs[i];
        if (value == '/' || value == '//') {
          value = 'null';
        }
        unique.add(value);
        if (value == 'null') {
          newValues.add(null);
        } else {
          newValues.add(parse.call(value));
        }
        if (durations.isNotEmpty) {
          currentlyViewedProgression.assertDurationValid(
              value: newValues[count], duration: durations[count]);
        }
        durations.add(step);
        count++;
      }
      duration += step;
    }
    return Progression.raw(
      values: newValues,
      durations: durations,
      timeSignature: currentlyViewedProgression.timeSignature,
      duration: duration,
    );
  }
}
