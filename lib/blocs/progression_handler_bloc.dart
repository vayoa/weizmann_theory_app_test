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
import 'package:tonic/tonic.dart';
import 'package:weizmann_theory_app_test/blocs/substitution_handler/substitution_handler_bloc.dart';
import 'package:weizmann_theory_app_test/utilities.dart';

import '../modals/progression_type.dart';

part 'progression_handler_event.dart';
part 'progression_handler_state.dart';

class ProgressionHandlerBloc
    extends Bloc<ProgressionHandlerEvent, ProgressionHandlerState> {
  late final SubstitutionHandlerBloc _substitutionHandlerBloc;
  String title;
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
    required String initialTitle,
  })  : _substitutionHandlerBloc = substitutionHandlerBloc,
        title = initialTitle,
        super(ProgressionHandlerInitial()) {
    on<OverrideProgression>((event, emit) {
      _chordMeasures = null;
      _progressionMeasures = null;
      if (!event.newProgression.isEmpty) {
        if (event.newProgression[0] is Chord) {
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
      if (!_rangeValid() || !_recalculateRangePositions(fromDur, toDur)) {
        rangeDisabled = true;
        fromChord = -1;
        toChord = -1;
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
        double realEnd = event.end - (prog.timeSignature.step / 2);
        int newFromChord = prog.getPlayingIndex(event.start),
            newToChord = prog.getPlayingIndex(realEnd);
        if (newToChord >= newFromChord) {
          fromChord = newFromChord;
          toChord = newToChord;
          startDur = event.start -
              (prog.durations.real(fromChord) - prog.durations[fromChord]);
          endDur = event.end -
              (prog.durations.real(toChord) - prog.durations[toChord]);
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
            ? _parseChordInputs(event.inputs)
            : _parseScaleDegreeInputs(event.inputs);
      } on Exception catch (firstError) {
        try {
          progression = chords
              ? _parseScaleDegreeInputs(event.inputs)
              : _parseChordInputs(event.inputs);
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
      if (progression.isEmpty || type == ProgressionType.chords) {
        if (_currentScale == null) {
          _currentScale = ChordProgression.fromProgression(
                  progression as Progression<Chord>)
              .krumhanslSchmucklerScales
              .first;
          emit(ScaleChanged(
              progression: currentlyViewedProgression, scale: _currentScale!));
        }
        add(
          OverrideProgression(
            ScaleDegreeProgression.fromChords(
              _currentScale!,
              currentChords.replaceMeasure(
                event.measureIndex,
                progression as Progression<Chord>,
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
                event.measureIndex,
                progression as Progression<ScaleDegreeChord>,
                measures: progressionMeasures,
              ),
            ),
          ),
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
  }

  Progression<ScaleDegreeChord> _parseScaleDegreeInputs(List<String> inputs) =>
      ScaleDegreeProgression.fromProgression(_parseInputs<ScaleDegreeChord>(
          inputs, (input) => ScaleDegreeChord.parse(input)));

  Progression<Chord> _parseChordInputs(List<String> inputs) =>
      _parseInputs<Chord>(inputs, (input) => ChordExtension.parse(input));

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
      fromDur < currentlyViewedProgression.length &&
      toChord < currentlyViewedProgression.length;

  // TODO: Optimize this.
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
    Progression prog = currentlyViewedProgression;
    if (start >= 0.0 && end <= prog.duration && start < end) {
      double realEnd = end - (prog.timeSignature.step / 2);
      int newFromChord = prog.getPlayingIndex(start),
          newToChord = prog.getPlayingIndex(realEnd);
      if (newToChord >= newFromChord) {
        int _fromChord = newFromChord;
        int _toChord = newToChord;
        double _startDur = start -
            (prog.durations.real(_fromChord) - prog.durations[_fromChord]);
        double _endDur =
            end - (prog.durations.real(_toChord) - prog.durations[_toChord]);
        if (prog.timeSignature.validDuration(_startDur) &&
            prog.timeSignature.validDuration(_endDur)) {
          fromChord = _fromChord;
          toChord = _toChord;
          startDur = _startDur;
          endDur = _endDur;
          _calculateRangePositions();
          rangeDisabled = false;
          return true;
        }
      }
    }
    return false;
  }

  Progression<T> _parseInputs<T>(
      List<String> inputs, T Function(String input) parse) {
    // TODO: Make a delete measure method instead...
    if (inputs.length == 1 && inputs[0].isEmpty) {
      return Progression.empty();
    }
    List<double> durations = [];
    final TimeSignature ts = currentProgression.timeSignature;
    final double step = ts.step;
    final double decimal = ts.decimal;
    double duration = 0.0;
    List<T?> newValues = [];
    bool hasNull = false;
    for (int i = 0; i < inputs.length; i++) {
      if (inputs.isEmpty || inputs[i].isNotEmpty) {
        duration += step;
        if (i >= inputs.length - 1 ||
            inputs.isEmpty ||
            inputs[i] != inputs[i + 1]) {
          String value = inputs[i];
          if (value == '/' || value == '//' || value == 'null') {
            hasNull = true;
            newValues.add(null);
          } else {
            newValues.add(parse.call(value));
          }
          double dur = duration % decimal;
          double overallDur = 0.0;
          if (durations.isNotEmpty) {
            dur = (duration - durations.last) % decimal;
            overallDur = dur;
          }
          if (dur < 0) {
            throw NonPositiveDuration(value, duration);
          } else if ((overallDur % decimal) + duration <= decimal) {
            if (!currentProgression.timeSignature.validDuration(dur)) {
              throw NonValidDuration(
                  value: value, duration: duration, timeSignature: ts);
            }
          }
          durations.add(duration);
        }
      }
    }
    return Progression.raw(
      values: newValues,
      durations: AbsoluteDurations(durations),
      timeSignature: currentlyViewedProgression.timeSignature,
      hasNull: hasNull,
    );
  }
}
