import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:harmony_theory/modals/pitch_chord.dart';
import 'package:harmony_theory/modals/progression/absolute_durations.dart';
import 'package:harmony_theory/modals/progression/chord_progression.dart';
import 'package:harmony_theory/modals/progression/degree_progression.dart';
import 'package:harmony_theory/modals/progression/exceptions.dart';
import 'package:harmony_theory/modals/progression/progression.dart';
import 'package:harmony_theory/modals/progression/time_signature.dart';
import 'package:harmony_theory/modals/substitution.dart';
import 'package:harmony_theory/modals/theory_base/degree/degree_chord.dart';
import 'package:harmony_theory/modals/theory_base/pitch_scale.dart';
import 'package:harmony_theory/state/progression_bank.dart';
import 'package:tonic/tonic.dart';

import '../blocs/substitution_handler/substitution_handler_bloc.dart';
import '../modals/progression_type.dart';
import '../utilities.dart';

part 'progression_handler_event.dart';
part 'progression_handler_state.dart';

class ProgressionHandlerBloc
    extends Bloc<ProgressionHandlerEvent, ProgressionHandlerState> {
  late final SubstitutionHandlerBloc _substitutionHandlerBloc;
  EntryLocation location;
  PitchScale? _currentScale;
  ChordProgression currentChords = ChordProgression.empty();
  DegreeProgression currentProgression = DegreeProgression.empty();
  List<Progression<PitchChord>>? _chordMeasures;
  List<Progression<DegreeChord>>? _progressionMeasures;
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
    if (currentProgression.length > 1 ||
        (!currentProgression.isEmpty && currentProgression[0] != null)) {
      _currentScale = defaultScale;
      currentChords = currentProgression.inScale(_currentScale!);
    }
    on<OverrideProgression>((event, emit) {
      // TODO: Fix the fact that one chord insert will guess the scale on new songs...
      _chordMeasures = null;
      _progressionMeasures = null;
      if (!event.newProgression.isEmpty) {
        if (event.newProgression is ChordProgression ||
            event.newProgression is Progression<PitchChord> ||
            event.newProgression[0] is PitchChord) {
          bool scaleChanged = _currentScale == null;
          if (scaleChanged) _calculateScales();
          currentChords = ChordProgression.fromProgression(
              event.newProgression as Progression<PitchChord>);
          if (event.overrideOther) {
            currentProgression =
                DegreeProgression.fromChords(_currentScale!, currentChords);
          }
          if (scaleChanged) {
            emit(ScaleChanged(
                progression: currentlyViewedProgression,
                scale: _currentScale!));
          }
        } else {
          bool scaleChanged = _currentScale == null;
          if (scaleChanged) _currentScale = defaultScale;
          currentProgression = event.newProgression as DegreeProgression;
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
      _substitutionHandlerBloc.add(const ClearSubstitutions());
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
          DegreeProgression.fromChords(_currentScale!, currentChords),
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
            : _parseDegreeInputs(event.inputs, event.measureIndex);
      } on NonValidDuration catch (e) {
        return emit(InvalidInputReceived(
            progression: currentlyViewedProgression, exception: e));
      } on Exception catch (firstError) {
        try {
          progression = chords
              ? _parseDegreeInputs(event.inputs, event.measureIndex)
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
            ChordProgression.fromProgression(
                progression as Progression<PitchChord>);
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
    on<DeleteRange>((event, emit) {
      Progression progression;
      try {
        progression = currentlyViewedProgression.deleteRange(fromDur, toDur);
      } on NonValidDuration catch (e) {
        return emit(InvalidInputReceived(
            progression: currentlyViewedProgression, exception: e));
      }
      add(const DisableRange(disable: true));
      if (type == ProgressionType.romanNumerals) {
        return add(OverrideProgression(DegreeProgression.fromProgression(
            progression as Progression<DegreeChord>)));
      } else {
        return add(OverrideProgression(ChordProgression.fromProgression(
            progression as Progression<PitchChord>)));
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
      DegreeProgression progression;
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

  Progression<DegreeChord> _parseDegreeInputs(List<String> inputs, int index) =>
      DegreeProgression.fromProgression(_parseInputsAndReplace<DegreeChord>(
        inputs: inputs,
        index: index,
        parse: (input) => DegreeChord.parse(input),
        progression: currentProgression,
        measures: _progressionMeasures,
      ));

  Progression<PitchChord> _parseChordInputs(List<String> inputs, int index) =>
      _parseInputsAndReplace<PitchChord>(
        inputs: inputs,
        index: index,
        parse: (input) => PitchChord.parse(input),
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

  List<Progression<PitchChord>> get chordMeasures {
    _chordMeasures ??= currentChords.splitToMeasures();
    return _chordMeasures!;
  }

  List<Progression<DegreeChord>> get progressionMeasures {
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
      val == next || (_valueIsNull(val) && _valueIsNull(next));

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
