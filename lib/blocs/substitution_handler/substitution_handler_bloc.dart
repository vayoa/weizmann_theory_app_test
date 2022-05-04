import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoery_test/modals/chord_progression.dart';
import 'package:thoery_test/modals/pitch_scale.dart';
import 'package:thoery_test/modals/progression.dart';
import 'package:thoery_test/modals/scale_degree_progression.dart';
import 'package:thoery_test/modals/substitution.dart';
import 'package:thoery_test/modals/substitution_match.dart';
import 'package:thoery_test/modals/weights/keep_harmonic_function_weight.dart';
import 'package:thoery_test/state/substitution_handler.dart';
import 'package:weizmann_theory_app_test/modals/progression_type.dart';

part 'substitution_handler_event.dart';
part 'substitution_handler_state.dart';

class SubstitutionHandlerBloc
    extends Bloc<SubstitutionHandlerEvent, SubstitutionHandlerState> {
  ProgressionType type = ProgressionType.romanNumerals;
  List<Substitution>? _substitutions;
  bool _inSetup = false;

  bool get inSetup => _inSetup;

  bool _surpriseMe = false;

  bool get surpriseMe => _surpriseMe;

  ScaleDegreeProgression? _currentProgression;
  int _fromChord = 0, _toChord = 0;
  double _startDur = 0.0;
  double? _endDur;
  KeepHarmonicFunctionAmount _keepHarmonicFunction =
      SubstitutionHandler.keepAmount;

  KeepHarmonicFunctionAmount get keepHarmonicFunction => _keepHarmonicFunction;

  // If we calculate a ChordProgression for a substitution we save it here.
  List<ChordProgression?>? _chordProgressions;
  List<ChordProgression?>? _originalSubs;

  List<Substitution>? get substitutions => _substitutions;

  bool get showingWindow => _substitutions != null || _inSetup;

  SubstitutionHandlerBloc() : super(SubstitutionHandlerInitial()) {
    on<OpenSetupPage>((event, emit) {
      _currentProgression = event.progression;
      _fromChord = event.fromChord;
      _toChord = event.toChord ?? event.progression.length - 1;
      _startDur = event.startDur;
      _endDur = event.endDur;
      _inSetup = true;
      _surpriseMe = event.surpriseMe;
      return emit(SetupPage(surpriseMe: event.surpriseMe));
    });
    on<SwitchSubType>((event, emit) {
      type = event.progressionType;
      return emit(TypeChanged(type));
    });
    on<CalculateSubstitutions>((event, emit) {
      bool changedSettings =
          event.keepHarmonicFunction != _keepHarmonicFunction;
      if ((_substitutions == null && _currentProgression != null) ||
          changedSettings) {
        if (changedSettings) {
          _keepHarmonicFunction = event.keepHarmonicFunction;
          emit(ChangedSubstitutionSettings());
        }
        emit(
            CalculatingSubstitutions(fromChord: _fromChord, toChord: _toChord));
        if (_surpriseMe) {
          _substitutions = [
            SubstitutionHandler.substituteBy(
              base: _currentProgression!,
              maxIterations: 50,
              keepHarmonicFunction: _keepHarmonicFunction,
            )
          ];
        } else {
          _substitutions = SubstitutionHandler.getRatedSubstitutions(
            _currentProgression!,
            keepAmount: _keepHarmonicFunction,
            start: _fromChord,
            startDur: _startDur,
            end: _toChord + 1,
            endDur: _endDur,
          );
        }
        _chordProgressions =
            List.generate(_substitutions!.length, (index) => null);
        _originalSubs = List.generate(_substitutions!.length, (index) => null);
        _inSetup = false;
        return emit(CalculatedSubstitutions(
          substitutions: substitutions!,
          surpriseMe: _surpriseMe,
        ));
      }
    });
    on<ClearSubstitutions>((event, emit) {
      _substitutions = null;
      _currentProgression = null;
      _fromChord = 0;
      _toChord = 0;
      _startDur = 0.0;
      _endDur = null;
      _chordProgressions = null;
      _originalSubs = null;
      _inSetup = false;
      return emit(const ClearedSubstitutions());
    });
    on<SetKeepHarmonicFunction>((event, emit) {
      _keepHarmonicFunction = event.keepHarmonicFunction;
      return emit(ChangedSubstitutionSettings());
    });
  }

  Progression getSubstitutedBase(PitchScale? scale, int index) {
    if (scale == null || type == ProgressionType.romanNumerals) {
      return _substitutions![index].substitutedBase;
    } else {
      return getChordProgression(scale, index);
    }
  }

  // TODO: Decide whether you want to show chords...
  Progression getOriginalSubstitution(PitchScale? scale, int index) {
    return _substitutions![index].originalSubstitution;
    if (scale == null || type == ProgressionType.romanNumerals) {} else {
      return getOriginalSubChords(scale, index);
    }
  }

  ChordProgression getChordProgression(PitchScale scale, int index) {
    assert(index >= 0 && index < _chordProgressions!.length);
    if (_chordProgressions![index] == null) {
      _chordProgressions![index] =
          _substitutions![index].substitutedBase.inScale(scale);
    }
    return _chordProgressions![index]!;
  }

  ChordProgression getOriginalSubChords(PitchScale scale, int index) {
    assert(index >= 0 && index < _originalSubs!.length);
    if (_originalSubs![index] == null) {
      ScaleDegreeProgression originalSub =
          _substitutions![index].originalSubstitution;
      SubstitutionMatch match = _substitutions![index].match;
      if (match.type == SubstitutionMatchType.tonicization) {
        // TODO: Optimize.
        originalSub = originalSub.tonicizedFor(
            _substitutions![index].substitutedBase[match.baseIndex]!);
      }
      _originalSubs![index] = originalSub.inScale(scale);
    }
    return _originalSubs![index]!;
  }
}
