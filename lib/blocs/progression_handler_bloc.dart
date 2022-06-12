import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/absolute_durations.dart';
import 'package:thoery_test/modals/chord_progression.dart';
import 'package:thoery_test/modals/exceptions.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_chord.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:thoery_test/modals/time_signature.dart';
import 'package:thoery_test/state/progression_bank.dart';
import 'package:tonic/tonic.dart';
import 'package:weizmann_theory_app_test/blocs/substitution_handler/substitution_handler_bloc.dart';
import 'package:weizmann_theory_app_test/utilities.dart';

import '../modals/progression_type.dart';

part 'progression_handler_event.dart';
part 'progression_handler_state.dart';

class ProgressionHandlerBloc
    extends Bloc<ProgressionHandlerEvent, ProgressionHandlerState> {
  late final SubstitutionHandlerBloc _substitutionHandlerBloc;
  EntryLocation location;
  PitchScale? _currentScale;
  ChordProgression currentChords = ChordProgression.empty();
  ScaleDegreeProgression currentProgression = ScaleDegreeProgression.empty();
  List<Progression<Chord>>? _chordMeasures;
  List<Progression<ScaleDegreeChord>>? _progressionMeasures;
  ProgressionType type = ProgressionType.romanNumerals;
  int fromChord = 0, toChord = 0;
  double startDur = 0.0;
  double endDur = 0.0;
  int startMeasure = -1, startIndex = 0;
  int endMeasure = -1, endIndex = 0;
  bool rangeDisabled = true;

  static final PitchScale defaultScale =
      PitchScale.common(tonic: Pitch.parse('C'));

  double get fromDur => currentlyViewedProgression.isEmpty
      ? 0.0
      : currentlyViewedProgression.durations.real(fromChord) -
          currentlyViewedProgression.durations[fromChord] +
          startDur;

  double get toDur => currentlyViewedProgression.isEmpty
      ? 0.0
      : currentlyViewedProgression.durations.real(toChord) -
          currentlyViewedProgression.durations[toChord] +
          endDur;

  ProgressionHandlerBloc({
    required SubstitutionHandlerBloc substitutionHandlerBloc,
    required this.currentProgression,
    required EntryLocation initialLocation,
  })  : _substitutionHandlerBloc = substitutionHandlerBloc,
        location = initialLocation,
        super(ProgressionHandlerInitial()) {
    if (!currentProgression.isEmpty) {
      _currentScale = defaultScale;
      currentChords = currentProgression.inScale(_currentScale!);
    }
    on<OverrideProgression>((event, emit) {
      _chordMeasures = null;
      _progressionMeasures = null;
      if (!event.newProgression.isEmpty) {
        if (event.newProgression is ChordProgression ||
            event.newProgression is Progression<Chord> ||
            event.newProgression[0] is Chord) {
          bool scaleChanged = _currentScale == null;
          if (scaleChanged) _calculateScales();
          currentChords = ChordProgression.fromProgression(
              event.newProgression as Progression<Chord>);
          if (event.overrideOther) {
            currentProgression = ScaleDegreeProgression.fromChords(
                _currentScale!, currentChords);
          }
          if (scaleChanged) {
            emit(ScaleChanged(
                progression: currentlyViewedProgression,
                scale: _currentScale!));
          }
        } else {
          bool scaleChanged = _currentScale == null;
          if (scaleChanged) _currentScale = defaultScale;
          currentProgression = event.newProgression as ScaleDegreeProgression;
          if (event.overrideOther) {
            currentChords = currentProgression.inScale(_currentScale!);
          }
          if (scaleChanged) {
            emit(ScaleChanged(
                progression: currentlyViewedProgression,
                scale: _currentScale!));
          }
        }
      }
      _substitutionHandlerBloc.add(ClearSubstitutions());
      emit(ProgressionChanged(currentlyViewedProgression));
      final bool rangeValid = _rangeValid();
      if (!rangeDisabled &&
          (!rangeValid || !_recalculateRangePositions(fromDur, toDur))) {
        if (rangeValid) {
          final double step = currentProgression.timeSignature.step;
          final double newFrom =
          min(fromDur, currentProgression.duration - step);
          final double newTo = min(toDur, currentProgression.duration);
          if (newTo - newFrom >= 2 * step) {
            _recalculateRangePositions(newFrom, newTo);
          } else {
            rangeDisabled = true;
            fromChord = -1;
            toChord = -1;
          }
        } else {
          rangeDisabled = true;
          fromChord = -1;
          toChord = -1;
        }
      }
      return emit(RangeChanged(
        progression: currentlyViewedProgression,
        rangeDisabled: rangeDisabled,
        newFromChord: fromChord,
        newToChord: toChord,
        startDur: startDur,
        endDur: endDur,
      ));
    });
    on<SwitchType>((event, emit) {
      type = event.progressionType;
      return emit(
          TypeChanged(progression: currentlyViewedProgression, newType: type));
    });
    on<CalculateScale>((event, emit) {
      add(ChangeScale(type == ProgressionType.romanNumerals
          ? defaultScale
          : currentChords.krumhanslSchmucklerScales.first));
    });
    on<ChangeScale>((event, emit) {
      _currentScale = event.newScale;
      if (type == ProgressionType.romanNumerals) {
        add(OverrideProgression(
          currentProgression.inScale(_currentScale!),
          overrideOther: false,
        ));
      } else {
        add(OverrideProgression(
          ScaleDegreeProgression.fromChords(_currentScale!, currentChords),
          overrideOther: false,
        ));
      }
      return emit(ScaleChanged(
          progression: currentlyViewedProgression, scale: _currentScale!));
    });
    on<ChangeRangeDuration>((event, emit) {
      Progression prog = currentlyViewedProgression;
      if (event.start >= 0.0 &&
          event.end <= prog.duration &&
          event.start < event.end) {
        List<double>? results =
        Utilities.calculateDurationPositions(prog, event.start, event.end);
        if (results != null) {
          fromChord = results[0].toInt();
          startDur = results[1];
          toChord = results[2].toInt();
          endDur = results[3];
          _calculateRangePositions();
          rangeDisabled = false;
          return emit(RangeChanged(
            progression: currentlyViewedProgression,
            rangeDisabled: false,
            newToChord: toChord,
            newFromChord: fromChord,
            startDur: startDur,
            endDur: endDur,
          ));
        }
      }
    });
    on<DisableRange>((event, emit) {
      if (event.disable != rangeDisabled) {
        rangeDisabled = event.disable;
        return emit(RangeChanged(
            progression: currentlyViewedProgression,
            rangeDisabled: rangeDisabled));
      }
    });
    on<MeasureEdited>((event, emit) {
      Progression progression;
      ProgressionType? newType;
      bool chords = type == ProgressionType.chords;
      try {
        progression = chords
            ? _parseChordInputs(event.inputs, event.measureIndex)
            : _parseScaleDegreeInputs(event.inputs, event.measureIndex);
      } on NonValidDuration catch (e) {
        return emit(InvalidInputReceived(
            progression: currentlyViewedProgression, exception: e));
      } on Exception catch (firstError) {
        try {
          progression = chords
              ? _parseScaleDegreeInputs(event.inputs, event.measureIndex)
              : _parseChordInputs(event.inputs, event.measureIndex);
          newType =
          chords ? ProgressionType.romanNumerals : ProgressionType.chords;
        } on Exception catch (_) {
          return emit(InvalidInputReceived(
              progression: currentlyViewedProgression, exception: firstError));
        }
      }
      if (newType != null) {
        type = newType;
        emit(TypeChanged(
            progression: currentlyViewedProgression, newType: newType));
      }
      // If we're here then the input was valid...

      if (type == ProgressionType.chords) {
        final ChordProgression chordProgression =
        ChordProgression.fromProgression(progression as Progression<Chord>);
        if (_currentScale == null) {
          _currentScale = chordProgression.krumhanslSchmucklerScales.first;
          emit(ScaleChanged(
              progression: currentlyViewedProgression, scale: _currentScale!));
        }
        add(OverrideProgression(chordProgression));
      } else {
        add(
          OverrideProgression(progression),
        );
      }
    });
    on<Reharmonize>((event, emit) {
      if (!rangeDisabled) {
        _substitutionHandlerBloc.add(OpenSetupPage(
          progression: currentProgression,
          surpriseMe: false,
          fromChord: fromChord,
          toChord: toChord,
          startDur: startDur,
          endDur: endDur,
        ));
      }
    });
    on<SurpriseMe>(
          (event, emit) => _substitutionHandlerBloc.add(OpenSetupPage(
        progression: currentProgression,
        surpriseMe: true,
      )),
    );
    on<ApplySubstitution>(
          (event, emit) =>
          add(OverrideProgression(event.substitution.substitutedBase)),
    );
    on<ChangeTimeSignature>((event, emit) {
      ScaleDegreeProgression progression;
      bool even = currentProgression.timeSignature.numerator == 4;
      try {
        progression = currentProgression.inTimeSignature(
            even ? const TimeSignature(3, 4) : const TimeSignature.evenTime());
      } on Exception catch (e) {
        return emit(InvalidInputReceived(
            progression: currentlyViewedProgression, exception: e));
      }
      emit(ChangedTimeSignature(
          progression: currentlyViewedProgression, even: !even));
      add(OverrideProgression(progression));
    });
    on<ChangeLocation>((event, emit) {
      location = event.newLocation;
      return emit(ChangedLocation(
          progression: currentlyViewedProgression, newLocation: location));
    });
  }

  Progression<ScaleDegreeChord> _parseScaleDegreeInputs(
          List<String> inputs, int index) =>
      ScaleDegreeProgression.fromProgression(
          _parseInputsAndReplace<ScaleDegreeChord>(
        inputs: inputs,
        index: index,
        parse: (input) => ScaleDegreeChord.parse(input),
        progression: currentProgression,
        measures: _progressionMeasures,
      ));

  Progression<Chord> _parseChordInputs(List<String> inputs, int index) =>
      _parseInputsAndReplace<Chord>(
        inputs: inputs,
        index: index,
        parse: (input) => ChordExtension.parse(input),
        progression: currentChords,
        measures: _chordMeasures,
      );

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

  bool _rangeValid() =>
      fromChord >= 0 &&
      toChord >= 0 &&
      fromChord < currentlyViewedProgression.length &&
      toChord < currentlyViewedProgression.length;

  void _calculateRangePositions() {
    List<int> results = Utilities.calculateRangePositions(
      progression: currentlyViewedProgression,
      measures: currentlyViewedMeasures,
      fromChord: fromChord,
      toChord: toChord,
      startDur: startDur,
      endDur: endDur,
    );
    startMeasure = results[0];
    startIndex = results[1];
    endMeasure = results[2];
    endIndex = results[3];
  }

  bool _recalculateRangePositions(double start, double end) {
    if (start < 0.0 ||
        end > currentlyViewedProgression.duration ||
        start >= end) {
      return false;
    }
    List<double>? results = Utilities.calculateDurationPositions(
        currentlyViewedProgression, start, end);
    if (results == null) {
      return false;
    } else {
      fromChord = results[0].toInt();
      startDur = results[1];
      toChord = results[2].toInt();
      endDur = results[3];
      _calculateRangePositions();
      rangeDisabled = false;
      return true;
    }
  }

  bool _valueIsNull(String value) =>
      value == '/' || value == '//' || value == 'null';

  bool _adjacentValuesEqual(String val, String next) =>
      Progression.adjacentValuesEqual(val, next) ||
      (_valueIsNull(val) && _valueIsNull(next));

  Progression<T> _parseInputsAndReplace<T>({
    required List<String> inputs,
    required T Function(String input) parse,
    required int index,
    required Progression<T> progression,
    required List<Progression<T>>? measures,
  }) {
    final TimeSignature ts = currentProgression.timeSignature;
    if (inputs.length == 1 && inputs[0].isEmpty) {
      progression.replaceMeasure(
        index,
        Progression.empty(timeSignature: ts),
        measures: measures,
      );
    }
    List<double> durations = [];
    final double step = ts.step;
    double duration = 0.0;
    bool hasNull = false;
    List<T?> newValues = [];
    for (int i = 0; i < inputs.length; i++) {
      if (inputs[i].isNotEmpty) {
        List<String> parts = inputs[i].split(' ');
        String value = parts[0];
        int addTimes = 1;
        if (parts.length == 2) {
          addTimes = max(addTimes, int.tryParse(parts[1]) ?? addTimes);
        }
        duration += step + ((addTimes - 1) * step);
        if (i >= inputs.length - 1 ||
            !_adjacentValuesEqual(value, inputs[i + 1].split(' ')[0])) {
          if (value == '/' || value == '//' || value == 'null') {
            newValues.add(null);
            hasNull = true;
          } else {
            newValues.add(parse.call(value));
          }
          double dur = duration;
          if (durations.isNotEmpty) {
            dur = duration - durations.last;
          }
          if (dur <= 0) {
            throw NonPositiveDuration(value, dur);
          }
          durations.add(duration);
        }
      }
    }

    // Since the names can be different, we pass through again to conjoin
    // adjacent elements...
    return progression.replaceMeasure(
      index,
      Progression.raw(
        values: newValues,
        durations: AbsoluteDurations(durations),
        hasNull: hasNull,
        timeSignature: ts,
      ),
      measures: measures,
    );
  }
}
