import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:thoery_test/extensions/chord_extension.dart';
import 'package:thoery_test/modals/absolute_durations.dart';
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
  ScaleDegreeProgression currentProgression = ScaleDegreeProgression.empty();
  List<Progression<Chord>>? _chordMeasures;
  List<Progression<ScaleDegreeChord>>? _progressionMeasures;
  ProgressionType type = ProgressionType.chords;
  int fromChord = 0, toChord = 0;
  double startDur = 0.0;
  double endDur = 0.0;
  int startMeasure = -1, startIndex = 0;
  int endMeasure = -1, endIndex = 0;
  bool rangeDisabled = true;

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

  ProgressionHandlerBloc(this._substitutionHandlerBloc)
      : super(ProgressionHandlerInitial()) {
    on<OverrideProgression>((event, emit) {
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
      rangeDisabled = true;
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
      try {
        Progression progression;
        if (type == ProgressionType.chords) {
          progression = _parseInputs<Chord>(
              event.inputs, (input) => ChordExtension.parse(input));
        } else {
          progression = ScaleDegreeProgression.fromProgression(
              _parseInputs<ScaleDegreeChord>(
                  event.inputs, (input) => ScaleDegreeChord.parse(input)));
        }
        add(SetMeasure(newMeasure: progression, index: event.measureIndex));
      } on Exception catch (e) {
        print('hey');
        return emit(InvalidInputReceived(
            progression: currentlyViewedProgression, exception: e));
      }
    });
    on<SetMeasure>((event, emit) {
      // if (event.index >= startMeasure && event.index <= endMeasure) {
      //   final Progression prog = currentlyViewedProgression;
      //   print(
      //       'startMeasure: $startMeasure, endMeasure: $endMeasure, index: ${event.index}');
      //   if (event.index == startMeasure && event.index == endMeasure) {
      //     rangeDisabled = true;
      //     emit(RangeChanged(progression: prog, rangeDisabled: rangeDisabled));
      //   } else if (startMeasure == event.index) {
      //     startDur = 0.0;
      //     // fromChord =
      //   } else if (endMeasure == event.index) {
      //   } else {}
      // }
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
            ),
          ),
        );
      }
    });
    on<Reharmonize>((event, emit) {
      if (!rangeDisabled) {
        _substitutionHandlerBloc.add(SetupReharmonization(
          progression: currentProgression,
          fromChord: fromChord,
          toChord: toChord,
          startDur: startDur,
          endDur: endDur,
        ));
      }
    });
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
      toChord: toChord,
      startDur: startDur,
      endDur: endDur,
    );
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
    List<double> durations = [];
    final double step = currentProgression.timeSignature.step;
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
          if (value == '/' || value == '//') {
            hasNull = true;
            value = 'null';
          }
          if (value == 'null') {
            newValues.add(null);
          } else {
            newValues.add(parse.call(value));
          }
          double dur = duration % currentProgression.timeSignature.decimal;
          double overallDur = 0.0;
          if (durations.isNotEmpty) {
            dur = (duration - durations.last) %
                currentProgression.timeSignature.decimal;
            overallDur = dur;
          }
          currentlyViewedProgression.checkValidDuration(
            value: newValues.last,
            duration: dur,
            overallDuration: overallDur,
          );
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
